#import <Foundation/Foundation.h>

@protocol SROCarouselStrategy <NSObject>

- (BOOL)needRecenter;
- (NSInteger)decreaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount;
- (NSInteger)increaseIndex:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount;
- (NSInteger)distanceBetweenIndex:(NSUInteger)index1 andIndex:(NSUInteger)index2 withCellViewsCount:(NSUInteger)cellViewsCount;
- (BOOL)isIndexValid:(NSInteger)index withCellViewsCount:(NSUInteger)cellViewsCount;

@end
