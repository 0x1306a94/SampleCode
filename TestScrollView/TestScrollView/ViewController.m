//
//  ViewController.m
//  TestScrollView
//
//  Created by king on 2023/2/20.
//

#import "ViewController.h"

#import "TDXDBlockScrollContainerView.h"

#import "TDXDBlockScrollGoodsListComponent.h"
#import "TDXDBlockScrollGoodsThemeRichTextComponent.h"

@interface ViewController ()
@property (nonatomic, strong) TDXDBlockScrollContainerView *scrollContainerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    TDXDBlockScrollContainerView *scrollContainerView = [[TDXDBlockScrollContainerView alloc] initWithFrame:self.view.bounds];
    self.scrollContainerView = scrollContainerView;
    scrollContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:scrollContainerView];

    [NSLayoutConstraint activateConstraints:@[
        [scrollContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:0],
        [scrollContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:0],
        [scrollContainerView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:0],
        [scrollContainerView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:0],
    ]];
    
    [self setupComponents];
}

- (void)setupComponents {
    TDXDBlockScrollGoodsThemeRichTextComponent *richTextComponent = [[TDXDBlockScrollGoodsThemeRichTextComponent alloc] init];
    TDXDBlockScrollGoodsListComponent *listComponent = [[TDXDBlockScrollGoodsListComponent alloc] init];

    [self.scrollContainerView addComponents:@[richTextComponent, listComponent]];
}

@end
