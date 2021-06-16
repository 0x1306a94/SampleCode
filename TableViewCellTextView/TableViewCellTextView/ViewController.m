//
//  ViewController.m
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import "ViewController.h"

#import "EditerTableViewCell.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<EditerModel *> *dataSources;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.

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

	cell.tableView = tableView;

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

#pragma mark - lazy
- (UITableView *)tableView {
	if (!_tableView) {
		_tableView              = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
		_tableView.dataSource   = self;
		_tableView.delegate     = self;
		_tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);

		[_tableView registerNib:[UINib nibWithNibName:NSStringFromClass(EditerTableViewCell.class) bundle:nil] forCellReuseIdentifier:@"cell"];
	}
	return _tableView;
}

@end

