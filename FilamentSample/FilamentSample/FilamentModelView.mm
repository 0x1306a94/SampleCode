//
//  FilamentModelView.m
//  FilamentSample
//
//  Created by king on 2022/9/26.
//

#if !FILAMENT_APP_USE_METAL && !FILAMENT_APP_USE_OPENGL
#error A valid FILAMENT_APP_USE_ backend define must be set.
#endif

#import "FilamentModelView.h"

#import <Foundation/Foundation.h>

#include <filament/Camera.h>
#include <filament/Color.h>
#include <filament/Engine.h>
#include <filament/IndirectLight.h>
#include <filament/LightManager.h>
#include <filament/RenderableManager.h>
#include <filament/Renderer.h>
#include <filament/Scene.h>
#include <filament/Skybox.h>
#include <filament/SwapChain.h>
#include <filament/TransformManager.h>
#include <filament/View.h>
#include <filament/Viewport.h>

#include <gltfio/Animator.h>
#include <gltfio/AssetLoader.h>
#include <gltfio/ResourceLoader.h>
#include <gltfio/TextureProvider.h>
#include <gltfio/materials/uberarchive.h>

#include <ktxreader/Ktx1Reader.h>

#include <utils/EntityManager.h>
#include <utils/NameComponentManager.h>

#include <camutils/Manipulator.h>

using namespace filament;
using namespace utils;
using namespace filament::gltfio;
using namespace camutils;
using namespace ktxreader;

const double kNearPlane = 0.05;   // 5 cm
const double kFarPlane = 1000.0;  // 1 km
const float kScaleMultiplier = 100.0f;
const float kAperture = 16.0f;
const float kShutterSpeed = 1.0f / 125.0f;
const float kSensitivity = 100.0f;

@interface FilamentModelView ()

- (void)initCommon;
- (void)updateViewportAndCameraProjection;
- (void)didPan:(UIGestureRecognizer *)sender;
- (void)didPinch:(UIGestureRecognizer *)sender;

@end

@implementation FilamentModelView {
    Camera *_camera;
    SwapChain *_swapChain;

    struct {
        Entity camera;
    } _entities;

    MaterialProvider *_materialProvider;
    AssetLoader *_assetLoader;
    ResourceLoader *_resourceLoader;

    Manipulator<float> *_manipulator;
    TextureProvider *_stbDecoder;
    TextureProvider *_ktxDecoder;

    FilamentAsset *_asset;

    Texture *_skyboxTexture;
    Skybox *_skybox;
    Texture *_iblTexture;
    IndirectLight *_indirectLight;
    Entity _sun;

    UIPanGestureRecognizer *_panRecognizer;
    UIPinchGestureRecognizer *_pinchRecognizer;
    UITapGestureRecognizer *_doubleTapRecognizer;
    CGFloat _previousScale;
    CADisplayLink *_displayLink;
    CFTimeInterval _startTime;

    BOOL _interaction;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self initCommon];
    }
    return self;
}

