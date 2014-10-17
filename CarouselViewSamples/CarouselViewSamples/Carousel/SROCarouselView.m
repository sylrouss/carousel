#import "SROCarouselView.h"

#define CAROUSEL_VIEW_TAG_CONSTANT      1000
#define CAROUSEL_SUBVIEWS_TAG_FACTOR    10

@interface SROCarouselView ()

@property (nonatomic, weak) id<SROCarouselViewDataSource>carouselDataSource;
@property (nonatomic, weak) id<SROCarouselViewDelegate>carouselDelegate;
@property (nonatomic, assign) NSUInteger cellViewsCount;
@property (nonatomic, assign) CGFloat cellViewSpacing;
@property (nonatomic, assign) CGFloat cellViewMagnetizeOffset;
@property (nonatomic, assign) CGFloat cellViewWidth;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSMutableDictionary *recycledViewCells;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation SROCarouselView

- (id)initWithFrame:(CGRect)frame withStrategy:(id<SROCarouselStrategy>)strategy withCarouselDatasource:(id<SROCarouselViewDataSource>)carouselDataSource andCarouselDelegate:(id<SROCarouselViewDelegate>)carouselDelegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _strategy = strategy;
        _carouselDataSource = carouselDataSource;
        _carouselDelegate = carouselDelegate;
        _recycledViewCells = [[NSMutableDictionary alloc] init];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        _containerView = [[UIView alloc] initWithFrame: CGRectZero];
        [self addSubview: _containerView];
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(didTapInView:)];
        [_containerView addGestureRecognizer: _tapGestureRecognizer];
        [self initIfNeeded];
        [self scrollViewToViewCellAtIndex: 0 animated: NO];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self initIfNeeded];
    [self recenterIfNeeded];
    [self recycleViewsThatAreNotVisibleAnymore];
    [self updateVisibleViewCells];
    [self recycleViewsThatAreNotVisibleAnymore];
    [self configureVisibleViewCell];
}

#pragma mark - Public

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    NSMutableArray *cells = [self cellsFromIdentifier:identifier];
    SROCarouselViewCell *reusableViewCell = [cells lastObject];
    [cells removeLastObject];
    return reusableViewCell;
}

- (void)scrollViewToViewCellAtIndex:(NSUInteger)cellViewIndex animated:(BOOL)animated
{
    [self scrollViewToViewCellAtIndex:cellViewIndex animated:animated offset:0];
}

- (void)scrollViewToViewCellAtIndex:(NSUInteger)cellViewIndex animated:(BOOL)animated offset:(CGFloat)offset
{
    if (cellViewIndex > self.cellViewsCount)
    {
        return;
    }
    self.currentIndex = cellViewIndex;
    SROCarouselViewCell *view = [self viewCellWithIndex: cellViewIndex];
    if (view != nil)
    {
        [self setContentOffset: CGPointMake(MIN(view.left + offset, self.contentSize.width - self.width), 0) animated: animated];
        return;
    }
    SROCarouselViewCell *firstVisibleView = [self firstVisibleViewCell];
    if (firstVisibleView == nil)
    {
        [self updateVisibleViewCells];
        firstVisibleView = [self firstVisibleViewCell];
    }
    CGFloat offsetX = firstVisibleView.left + offset;
    NSUInteger firstVisibleViewIndex = [self viewCellIndexWithView: firstVisibleView];
    CGFloat offsetShift = [self.strategy distanceBetweenIndex: firstVisibleViewIndex andIndex: cellViewIndex withCellViewsCount: self.cellViewsCount] * (self.cellViewWidth + self.cellViewSpacing);
    if (![self.strategy needRecenter])
    {
        [self setContentOffset: CGPointMake(MIN(offsetX + offsetShift, self.contentSize.width - self.width), 0) animated: animated];
        return;
    }
    if ((offsetX + offsetShift) < 0 || (offset + offsetShift) > (self.contentSize.width - self.width))
    {
        [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *cellView, NSUInteger index, BOOL *stop) {
            [cellView removeFromSuperview];
            NSMutableArray *cells = [self cellsFromIdentifier:[cellView reuseIdentifier]];
            [cells addObject: cellView];
        }];
        [self setContentOffset: CGPointMake(0, 0)];
    }
    else
    {
        [self setContentOffset: CGPointMake(offsetX + offsetShift, 0) animated: animated];
    }
}

- (NSRange)visibleViewCellsRange
{
    SROCarouselViewCell *firstVisibleViewCell = [self firstVisibleViewCell];
    return NSMakeRange([self viewCellIndexWithView: firstVisibleViewCell], [self.containerView.subviews count]);
}

