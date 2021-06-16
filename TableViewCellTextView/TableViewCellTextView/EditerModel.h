//
//  EditerModel.h
//  TableViewCellTextView
//
//  Created by king on 2021/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EditerModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, assign) float topSpacing;
@property (nonatomic, assign) float bottomSpacing;
@property (nonatomic, assign) float minInputHeight;
@property (nonatomic, assign) float inputHeight;

+ (instancetype)editerWithTitle:(NSString *)title;
@end

NS_ASSUME_NONNULL_END

