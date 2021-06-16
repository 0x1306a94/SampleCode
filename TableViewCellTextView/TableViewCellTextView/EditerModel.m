//
//  EditerModel.m
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import "EditerModel.h"

@implementation EditerModel
- (instancetype)init {
	if (self == [super init]) {
		_topSpacing     = 40;
		_bottomSpacing  = 15;
		_minInputHeight = 20;
		_inputHeight    = _minInputHeight;
	}
	return self;
}

+ (instancetype)editerWithTitle:(NSString *)title {
	EditerModel *m = [[EditerModel alloc] init];
	m.title        = title;
	return m;
}
@end