- (void)initCommon {
    self.contentScaleFactor = UIScreen.mainScreen.nativeScale;
#if FILAMENT_APP_USE_OPENGL
    [self initializeGLLayer];
    _engine = Engine::create(Engine::Backend::OPENGL);
#elif FILAMENT_APP_USE_METAL
    [self initializeMetalLayer];
    _engine = Engine::create(Engine::Backend::METAL);
#endif

    _renderer = _engine->createRenderer();
    _renderer->setClearOptions({.clear = true});
    _scene = _engine->createScene();
    _entities.camera = EntityManager::get().create();
    _camera = _engine->createCamera(_entities.camera);
    _view = _engine->createView();
    _view->setScene(_scene);
    _view->setCamera(_camera);
    //    _view->setBlendMode(filament::BlendMode::TRANSLUCENT);
    //        _view->setPostProcessingEnabled(false);

    _cameraFocalLength = 28.0f;
    _camera->setExposure(kAperture, kShutterSpeed, kSensitivity);

    _swapChain = _engine->createSwapChain((__bridge void *)self.layer, SwapChain::CONFIG_TRANSPARENT);

    _materialProvider = createUbershaderProvider(_engine, UBERARCHIVE_DEFAULT_DATA, UBERARCHIVE_DEFAULT_SIZE);
    EntityManager &em = EntityManager::get();
    NameComponentManager *ncm = new NameComponentManager(em);
    _assetLoader = AssetLoader::create({_engine, _materialProvider, ncm, &em});
    _resourceLoader = new ResourceLoader({.engine = _engine, .normalizeSkinningWeights = true});
    _stbDecoder = createStbProvider(_engine);
    _ktxDecoder = createKtx2Provider(_engine);
    _resourceLoader->addTextureProvider("image/png", _stbDecoder);
    _resourceLoader->addTextureProvider("image/jpeg", _stbDecoder);
    _resourceLoader->addTextureProvider("image/ktx2", _ktxDecoder);

    _manipulator = Manipulator<float>::Builder().orbitHomePosition(0.0f, 0.0f, 4.0f).build(Mode::ORBIT);

    [self createLights];

    // Set up pan and pinch gesture recognizers, used to orbit, zoom, and translate the camera.
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    _panRecognizer.minimumNumberOfTouches = 1;
    _panRecognizer.maximumNumberOfTouches = 2;
    _pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
    _doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    _doubleTapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:_panRecognizer];
    [self addGestureRecognizer:_pinchRecognizer];
    [self addGestureRecognizer:_doubleTapRecognizer];
    _previousScale = 1.0f;

    _asset = nullptr;
}

- (void)createLights {
    // Load Skybox.
    NSString *skyboxPath = [[NSBundle mainBundle] pathForResource:@"default_env_skybox"
                                                           ofType:@"ktx"];
    assert(skyboxPath.length > 0);
    NSData *skyboxBuffer = [NSData dataWithContentsOfFile:skyboxPath];

    image::Ktx1Bundle *skyboxBundle = new image::Ktx1Bundle(static_cast<const uint8_t *>(skyboxBuffer.bytes),
                                                            static_cast<uint32_t>(skyboxBuffer.length));
    _skyboxTexture = Ktx1Reader::createTexture(self.engine, skyboxBundle, false);
    _skybox = filament::Skybox::Builder().environment(_skyboxTexture).build(*self.engine);
    //    _skybox = filament::Skybox::Builder().color({28.0 / 255.0, 28.0 / 255.0, 28.0 / 255.0, 1.0}).build(*self.engine);
    //    self.scene->setSkybox(nullptr);

    // Load IBL.
    NSString *iblPath = [[NSBundle mainBundle] pathForResource:@"default_env_ibl" ofType:@"ktx"];
    assert(iblPath.length > 0);
    NSData *iblBuffer = [NSData dataWithContentsOfFile:iblPath];

    image::Ktx1Bundle *iblBundle = new image::Ktx1Bundle(static_cast<const uint8_t *>(iblBuffer.bytes),
                                                         static_cast<uint32_t>(iblBuffer.length));
    math::float3 harmonics[9];
    iblBundle->getSphericalHarmonics(harmonics);
    _iblTexture = Ktx1Reader::createTexture(self.engine, iblBundle, false);
    _indirectLight = IndirectLight::Builder()
                         .reflections(_iblTexture)
                         .irradiance(3, harmonics)
                         .intensity(30000.0f)
                         .build(*self.engine);
    self.scene->setIndirectLight(_indirectLight);

    // Always add a direct light source since it is required for shadowing.
    _sun = EntityManager::get().create();
    LightManager::Builder(LightManager::Type::SUN)
        .color(Color::cct(6500.0f))
        .intensity(100000.0f)
        .direction(math::float3(0.0f, -1.0f, 0.0f))
        .castShadows(true)
        .build(*self.engine, _sun);
    self.scene->addEntity(_sun);
}

#pragma mark UIView methods

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateViewportAndCameraProjection];
}

- (void)setContentScaleFactor:(CGFloat)contentScaleFactor {
    [super setContentScaleFactor:contentScaleFactor];
    [self updateViewportAndCameraProjection];
}