- (NSUInteger)magnetizeViewCellInDirectionAnimated:(BOOL)animated
{
    CGPoint translation = [self.panGestureRecognizer translationInView: self];
    SROCarouselViewCell *firstVisibleViewCell = [self firstVisibleViewCell];
    NSUInteger viewCellIndex = [self viewCellIndexWithView: firstVisibleViewCell];
    NSUInteger targetViewCellIndex = translation.x >= 0 ? viewCellIndex : [self.strategy increaseIndex: viewCellIndex withCellViewsCount: self.cellViewsCount];
    if (targetViewCellIndex == 0)
    {
        [self scrollViewToViewCellAtIndex: targetViewCellIndex animated: animated offset:0];
    }
    else
    {
        [self scrollViewToViewCellAtIndex: targetViewCellIndex animated: animated offset:self.cellViewMagnetizeOffset];
    }
	return targetViewCellIndex;
}

- (void)reloadData
{
    [self initIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - Actions

- (void)didTapInView:(id)sender
{
    CGPoint locationInView = [self.tapGestureRecognizer locationInView: self];
    __block NSUInteger viewCellIndex = self.cellViewsCount - 1;
    [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *view, NSUInteger index, BOOL *stop) {
        if (locationInView.x > view.frame.origin.x && locationInView.x < (view.frame.origin.x + view.frame.size.width))
        {
            *stop = YES;
            viewCellIndex = (view.tag - CAROUSEL_VIEW_TAG_CONSTANT)/10;
        }
    }];
    [self.carouselDelegate carouselView: self didSelectCellViewAtIndex: viewCellIndex];
}

#pragma mark - Private

- (void)initIfNeeded
{
    BOOL needToInit = NO;
    CGFloat cellViewsCount = [self.carouselDataSource numberOfViewsCellsInCarouselView: self];
    needToInit |= cellViewsCount != self.cellViewsCount;
    if ([self.carouselDataSource respondsToSelector: @selector(cellViewSpacingInCarouselView:)])
    {
        CGFloat cellViewSpacing = [self.carouselDataSource cellViewSpacingInCarouselView: self];
        needToInit |= cellViewSpacing != self.cellViewSpacing;
        self.cellViewSpacing = cellViewSpacing;
    }
    if ([self.carouselDataSource respondsToSelector: @selector(cellViewMagnetizeOffset:)])
    {
        CGFloat cellViewMagnetizeOffset = [self.carouselDataSource cellViewMagnetizeOffset: self];
        needToInit |= cellViewMagnetizeOffset != self.cellViewMagnetizeOffset;
        self.cellViewMagnetizeOffset = cellViewMagnetizeOffset;
    }
    
    CGFloat cellViewWidth = [self.carouselDataSource cellViewWidthInCarouselView: self];
    needToInit |= cellViewWidth != self.cellViewWidth;
    if (needToInit)
    {
        self.cellViewsCount = cellViewsCount;
        self.cellViewWidth = cellViewWidth;
        CGFloat contentWidth = [_strategy needRecenter] ? ((self.cellViewSpacing + self.cellViewWidth) * self.cellViewsCount) > self.width ? self.width*5 : self.width : self.cellViewWidth * self.cellViewsCount;
        contentWidth -= self.cellViewMagnetizeOffset;
        self.contentSize = CGSizeMake(contentWidth, self.height);
        self.containerView.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    }
}

- (void)recenterIfNeeded
{
    if ([self.strategy needRecenter])
    {
        CGPoint currentOffset = self.contentOffset;
        CGFloat contentWidth = self.contentSize.width;
        CGFloat centerOffsetX = (contentWidth - self.bounds.size.width)/2;
        CGFloat distanceFromCenter = fabs(currentOffset.x - centerOffsetX);
        if (distanceFromCenter > (contentWidth / 4.0))
        {
            self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);
            [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *view, NSUInteger index, BOOL *stop) {
                CGPoint center = view.center;
                center.x += (centerOffsetX - currentOffset.x);
                view.center = center;
            }];
        }
    }
}

- (void)recycleViewsThatAreNotVisibleAnymore
{
    [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *cellView, NSUInteger index, BOOL *stop)
     {
         if (cellView.right <= self.contentOffset.x || cellView.left >= (self.contentOffset.x + self.frame.size.width))
         {
             [cellView removeFromSuperview];
             NSMutableArray *cells = [self cellsFromIdentifier:[cellView reuseIdentifier] ];
             [cells addObject: cellView];
         }
     }];
}

