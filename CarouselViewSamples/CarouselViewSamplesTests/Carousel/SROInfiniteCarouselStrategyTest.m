#import <XCTest/XCTest.h>
#import "SROInfiniteCarouselStrategy.h"

@interface SROInfiniteCarouselStrategyTest : XCTestCase

@property (nonatomic, strong) SROInfiniteCarouselStrategy *strategy;

@end

@implementation SROInfiniteCarouselStrategyTest

- (void)setUp
{
    [super setUp];
    _strategy = [[SROInfiniteCarouselStrategy alloc] init];
}

- (void)testItShouldNeedRenceter
{
    XCTAssertTrue([self.strategy needRecenter], @"it should not need to recenter");
}

- (void)testItShouldNotDecreaseWithNegativeValue
{
    XCTAssertEqual((NSInteger)2, [self.strategy decreaseIndex: 3 withCellViewsCount: 100], @"decreasing from 3 should be 2");
    XCTAssertEqual((NSInteger)99, [self.strategy decreaseIndex: 0 withCellViewsCount: 100], @"decreasing index should be negative");
}

- (void)testItShouldNotIncrease
{
    XCTAssertEqual((NSInteger)2, [self.strategy increaseIndex: 1 withCellViewsCount: 10], @"increasing from 1 should be 2");
    XCTAssertEqual((NSInteger)0, [self.strategy increaseIndex: 99 withCellViewsCount: 100], @"increasing index should greater or equal to cell views count");
}

- (void)testValueShouldbeValidIfGreaterThan0AndLesserThanCellViewsCount
{
    XCTAssertTrue([self.strategy isIndexValid: 0 withCellViewsCount: 10], @"O should be valid");
    XCTAssertFalse([self.strategy isIndexValid: -1 withCellViewsCount: 10], @"-1 should be valid");
    XCTAssertTrue([self.strategy isIndexValid: 9 withCellViewsCount: 10], @"9 should be valid");
    XCTAssertFalse([self.strategy isIndexValid: 10 withCellViewsCount: 10], @"1O should be valid");
    XCTAssertFalse([self.strategy isIndexValid: 13 withCellViewsCount: 10], @"13 should be valid");
    XCTAssertFalse([self.strategy isIndexValid: 0 withCellViewsCount: 0], @"0 cell views count should return a invalid value");
}

- (void)testItShouldReturnAbsoluteDistanceBetween2Index
{
    XCTAssertEqual((NSInteger)7, [self.strategy distanceBetweenIndex: 0 andIndex: 7 withCellViewsCount: 15]);
    XCTAssertEqual((NSInteger)1, [self.strategy distanceBetweenIndex: 7 andIndex: 0 withCellViewsCount: 8]);
    XCTAssertEqual((NSInteger)3, [self.strategy distanceBetweenIndex: 9 andIndex: 1 withCellViewsCount: 11]);
    XCTAssertEqual((NSInteger)-1, [self.strategy distanceBetweenIndex: 4 andIndex: 3 withCellViewsCount: 4]);
    XCTAssertEqual((NSInteger)-2, [self.strategy distanceBetweenIndex: 1 andIndex: 8 withCellViewsCount: 9]);
}

@end
