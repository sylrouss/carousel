#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (CustomLayout)

@property (nonatomic, assign) BOOL layoutAllowsVariableWidth;
@property (nonatomic, assign) BOOL layoutAllowsVariableHeight;
@property (nonatomic, assign) CGSize layoutFixedSize;
@property (nonatomic, assign) CGFloat layoutFixedWidth;
@property (nonatomic, assign) CGFloat layoutFixedHeight;

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat bottom;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat centerX;
@property(nonatomic) CGFloat centerY;

- (CGSize)layoutSizeThatFits:(CGSize)size;

@end
