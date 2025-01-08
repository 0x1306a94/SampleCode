//
//  ViewController.m
//  BezierPathSample
//
//  Created by KK on 2025/1/8.
//

#import "ViewController.h"

@interface KKCustomTabBar : UIView
@property (nonatomic, assign) BOOL flipHorizontally;
@end

@implementation KKCustomTabBar

+ (Class)layerClass {
    return CAShapeLayer.class;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (CGRectIsEmpty(self.bounds)) {
        return;
    }

    UIColor *fillColor = UIColor.whiteColor;
    CAShapeLayer *layer = ((CAShapeLayer *)self.layer);
    UIBezierPath *bezierPath = [self buildBezierPath:self.bounds];
    if (self.flipHorizontally) {
        const CGFloat midX = CGRectGetMidX(self.bounds);
        // 1. 将路径移动到以 x 为中心的位置
        CGAffineTransform translateToOrigin = CGAffineTransformMakeTranslation(-midX, 0);

        // 2. 应用水平翻转变换
        CGAffineTransform flipTransform = CGAffineTransformMakeScale(-1, 1);

        // 3. 将路径移回原始位置
        CGAffineTransform translateBack = CGAffineTransformMakeTranslation(midX, 0);

        // 合并三个变换
        CGAffineTransform combinedTransform = CGAffineTransformConcat(translateToOrigin, flipTransform);
        combinedTransform = CGAffineTransformConcat(combinedTransform, translateBack);

        // 应用变换到路径
        [bezierPath applyTransform:combinedTransform];
    }
    layer.path = bezierPath.CGPath;
    layer.fillColor = fillColor.CGColor;
    layer.strokeColor = UIColor.blueColor.CGColor;
}

- (UIBezierPath *)buildBezierPath:(CGRect)bounds {
    UIBezierPath *path = [UIBezierPath bezierPath];

    const CGFloat minX = CGRectGetMinX(bounds);
    const CGFloat minY = CGRectGetMinY(bounds);
    const CGFloat maxX = CGRectGetMaxX(bounds);
    const CGFloat maxY = CGRectGetMaxY(bounds);
    const CGFloat midX = CGRectGetMidX(bounds);
    const CGFloat topSpacing = 45;
    const CGFloat middleLineWidth = 16;
    const CGFloat cornerRadii = 10;

    // 左上角圆角
    [path addArcWithCenter:CGPointMake(minX + cornerRadii, minY + cornerRadii) radius:cornerRadii startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    // 左侧直线
    [path addLineToPoint:CGPointMake(midX - middleLineWidth * 0.5, minY)];
    // 左上弧线 + 1 是为了连接处平滑
    [path addQuadCurveToPoint:CGPointMake(midX - middleLineWidth * 0.5 + cornerRadii + 1, minY + cornerRadii) controlPoint:CGPointMake(midX - middleLineWidth * 0.5 + cornerRadii, minY)];
    // 中间斜线
    [path addLineToPoint:CGPointMake(midX + middleLineWidth * 0.5, topSpacing - cornerRadii)];
    // 右下弧线 - 1 是为了连接处平滑
    [path addQuadCurveToPoint:CGPointMake(midX + middleLineWidth * 0.5 + cornerRadii, topSpacing) controlPoint:CGPointMake(midX + middleLineWidth * 0.5 + 1, topSpacing)];
    // 右侧直线
    [path addLineToPoint:CGPointMake(maxX - cornerRadii, topSpacing)];
    // 右上角圆角
    [path addArcWithCenter:CGPointMake(maxX - cornerRadii, topSpacing + cornerRadii) radius:cornerRadii startAngle:M_PI_2 * 3 endAngle:0 clockwise:YES];
    // 底部和关闭路径
    [path addLineToPoint:CGPointMake(maxX, maxY)];
    [path addLineToPoint:CGPointMake(minX, maxY)];
    [path addLineToPoint:CGPointMake(minX, minY + cornerRadii)];
    [path closePath];

    return path;
}

- (void)setFlipHorizontally:(BOOL)flipHorizontally {
    if (_flipHorizontally == flipHorizontally) {
        return;
    }
    _flipHorizontally = flipHorizontally;
    [self setNeedsLayout];
}
@end

@interface ViewController ()
@property (nonatomic, strong) KKCustomTabBar *tabBarShapeView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = UIColor.grayColor;

    KKCustomTabBar *tabBarShapeView = [KKCustomTabBar new];
    tabBarShapeView.backgroundColor = UIColor.orangeColor;
    tabBarShapeView.translatesAutoresizingMaskIntoConstraints = NO;
    _tabBarShapeView = tabBarShapeView;
    [self.view addSubview:tabBarShapeView];

    [NSLayoutConstraint activateConstraints:@[
        [tabBarShapeView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [tabBarShapeView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [tabBarShapeView.heightAnchor constraintEqualToConstant:74],
        [tabBarShapeView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:30],
    ]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.tabBarShapeView.flipHorizontally = !self.tabBarShapeView.flipHorizontally;
}
@end
