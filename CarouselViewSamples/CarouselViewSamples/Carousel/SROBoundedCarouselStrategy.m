#import "SROBoundedCarouselStrategy.h"

@implementation SROBoundedCarouselStrategy

- (BOOL)needRecenter
{
    return NO;
}

- (NSInteger)decreaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index - 1;
}

- (NSInteger)increaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index + 1;
}

- (NSInteger)distanceBetweenIndex:(NSUInteger)index1 andIndex:(NSUInteger)index2 withCellViewsCount:(NSUInteger)cellViewsCount
{
    return (int)index2 - (int)index1;
}

- (BOOL)isIndexValid:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index >= 0 && index < cellViewsCount;
}

@end