#pragma mark FilamentModelView methods

- (void)destroyModel {
    if (!_asset) {
        return;
    }
    _resourceLoader->evictResourceData();
    _scene->removeEntities(_asset->getEntities(), _asset->getEntityCount());
    _assetLoader->destroyAsset(_asset);
    _asset = nullptr;
    _animator = nullptr;
}

- (void)transformToUnitCube {
    if (!_asset) {
        return;
    }
    auto &tm = _engine->getTransformManager();
    auto aabb = _asset->getBoundingBox();
    auto center = aabb.center();
    auto halfExtent = aabb.extent();
    auto maxExtent = max(halfExtent) * 2;
    auto scaleFactor = 2.0f / maxExtent;
    auto transform = math::mat4f::scaling(scaleFactor) * math::mat4f::translation(-center);
    tm.setTransform(tm.getInstance(_asset->getRoot()), transform);
}

- (void)loadModelGlb:(NSData *)buffer {
    [self destroyModel];
    _asset = _assetLoader->createAsset(static_cast<const uint8_t *>(buffer.bytes), static_cast<uint32_t>(buffer.length));

    if (!_asset) {
        return;
    }

    _scene->addEntities(_asset->getEntities(), _asset->getEntityCount());
    _resourceLoader->loadResources(_asset);
    _animator = _asset->getAnimator();
    _asset->releaseSourceData();

    [self startDisplayLink];
}

- (void)loadModelGltf:(NSData *)buffer callback:(ResourceCallback)callback {
    [self destroyModel];
    _asset = _assetLoader->createAsset(static_cast<const uint8_t *>(buffer.bytes), static_cast<uint32_t>(buffer.length));

    if (!_asset) {
        return;
    }

    auto destroy = [](void *, size_t, void *userData) { CFBridgingRelease(userData); };

    const char *const *const resourceUris = _asset->getResourceUris();
    const size_t resourceUriCount = _asset->getResourceUriCount();
    for (size_t i = 0; i < resourceUriCount; i++) {
        const char *const uri = resourceUris[i];
        NSString *uriString = [NSString stringWithCString:uri encoding:NSUTF8StringEncoding];
        NSData *data = callback(uriString);
        ResourceLoader::BufferDescriptor b(
            data.bytes, data.length, destroy, (void *)CFBridgingRetain(data));
        _resourceLoader->addResourceData(uri, std::move(b));
    }

    _resourceLoader->loadResources(_asset);
    _animator = _asset->getAnimator();
    _asset->releaseSourceData();

    _scene->addEntities(_asset->getEntities(), _asset->getEntityCount());

    [self startDisplayLink];
}

- (void)startDisplayLink {
    [self stopDisplayLink];

    // Call our render method 60 times a second.
    _startTime = CACurrentMediaTime();
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render)];
    _displayLink.preferredFramesPerSecond = 60;
    _displayLink.paused = YES;
    [_displayLink addToRunLoop:NSRunLoop.currentRunLoop forMode:NSDefaultRunLoopMode];
}

- (void)stopDisplayLink {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)render {

    if (_animator != nullptr && !_interaction && !_displayLink.paused) {
        if (_animator->getAnimationCount() > 0) {
            CFTimeInterval elapsedTime = CACurrentMediaTime() - _startTime;
            _animator->applyAnimation(0, static_cast<float>(elapsedTime));
        }
        _animator->updateBoneMatrices();
    }

    // Extract the camera basis from the helper and push it to the Filament camera.
    math::float3 eye, target, upward;
    _manipulator->getLookAt(&eye, &target, &upward);
    _camera->lookAt(eye, target, upward);

    // Render the scene, unless the renderer wants to skip the frame.
    if (_renderer->beginFrame(_swapChain)) {
        _renderer->render(_view);
        _renderer->endFrame();
    }
}

- (void)startAnimationIfNeeded {
    if (_animator == nullptr) {
        return;
    }
    _startTime = CACurrentMediaTime();
    _displayLink.paused = NO;
}

