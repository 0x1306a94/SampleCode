//
//  ViewController.m
//  FilamentSample
//
//  Created by king on 2022/9/26.
//

#import "ViewController.h"

#import "FilamentModelView.h"

@interface ViewController ()
@property (nonatomic, strong) FilamentModelView *modelView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.lightGrayColor;

    FilamentModelView *modelView = [[FilamentModelView alloc] init];
    self.modelView = modelView;
    modelView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:modelView];
    modelView.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [modelView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [modelView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [modelView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [modelView.heightAnchor constraintEqualToAnchor:modelView.widthAnchor],
    ]];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = UIColor.orangeColor;
    [button setTitle:@"Start Animation" forState:UIControlStateNormal];
    [button setTitle:@"Stop Animation" forState:UIControlStateSelected];
    button.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.selected = NO;
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    [NSLayoutConstraint activateConstraints:@[
        [button.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [button.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    ]];
    [self.view layoutIfNeeded];

#if 0
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cup.glb" ofType:nil];
    assert(path.length > 0);
    NSData *buffer = [NSData dataWithContentsOfFile:path];
    [self.modelView loadModelGlb:buffer];
#else
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cup"
                                                     ofType:@"gltf"
                                                inDirectory:@"BusterDrone"];
    assert(path.length > 0);
    NSData *buffer = [NSData dataWithContentsOfFile:path];
    [self.modelView loadModelGltf:buffer callback:^NSData *(NSString *uri) {
        NSString *p = [[NSBundle mainBundle] pathForResource:uri
                                                      ofType:@""
                                                 inDirectory:@"BusterDrone"];
        return [NSData dataWithContentsOfFile:p];
    }];
#endif

    [self.modelView transformToUnitCube];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.modelView render];
}

- (void)buttonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.modelView startAnimationIfNeeded];
    } else {
        [self.modelView stopAnimationIfNeeded];
    }
}
@end

