//
//  TDXDBlockScrollGoodsThemeRichTextComponent.m
//  TestScrollView
//
//  Created by king on 2023/2/20.
//

#import "TDXDBlockScrollGoodsThemeRichTextComponent.h"

@interface TDXDBlockScrollGoodsThemeRichTextComponent () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger count;
@end

@implementation TDXDBlockScrollGoodsThemeRichTextComponent

#pragma mark - life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

#pragma mark - Initial Methods
- (void)commonInit {
    /*custom view u want draw in here*/
    self.backgroundColor = [UIColor clearColor];

    self.count = 30;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.frame style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor orangeColor];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.scrollEnabled = NO;
    tableView.scrollsToTop = NO;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 50;

    [self addSubview:tableView];
    self.tableView = tableView;

    [NSLayoutConstraint activateConstraints:@[
        [tableView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [tableView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [tableView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [tableView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
    ]];

    [self addSubViews];
    [self addSubViewConstraints];

    [tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark - add subview
- (void)addSubViews {
}

#pragma mark - layout
- (void)addSubViewConstraints {
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context {
    if (![keyPath isEqualToString:@"contentOffset"]) {
        return;
    }

    CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    NSLog(@"RichText: %f", contentOffset.y);
}

// MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"RichText: %ld", indexPath.row];
    return cell;
}

// MARK: - TDXDBlockScrollComponent
- (CGFloat)conetntHeight {
    return self.tableView.rowHeight * self.count;
}

- (CGPoint)maxContentOffset {
    CGSize contentSize = self.tableView.contentSize;
    CGRect bounds = self.tableView.bounds;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    return CGPointMake(
        contentSize.width - bounds.size.width + contentInset.right,
        contentSize.height - bounds.size.height + contentInset.bottom);
}

- (void)updateEnableScroll:(BOOL)enable {
}

- (void)updateScrollOffset:(CGFloat)offset {
    CGPoint contentOffset = CGPointMake(0, offset);
    [self.tableView setContentOffset:contentOffset animated:NO];
}
@end
