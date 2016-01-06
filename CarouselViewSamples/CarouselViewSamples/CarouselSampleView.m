#import "CarouselSampleView.h"
#import "SROCarouselView.h"
#import "SROInfiniteCarouselStrategy.h"
#import "CarouselSampleViewCell.h"

@interface CarouselSampleView ()  <SROCarouselViewDataSource, SROCarouselViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) SROCarouselView *carouselView;

@end

@implementation CarouselSampleView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame: frame]))
    {
        [self setBackgroundColor: [UIColor clearColor]];
        [self addSubview: self.carouselView];
    }
    return self;
}

#pragma mark - MPYCarouselViewDataSource

- (NSUInteger)numberOfViewsCellsInCarouselView:(SROCarouselView *)carouselView
{
    return 3;
}

- (CGFloat)cellViewWidthInCarouselView:(SROCarouselView *)carouselView
{
    return carouselView.width/2;
}

- (SROCarouselViewCell *)carouselView:(SROCarouselView *)carouselView viewCellForIndex:(NSUInteger)index
{
    static NSString *cellIdentifier = @"cell";
    CarouselSampleViewCell *viewCell = [carouselView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (viewCell == nil)
    {
        viewCell = [[CarouselSampleViewCell alloc] initWithFrame: CGRectMake(0, 0, self.width/5, 50) reuseIdentifier:cellIdentifier];
    }
    NSString *imageNamed = [NSString stringWithFormat: @"image%lu.png", (unsigned long)index];
    [viewCell setImage: [UIImage imageNamed: imageNamed]];
    return viewCell;
}

- (void)carouselView:(SROCarouselView *)carouselView configureViewCell:(UIView *)view forIndex:(NSUInteger)index amongVisibleViewCellsRange:(NSRange)visibleViewCellsRange
{
    CGFloat center = carouselView.contentOffset.x + carouselView.width/2;
    CGFloat distanceFromCenter = fabs(center - view.center.x);
    CGFloat scale = 1 - distanceFromCenter/(self.carouselView.width - self.carouselView.width/2);
    CarouselSampleViewCell *viewCell = (CarouselSampleViewCell *)view;
    viewCell.imageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, scale, scale);
}

#pragma mark - MPYCarouselViewDelegate

- (void)carouselView:(SROCarouselView *)carouselView didSelectCellViewAtIndex:(NSUInteger)index
{
    NSLog(@"Selected Cell %lu", (unsigned long)index);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.carouselView magnetizeViewCellInDirectionAnimated: YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        [self.carouselView magnetizeViewCellInDirectionAnimated: YES];
    }
}

#pragma mark - Private

- (SROCarouselView *)carouselView
{
    if (!_carouselView)
    {
        _carouselView = [[SROCarouselView alloc] initWithFrame: self.frame
                                                  withStrategy: [[SROInfiniteCarouselStrategy alloc] init]
                                        withCarouselDatasource: self
                                           andCarouselDelegate: self];
        _carouselView.delegate = self;
        [_carouselView scrollViewToViewCellAtIndex: 3 animated: NO];
    }
    return _carouselView;
}

@end
