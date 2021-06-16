//
//  EditerTableViewCell.h
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import <UIKit/UIKit.h>

#import "EditerModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EditerTableViewCellDelegate;

@interface EditerTableViewCell : UITableViewCell
@property (nonatomic, weak) id<EditerTableViewCellDelegate> delegate;
- (void)updateModel:(EditerModel *)model;
@end

@protocol EditerTableViewCellDelegate <NSObject>

@optional
- (void)editerTableViewCell:(EditerTableViewCell *)cell newHeightAfterTextChanged:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END

