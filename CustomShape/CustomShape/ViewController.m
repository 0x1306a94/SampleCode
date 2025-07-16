//
//  ViewController.m
//  CustomShape
//
//  Created by king on 2025/7/15.
//

#import "ViewController.h"

@interface MyView : UIView
@property (nonatomic, strong) CAGradientLayer *borderLayer;
@property (nonatomic, strong) CAShapeLayer *backgroundLayer;
@end

@implementation MyView
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
    self.backgroundColor = [UIColor whiteColor];

    UIColor *borderStartColor = UIColor.redColor;
    UIColor *borderEndColor = UIColor.blueColor;
    _borderLayer = [CAGradientLayer layer];
    _borderLayer.startPoint = CGPointMake(0.0, 0.5);
    _borderLayer.endPoint = CGPointMake(1.0, 0.5);
    _borderLayer.locations = @[@0.0, @1.0];
    _borderLayer.colors = @[
        (id)borderStartColor.CGColor,
        (id)borderEndColor.CGColor,
    ];

    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.fillColor = UIColor.whiteColor.CGColor;

    [self.layer addSublayer:_borderLayer];
    [self.layer addSublayer:_backgroundLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (CGSizeEqualToSize(CGSizeZero, self.bounds.size)) {
        return;
    }

    CGRect bounds = (CGRect){CGPointZero, self.bounds.size};
    self.borderLayer.frame = bounds;
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.fillColor = UIColor.clearColor.CGColor;
    maskLayer.strokeColor = UIColor.whiteColor.CGColor;
    maskLayer.lineWidth = 4;
    maskLayer.frame = bounds;
    CGRect fillBounds = CGRectInset(bounds, 2, 2);
    UIBezierPath *path = [self buildBezierPath:fillBounds cornerRadius:10 centerCornerRadius:9];
    maskLayer.path = path.CGPath;
    self.borderLayer.mask = maskLayer;

    self.backgroundLayer.frame = fillBounds;
    fillBounds = (CGRect){CGPointZero, CGSizeMake(fillBounds.size.width, fillBounds.size.height)};
    UIBezierPath *fillPath = [self buildBezierPath:fillBounds cornerRadius:10 centerCornerRadius:9];
    self.backgroundLayer.path = fillPath.CGPath;
}

- (UIBezierPath *)buildBezierPath:(CGRect)bounds cornerRadius:(CGFloat)cornerRadius centerCornerRadius:(CGFloat)centerCornerRadius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    const CGFloat minX = CGRectGetMinX(bounds);
    const CGFloat minY = CGRectGetMinY(bounds);
    const CGFloat maxX = CGRectGetMaxX(bounds);
    const CGFloat maxY = CGRectGetMaxY(bounds);
    const CGFloat midY = CGRectGetMidY(bounds);

    const CGFloat topLeftCenterX = minX + cornerRadius;
    const CGFloat topLeftCenterY = minY + cornerRadius;

    const CGFloat topRightCenterX = maxX - cornerRadius;
    const CGFloat topRightCenterY = minY + cornerRadius;

    const CGFloat bottomLeftCenterX = minX + cornerRadius;
    const CGFloat bottomLeftCenterY = maxY - cornerRadius;

    const CGFloat bottomRightCenterX = maxX - cornerRadius;
    const CGFloat bottomRightCenterY = maxY - cornerRadius;

    const CGFloat leftCenterCircleX = minX;
    const CGFloat rightCenterCircleX = maxX;

    // 1. 左上
    [path addArcWithCenter:CGPointMake(topLeftCenterX, topLeftCenterY) radius:cornerRadius startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    // 2. 右上
    [path addArcWithCenter:CGPointMake(topRightCenterX, topRightCenterY) radius:cornerRadius startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    // 3. 右侧中心半圆
    [path addArcWithCenter:CGPointMake(rightCenterCircleX, midY) radius:centerCornerRadius startAngle:M_PI_2 * 3 endAngle:M_PI_2 clockwise:NO];
    // 4. 右下
    [path addArcWithCenter:CGPointMake(bottomRightCenterX, bottomRightCenterY) radius:cornerRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    // 5. 左下
    [path addArcWithCenter:CGPointMake(bottomLeftCenterX, bottomLeftCenterY) radius:cornerRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    // 6. 左侧中心半圆
    [path addArcWithCenter:CGPointMake(leftCenterCircleX, midY) radius:centerCornerRadius startAngle:M_PI_2 endAngle:M_PI_2 * 3 clockwise:NO];
    [path closePath];

    return path;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    MyView *view = [[MyView alloc] initWithFrame:CGRectMake(15, 200, 366, 60)];
    [self.view addSubview:view];
}

@end
