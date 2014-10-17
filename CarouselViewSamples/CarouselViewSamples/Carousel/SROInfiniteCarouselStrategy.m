#import "SROInfiniteCarouselStrategy.h"

@implementation SROInfiniteCarouselStrategy

- (BOOL)needRecenter
{
    return YES;
}

- (NSInteger)decreaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index == 0 ? cellViewsCount - 1 : index - 1;
}

- (NSInteger)increaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index == cellViewsCount - 1 ? 0 : index + 1;
}

- (NSInteger)distanceBetweenIndex:(NSUInteger)index1 andIndex:(NSUInteger)index2 withCellViewsCount:(NSUInteger)cellViewsCount
{
    NSUInteger distance = abs((int)index2 - (int)index1);
    if (distance <= cellViewsCount/2)
    {
        return (int)index2 - (int)index1;
    }
    return index2 > index1 ? (int)index2 - (int)index1 - (int)cellViewsCount : (int)index2 - (int)index1 + (int)cellViewsCount;
}

- (BOOL)isIndexValid:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount
{
    return index >= 0 && index < cellViewsCount && cellViewsCount != 0;
}

@end