- (void)updateVisibleViewCells
{
    SROCarouselViewCell *firstVisibleViewCell = [self firstVisibleViewCell];
    if (firstVisibleViewCell == nil || (firstVisibleViewCell.left <= self.contentOffset.x && firstVisibleViewCell.right > self.contentOffset.x))
    {
        CGFloat startX = [self startXFromVisibleViewCell: firstVisibleViewCell];
        NSInteger currentIndex = firstVisibleViewCell == nil ? self.currentIndex : [self viewCellIndexWithView: firstVisibleViewCell];
        CGFloat width = 0;
        CGFloat viewWidthToCover = self.width + (firstVisibleViewCell == nil ? self.contentOffset.x - startX : self.contentOffset.x - firstVisibleViewCell.left);
        while (width < viewWidthToCover && [self.strategy isIndexValid: currentIndex withCellViewsCount: self.cellViewsCount])
        {
            SROCarouselViewCell *viewCell = [self addViewCellWithIndex: currentIndex];
            viewCell.frame = CGRectMake(startX, 0, self.cellViewWidth, self.height);
            currentIndex = [self.strategy increaseIndex: currentIndex withCellViewsCount: self.cellViewsCount];
            width += self.cellViewWidth + self.cellViewSpacing;
            startX += self.cellViewWidth + self.cellViewSpacing;
        }
    }
    else
    {
        CGFloat startX = firstVisibleViewCell.left;
        NSInteger currentIndex = [self viewCellIndexWithView: firstVisibleViewCell];
        currentIndex = [self.strategy decreaseIndex: currentIndex withCellViewsCount: self.cellViewsCount];
        CGFloat width = 0;
        while (width < (firstVisibleViewCell.left - self.contentOffset.x) &&
               [self.strategy isIndexValid: currentIndex withCellViewsCount: self.cellViewsCount])
        {
            SROCarouselViewCell *viewCell = [self addViewCellWithIndex: currentIndex];
            startX -= (self.cellViewWidth + self.cellViewSpacing);
            viewCell.frame = CGRectMake(startX, 0, self.cellViewWidth, self.height);
            currentIndex = [self.strategy decreaseIndex: currentIndex withCellViewsCount: self.cellViewsCount];
            width += self.cellViewWidth + self.cellViewSpacing;
        }
    }
}

- (CGFloat)startXFromVisibleViewCell:(UIView *)visibleViewCell
{
    if (visibleViewCell != nil)
    {
        return visibleViewCell.left;
    }
    if ([self.strategy needRecenter])
    {
        return self.contentOffset.x;
    }
    CGFloat xForCurrentIndex = self.currentIndex * (self.cellViewWidth + self.cellViewSpacing);
    while (xForCurrentIndex > self.contentOffset.x)
    {
        self.currentIndex = [self.strategy decreaseIndex: self.currentIndex withCellViewsCount: self.cellViewsCount];
        xForCurrentIndex = self.currentIndex * (self.cellViewWidth + self.cellViewSpacing);
    }
    return xForCurrentIndex;
}

- (SROCarouselViewCell *)addViewCellWithIndex:(NSUInteger)index
{
    SROCarouselViewCell *viewCell = [self viewCellWithIndex: index];
    if (viewCell == nil)
    {
        viewCell = [self.carouselDataSource carouselView: self viewCellForIndex: index];
        viewCell.tag = CAROUSEL_VIEW_TAG_CONSTANT + CAROUSEL_SUBVIEWS_TAG_FACTOR * index;
        [self.containerView addSubview: viewCell];
    }
    return viewCell;
}

- (void)configureVisibleViewCell
{
    if ([self.carouselDataSource respondsToSelector:@selector(carouselView:configureViewCell:forIndex:amongVisibleViewCellsRange:)])
    {
        NSRange visibleViewCellsRange = [self visibleViewCellsRange];
        [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *view, NSUInteger index, BOOL *stop) {
            [self.carouselDataSource carouselView: self
                                configureViewCell: view
                                         forIndex: [self viewCellIndexWithView: view]
                       amongVisibleViewCellsRange: visibleViewCellsRange];
        }];
    };
}

- (SROCarouselViewCell *)firstVisibleViewCell
{
    __block SROCarouselViewCell *firstVisibleViewCell = nil;
    __block CGFloat minx = -1;
    [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *view, NSUInteger idx, BOOL *stop) {
        if (minx < 0 || view.frame.origin.x < minx)
        {
            firstVisibleViewCell = view;
            minx = view.frame.origin.x;
        }
    }];
    return firstVisibleViewCell;
}

- (SROCarouselViewCell *)viewCellWithIndex:(NSUInteger)searchedViewCellIndex
{
    __block SROCarouselViewCell *viewCell = nil;
    [self.containerView.subviews enumerateObjectsUsingBlock:^(SROCarouselViewCell *view, NSUInteger index, BOOL *stop) {
        NSUInteger viewCellIndex = [self viewCellIndexWithView: view];
        if (viewCellIndex == searchedViewCellIndex)
        {
            *stop = YES;
            viewCell = view;
        }
    }];
    return viewCell;
}

- (NSUInteger)viewCellIndexWithView:(SROCarouselViewCell *)view
{
    return (view.tag - CAROUSEL_VIEW_TAG_CONSTANT)/10;
}

- (NSMutableArray *)cellsFromIdentifier:(NSString *)identifier
{
    NSMutableArray *cells = [self.recycledViewCells objectForKey:identifier];
    if (cells == nil)
    {
        cells = [[NSMutableArray alloc] init];
        [self.recycledViewCells setValue:cells forKey:identifier];
    }
    return cells;
}

@end