- (void)stopAnimationIfNeeded {
    if (_animator == nullptr) {
        return;
    }
    _displayLink.paused = YES;
}

- (void)restManipulator {
    if (_manipulator != nullptr) {
        delete _manipulator;
    }

    _manipulator = Manipulator<float>::Builder().orbitHomePosition(0.0f, 0.0f, 4.0f).build(Mode::ORBIT);
    _previousScale = 1.0;
}

#pragma mark ModelViewer properties

- (void)setCameraFocalLength:(float)cameraFocalLength {
    _cameraFocalLength = cameraFocalLength;
    [self updateViewportAndCameraProjection];
}

#pragma mark Private

- (void)initializeMetalLayer {
#if METAL_AVAILABLE
    CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
    metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    metalLayer.opaque = NO;
#endif
}

- (void)initializeGLLayer {
    CAEAGLLayer *glLayer = (CAEAGLLayer *)self.layer;
    glLayer.opaque = NO;
}

- (void)updateViewportAndCameraProjection {
    if (!_view || !_camera || !_manipulator) {
        return;
    }

    _manipulator->setViewport(self.bounds.size.width, self.bounds.size.height);

    const uint32_t width = self.bounds.size.width * self.contentScaleFactor;
    const uint32_t height = self.bounds.size.height * self.contentScaleFactor;
    _view->setViewport({0, 0, width, height});

#if FILAMENT_APP_USE_METAL
    CAMetalLayer *metalLayer = (CAMetalLayer *)self.layer;
    metalLayer.drawableSize = CGSizeMake(width, height);
#endif

    const double aspect = (double)width / height;
    _camera->setLensProjection(self.cameraFocalLength, aspect, kNearPlane, kFarPlane);
}

- (void)didPan:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    location.y = self.bounds.size.height - location.y;
    if (sender.state == UIGestureRecognizerStateBegan) {
        _interaction = YES;
        const bool strafe = _panRecognizer.numberOfTouches == 2;
        _manipulator->grabBegin(location.x, location.y, strafe);
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        _manipulator->grabUpdate(location.x, location.y);
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateFailed) {
        _manipulator->grabEnd();
        _interaction = NO;
    }

    [self render];
}

- (void)didPinch:(UIGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self];
    location.y = self.bounds.size.height - location.y;
    if (sender.state == UIGestureRecognizerStateBegan) {
        _previousScale = _pinchRecognizer.scale;
        _interaction = YES;
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat deltaScale = _pinchRecognizer.scale - _previousScale;
        _manipulator->scroll(location.x, location.y, -deltaScale * kScaleMultiplier);
        _previousScale = _pinchRecognizer.scale;
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateFailed) {
        _interaction = NO;
    }

    [self render];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    if (tap.state != UIGestureRecognizerStateEnded) {
        return;
    }

    [self restManipulator];
    [self updateViewportAndCameraProjection];
    [self transformToUnitCube];
    [self render];
}

+ (Class)layerClass {
#if FILAMENT_APP_USE_OPENGL
    return [CAEAGLLayer class];
#elif FILAMENT_APP_USE_METAL
    return [CAMetalLayer class];
#endif
}

- (void)dealloc {
    [self destroyModel];

    [self stopDisplayLink];

    delete _manipulator;
    delete _stbDecoder;
    delete _ktxDecoder;

    _materialProvider->destroyMaterials();
    delete _materialProvider;
    auto *ncm = _assetLoader->getNames();
    delete ncm;
    AssetLoader::destroy(&_assetLoader);
    delete _resourceLoader;

    _engine->destroy(_indirectLight);
    _engine->destroy(_iblTexture);
    _engine->destroy(_skybox);
    _engine->destroy(_skyboxTexture);
    _scene->remove(_sun);
    _engine->destroy(_sun);

    _engine->destroy(_swapChain);
    _engine->destroy(_view);
    EntityManager::get().destroy(_entities.camera);
    _engine->destroyCameraComponent(_entities.camera);
    _engine->destroy(_scene);
    _engine->destroy(_renderer);
    _engine->destroy(&_engine);
}
@end

