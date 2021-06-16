//
//  EditerTableViewCell.h
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import <UIKit/UIKit.h>

#import "EditerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditerTableViewCell : UITableViewCell
@property (nonatomic, weak) UITableView *tableView;
- (void)updateModel:(EditerModel *)model;
@end

NS_ASSUME_NONNULL_END

