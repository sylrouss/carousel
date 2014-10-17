#import <XCTest/XCTest.h>
#import "SROBoundedCarouselStrategy.h"

@interface SROBoundedCarouselStrategyTest : XCTestCase

@property (nonatomic, strong) SROBoundedCarouselStrategy *strategy;

@end

@implementation SROBoundedCarouselStrategyTest

- (void)setUp
{
    [super setUp];
    _strategy = [[SROBoundedCarouselStrategy alloc] init];
}

- (void)testItShouldNotNeedRenceter
{
    XCTAssertFalse([self.strategy needRecenter], @"it should not need to recenter");
}

- (void)testItShouldDecreaseWithNegativeValue
{
    XCTAssertEqual((NSInteger)2, [self.strategy decreaseIndex: 3 withCellViewsCount: 100], @"decreasing from 3 should be 2");
    XCTAssertEqual((NSInteger)-1, [self.strategy decreaseIndex: 0 withCellViewsCount: 100], @"decreasing index should be negative");
}

- (void)testItShouldIncreaseWithValueGreaterOrEqualToCellViewsCount
{
    XCTAssertEqual((NSInteger)2, [self.strategy increaseIndex: 1 withCellViewsCount: 10], @"increasing from 1 should be 2");
    XCTAssertEqual((NSInteger)100, [self.strategy increaseIndex: 99 withCellViewsCount: 100], @"increasing index should greater or equal to cell views count");
}

- (void)testValueShouldbeValidIfGreaterThan0AndLesserThanCellViewsCount
{
    XCTAssertTrue([self.strategy isIndexValid: 0 withCellViewsCount: 10], @"O should be valid");
    XCTAssertFalse([self.strategy isIndexValid: -1 withCellViewsCount: 10], @"-1 should be valid");
    XCTAssertTrue([self.strategy isIndexValid: 9 withCellViewsCount: 10], @"9 should be valid");
    XCTAssertFalse([self.strategy isIndexValid: 10 withCellViewsCount: 10], @"1O should be valid");
    XCTAssertFalse([self.strategy isIndexValid: 13 withCellViewsCount: 10], @"13 should be valid");
}

- (void)testItShouldReturnAbsoluteDistanceBetween2Index
{
    XCTAssertEqual((NSInteger)7, [self.strategy distanceBetweenIndex: 0 andIndex: 7 withCellViewsCount: 2]);
    XCTAssertEqual((NSInteger)-7, [self.strategy distanceBetweenIndex: 7 andIndex: 0 withCellViewsCount: 2]);
    XCTAssertEqual((NSInteger)-8, [self.strategy distanceBetweenIndex: 9 andIndex: 1 withCellViewsCount: 9]);
    XCTAssertEqual((NSInteger)-1, [self.strategy distanceBetweenIndex: 4 andIndex: 3 withCellViewsCount: 4]);
}

@end
