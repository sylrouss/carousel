#import "UIView+CustomLayout.h"

@implementation UIView (CustomLayout)

- (void)setLayoutAllowsVariableWidth:(BOOL)variableWidth {
	
    [self.layer setValue:[NSNumber numberWithBool:variableWidth] forKey:@"allowsVariableWidth"];
}

- (BOOL)layoutAllowsVariableWidth {
	
    NSNumber *value = (NSNumber *)[self.layer valueForKey:@"allowsVariableWidth"];
    if (value != nil) {
		
		return [value boolValue];
    }
    return NO;
}

- (void)setLayoutAllowsVariableHeight:(BOOL)variableHeight {
	
    [self.layer setValue:[NSNumber numberWithBool:variableHeight] forKey:@"allowsVariableHeight"];
}

- (BOOL)layoutAllowsVariableHeight {
	
    NSNumber *value = (NSNumber *)[self.layer valueForKey:@"allowsVariableHeight"];
    if (value != nil) {
		
		return [value boolValue];
    }
    return NO;
}

- (void)setLayoutFixedSize:(CGSize)size {

	[self setLayoutFixedWidth:size.width];
	[self setLayoutFixedHeight:size.height];
}

- (CGSize)layoutFixedSize {

    return CGSizeMake(self.layoutFixedWidth, self.layoutFixedHeight);
}

- (void)setLayoutFixedWidth:(CGFloat)width {

    [self.layer setValue:[NSNumber numberWithFloat:width] forKey:@"fixedWidth"];
}

- (CGFloat)layoutFixedWidth {
	
	return [[self.layer valueForKey:@"fixedWidth"] floatValue];
}

- (void)setLayoutFixedHeight:(CGFloat)height {

    [self.layer setValue:[NSNumber numberWithFloat:height] forKey:@"fixedHeight"];
}

- (CGFloat)layoutFixedHeight {

	return [[self.layer valueForKey:@"fixedHeight"] floatValue];
}

- (CGSize)layoutSizeThatFits:(CGSize)size {
	
	CGSize layoutSize = [self sizeThatFits:size];
	if ([self layoutFixedWidth]) {
		
		layoutSize.width = [self layoutFixedWidth];
	}
	if ([self layoutFixedHeight]) {
		
		layoutSize.height = [self layoutFixedHeight];
	}
	return layoutSize;
}

#pragma mark -

- (CGFloat)left
{
	return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x
{
	CGRect frame = self.frame;
	frame.origin.x = x;
	self.frame = frame;
}

- (CGFloat)right
{
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
	CGRect frame = self.frame;
	frame.origin.x = right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)top
{
	return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y
{
	CGRect frame = self.frame;
	frame.origin.y = y;
	self.frame = frame;
}

- (CGFloat)bottom
{
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
	CGRect frame = self.frame;
	frame.origin.y = bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)width
{
	return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
	CGRect frame = self.frame;
	frame.size.width = width;
	self.frame = frame;
}

- (CGFloat)height
{
	return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
	CGRect frame = self.frame;
	frame.size.height = height;
	self.frame = frame;
}

- (CGFloat)centerX
{
	return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
	CGPoint center = CGPointMake(centerX, self.center.y);
	self.center = center;
}

- (CGFloat)centerY
{
	return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
	CGPoint center = CGPointMake(self.center.x, centerY);
	self.center = center;
}

@end
