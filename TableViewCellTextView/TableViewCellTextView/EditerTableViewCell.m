//
//  EditerTableViewCell.m
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import "EditerTableViewCell.h"

#import <QMUIKit/QMUITextView.h>

@interface EditerTableViewCell () <QMUITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet QMUITextView *textView;

@property (nonatomic, strong) EditerModel *model;
@end

@implementation EditerTableViewCell
- (void)awakeFromNib {
	[super awakeFromNib];

	self.layer.cornerRadius  = 10;
	self.layer.masksToBounds = YES;

	self.backgroundColor = UIColor.orangeColor;
	self.textView.backgroundColor = UIColor.lightGrayColor;
}

- (void)setFrame:(CGRect)frame {

	frame.size.width -= 30;
	frame.origin.x = 15;

	[super setFrame:frame];
}

- (void)updateModel:(EditerModel *)model {
	self.model = model;

	self.nameLabel.text = model.title;
	self.textView.text  = model.content ?: @"";

	self.textView.placeholder = model.title;
	self.textView.placeholderColor = UIColor.lightTextColor;

	self.textView.delegate = self;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	self.textView.delegate = nil;
}

#pragma mark - QMUITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
	self.model.content = textView.text;
}

- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height {
	CGFloat h = MAX(self.model.minInputHeight, height);
	if (h != self.model.inputHeight) {
		self.model.inputHeight = h;
		// 触发高度代理回调
		[self.tableView beginUpdates];

		[self.tableView endUpdates];
	}
}
@end

