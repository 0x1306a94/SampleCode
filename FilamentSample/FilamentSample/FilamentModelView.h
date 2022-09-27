//
//  FilamentModelView.h
//  FilamentSample
//
//  Created by king on 2022/9/26.
//

#import <UIKit/UIKit.h>

namespace filament {
class Engine;
class Scene;
class View;
class Renderer;
};  // namespace filament

namespace filament::gltfio {
class Animator;
class FilamentAsset;
};  // namespace filament::gltfio

NS_ASSUME_NONNULL_BEGIN

@interface FilamentModelView : UIView
@property (nonatomic, readonly) filament::Engine *engine;
@property (nonatomic, readonly) filament::Scene *scene;
@property (nonatomic, readonly) filament::View *view;
@property (nonatomic, readonly) filament::Renderer *renderer;

@property (nonatomic, readonly) filament::gltfio::FilamentAsset *_Nullable asset;
@property (nonatomic, readonly) filament::gltfio::Animator *_Nullable animator;

@property (nonatomic, readwrite) float cameraFocalLength;

/**
 * Loads a monolithic binary glTF and populates the Filament scene.
 */
- (void)loadModelGlb:(NSData *)buffer;

/**
 * Loads a JSON-style glTF file and populates the Filament scene.
 *
 * The given callback is triggered for each requested resource.
 */
typedef NSData *_Nonnull (^ResourceCallback)(NSString *_Nonnull);
- (void)loadModelGltf:(NSData *)buffer callback:(ResourceCallback)callback;

- (void)destroyModel;

/**
 * Sets up a root transform on the current model to make it fit into a unit cube.
 */
- (void)transformToUnitCube;

/**
 * Renders the model and updates the Filament camera.
 */
- (void)render;

- (void)startAnimationIfNeeded;

- (void)stopAnimationIfNeeded;
@end

NS_ASSUME_NONNULL_END

