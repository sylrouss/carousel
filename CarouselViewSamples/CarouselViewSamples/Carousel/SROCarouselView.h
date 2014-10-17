#import <UIKit/UIKit.h>
#import "UIView+CustomLayout.h"
#import "SROCarouselStrategy.h"
#import "SROCarouselViewCell.h"

@class SROCarouselView;

@protocol SROCarouselViewDataSource <NSObject>

@required
- (NSUInteger)numberOfViewsCellsInCarouselView:(SROCarouselView *)carouselView;
- (CGFloat)cellViewWidthInCarouselView:(SROCarouselView *)carouselView;
- (SROCarouselViewCell *)carouselView:(SROCarouselView *)carouselView viewCellForIndex:(NSUInteger)index;

@optional
- (void)carouselView:(SROCarouselView *)carouselView configureViewCell:(UIView *)view forIndex:(NSUInteger)index amongVisibleViewCellsRange:(NSRange)visibleViewCellsRange;
- (CGFloat)cellViewSpacingInCarouselView:(SROCarouselView *)carouselView;
- (CGFloat)cellViewMagnetizeOffset:(SROCarouselView *)carouselView;

@end

@protocol SROCarouselViewDelegate <NSObject>

@required
- (void)carouselView:(SROCarouselView *)carouselView didSelectCellViewAtIndex:(NSUInteger)index;

@end

@interface SROCarouselView : UIScrollView

@property (nonatomic, strong) id<SROCarouselStrategy> strategy;

- (id)initWithFrame:(CGRect)frame withStrategy:(id<SROCarouselStrategy>)strategy withCarouselDatasource:(id<SROCarouselViewDataSource>)carouselDataSource andCarouselDelegate:(id<SROCarouselViewDelegate>)carouselDelegate;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (NSRange)visibleViewCellsRange;
- (void)scrollViewToViewCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)scrollViewToViewCellAtIndex:(NSUInteger)cellViewIndex animated:(BOOL)animated offset:(CGFloat)offset;
- (NSUInteger)magnetizeViewCellInDirectionAnimated:(BOOL)animated;
- (void)reloadData;

@end
