//
//  ViewController.m
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import "ViewController.h"

#import "EditerTableViewCell.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate, EditerTableViewCellDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<EditerModel *> *dataSources;

@property (nonatomic, assign) CGRect keyboardRect;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

	self.keyboardRect = CGRectNull;

	self.navigationController.navigationBar.translucent = NO;
	self.edgesForExtendedLayout                         = UIRectEdgeNone;

	self.view.backgroundColor      = [UIColor colorWithRed:(0xf8 / 255.0) green:(0xf8 / 255.0) blue:(0xf8 / 255.0) alpha:1.0];
	self.tableView.backgroundColor = [UIColor colorWithRed:(0xf8 / 255.0) green:(0xf8 / 255.0) blue:(0xf8 / 255.0) alpha:1.0];
	[self.view addSubview:self.tableView];

	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;

	[NSLayoutConstraint activateConstraints:@[
		[self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
		[self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
		[self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
		[self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
	]];

	self.dataSources = @[
		[EditerModel editerWithTitle:@"姓名"],
		[EditerModel editerWithTitle:@"电话"],
		[EditerModel editerWithTitle:@"城市"],
		[EditerModel editerWithTitle:@"详细地址"],
	];

	//增加监听，当键盘出现或改变时收出消息
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillShow:)
	                                             name:UIKeyboardWillShowNotification
	                                           object:nil];

	//增加监听，当键退出时收出消息
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(keyboardWillHide:)
	                                             name:UIKeyboardWillHideNotification
	                                           object:nil];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
	//获取键盘的高度
	NSDictionary *userInfo = [aNotification userInfo];
	NSValue *aValue        = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	CGRect keyboardRect    = [aValue CGRectValue];

	self.keyboardRect = keyboardRect;
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification {
	self.keyboardRect = CGRectNull;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	EditerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

	EditerModel *model = self.dataSources[indexPath.section];

	cell.delegate = self;

	[cell updateModel:model];
	return cell;
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *view         = [[UIView alloc] init];
	view.backgroundColor = UIColor.clearColor;
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	EditerModel *model = self.dataSources[indexPath.section];
	CGFloat height     = model.topSpacing + model.inputHeight + model.bottomSpacing;
	return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 20;
}

#pragma mark - EditerTableViewCellDelegate
- (void)editerTableViewCell:(EditerTableViewCell *)cell newHeightAfterTextChanged:(CGFloat)height {
	// 触发高度代理回调
	[self.tableView beginUpdates];

	[self.tableView endUpdates];

	NSLog(@"%@", NSStringFromCGRect(cell.frame));
	CGRect frame = [self.tableView convertRect:cell.frame toView:self.view];
	NSLog(@"%@", NSStringFromCGRect(frame));
	frame = [self.view convertRect:frame toView:self.view.window];
	NSLog(@"%@", NSStringFromCGRect(frame));
	// 底部间距
	frame.origin.y -= 15;

	NSLog(@"%@", NSStringFromCGRect(self.keyboardRect));
	NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
	if (indexPath && !CGRectIsNull(self.keyboardRect) && CGRectGetMaxY(frame) > CGRectGetMinY(self.keyboardRect)) {
		[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
	}
}

#pragma mark - lazy
- (UITableView *)tableView {
	if (!_tableView) {
		_tableView              = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.dataSource   = self;
		_tableView.delegate     = self;
		_tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);

		_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

		[_tableView registerNib:[UINib nibWithNibName:NSStringFromClass(EditerTableViewCell.class) bundle:nil] forCellReuseIdentifier:@"cell"];
	}
	return _tableView;
}

@end

