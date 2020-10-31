//
//  ViewController.m
//  TestTableView
//
//  Created by king on 2020/8/20.
//  Copyright © 2020 0x1306a94. All rights reserved.
//

#import "ViewController.h"

#import "CommentListViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) CommentListViewController *commentListVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.bgView                 = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.bgView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    [self.view insertSubview:self.bgView atIndex:0];

    self.commentListVC = [[CommentListViewController alloc] init];
    [self.view addSubview:self.commentListVC.view];
    self.commentListVC.view.frame = self.view.bounds;
}

- (IBAction)showButtonAction:(UIButton *)sender {
    [self.commentListVC show];
}

@end

