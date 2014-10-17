#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SROCarouselView.h"
#import "SROBoundedCarouselStrategy.h"
#import "SROInfiniteCarouselStrategy.h"

@interface SROCarouselViewTest : XCTestCase

@property (nonatomic, strong) id mockDataSource;

@end

@implementation SROCarouselViewTest

- (void)tearDown
{
    [self.mockDataSource verify];
    [super tearDown];
}

- (void)testItShouldHaveNoScrollIndicatorByDefault
{
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100) withStrategy: strategy withCarouselDatasource: nil andCarouselDelegate: nil];
    XCTAssertFalse(carouselView.showsHorizontalScrollIndicator, @"no horizontal scroll indicator");
    XCTAssertFalse(carouselView.showsVerticalScrollIndicator, @"no vertical scroll indicator");
}

- (void)testItShouldSetContentSizeTakenIntoAccountNumberOfViewCells
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 30.f;
    static NSString *cellIdentifier = @"cell";
    CGFloat magnetizeOffset = 0;
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                  withSpacing: 0.f
                          withMagnetizeOffset: magnetizeOffset
                            withCellViewWidth: cellViewWidth
                               withFrameWidth: 100
                              reuseIdentifier: cellIdentifier
                            visibleCellsCount: 4];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                              withStrategy: strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    XCTAssertEqual(100.f, carouselView.contentSize.height, @"height should be the frame height");
    XCTAssertEqual(numberOfCellViews * cellViewWidth, carouselView.contentSize.width, @"width should be numberOfCellViews * cellViewWidth");
}

- (void)testLayoutSubviewsShouldInvokesCellViewForIndexForAllVisibleViews
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 30.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 4];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                              withStrategy: strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    NSRange visibleCellViewsRange = NSMakeRange(0, 4);
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[2] forIndex: 2 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[3] forIndex: 3 amongVisibleViewCellsRange: visibleCellViewsRange];
    [carouselView layoutIfNeeded];

    UIView *containerView = carouselView.subviews[0];
    XCTAssertEqual(visibleCellViewsRange.length, [containerView.subviews count], @"check visible calls are added to the view");
    [containerView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(cellViewWidth, 100), view.frame.size));
        XCTAssertTrue(CGPointEqualToPoint(CGPointMake(index*cellViewWidth, 0), view.frame.origin));
    }];
}

- (void)testLayoutSubviewsShouldInvokesCellViewForIndexForAllVisibleViewsWithSpacing
{
    NSUInteger numberOfCellViews = 5;
    CGFloat spacing = 5.f;
    CGFloat magnetizeOffset = 0.f;
    CGFloat cellViewWidth = 30.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 3];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                              withStrategy: strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    NSRange visibleCellViewsRange = NSMakeRange(0, 3);
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[2] forIndex: 2 amongVisibleViewCellsRange: visibleCellViewsRange];
    [carouselView layoutIfNeeded];
    
    UIView *containerView = carouselView.subviews[0];
    XCTAssertEqual(visibleCellViewsRange.length, [containerView.subviews count], @"check visible calls are added to the view");
    [containerView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        XCTAssertTrue(CGSizeEqualToSize(CGSizeMake(cellViewWidth, 100), view.frame.size));
        XCTAssertTrue(CGPointEqualToPoint(CGPointMake(index*(cellViewWidth + spacing), 0), view.frame.origin));
    }];
}
- (void)testItShouldUpdateSubviewsWhenScrollingInCarouselView
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 90.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    NSRange visibleCellViewsRange = NSMakeRange(0, 2);
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: visibleCellViewsRange];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: visibleCellViewsRange];
    [carouselView layoutIfNeeded];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView setContentOffset: CGPointMake(80, 0) animated: YES];
    [carouselView layoutIfNeeded];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(120, 0) animated: YES];
    [carouselView layoutIfNeeded];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 0 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 2) reuseIdentifier:cellIdentifier];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView setContentOffset: CGPointMake(40, 0) animated: YES];
    [carouselView layoutIfNeeded];
}

- (void)testItShouldFeedRecycleViewsWhenScrollingInCarouselView
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 100.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 1];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 1)];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check no reusable cell are available");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    UIView *view1 = [self expectViewForCellAtIndex: 1 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(2, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check no reusable cell are available");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view1 forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(101, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertEqual(visibleCells[0], [carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check first cell is reusable");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check that once cell is dequeued, no reusable cell is available");
}

- (void)testItShouldFeedRecycleViewsWithIdentifiersWhenScrollingInCarouselView
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 100.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifierA = @"cellA";
    static NSString *cellIdentifierB = @"cellB";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifierA
                                                    visibleCellsCount: 1];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];

    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 1)];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierA], @"check no reusable cell are available");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierB], @"check no reusable cell are available");

    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    SROCarouselViewCell *view1 = [self expectViewForCellAtIndex: 1 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 2) reuseIdentifier:cellIdentifierB];
    [carouselView setContentOffset: CGPointMake(2, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierA], @"check no reusable cell are available");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierB], @"check no reusable cell are available");

    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view1 forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 1)];
    [carouselView setContentOffset: CGPointMake(100, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertEqual(visibleCells[0], [carouselView dequeueReusableCellWithIdentifier:cellIdentifierA], @"check first cell is reusable");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierA], @"check no reusable cell are available");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierB], @"check no reusable cell are available");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 0 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 1) reuseIdentifier:cellIdentifierA];
    [carouselView setContentOffset: CGPointMake(0, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierA], @"check no reusable cell are available");
    XCTAssertEqual(view1, [carouselView dequeueReusableCellWithIdentifier:cellIdentifierB], @"check first cell is reusable");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifierB], @"check no reusable cell are available");
}

- (void)testItShouldFeedRecycleViewsWhenScrollingInCarouselViewWithSpacing
{
    NSUInteger numberOfCellViews = 5;
    CGFloat spacing = 5.f;
    CGFloat magnetizeOffset = 0.f;
    CGFloat cellViewWidth = 100.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 1];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 1)];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check no reusable cell are available");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    UIView *view1 = [self expectViewForCellAtIndex: 1 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(6, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check no reusable cell are available");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view1 forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(111, 0) animated: YES];
    [carouselView layoutIfNeeded];
    XCTAssertEqual(visibleCells[0], [carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check first cell is reusable");
    XCTAssertNil([carouselView dequeueReusableCellWithIdentifier:cellIdentifier], @"check that once cell is dequeued, no reusable cell is available");
}

- (void)testItShouldReturnVisibleViewCellsRange
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    NSRange visibleViewCellsRange = [carouselView visibleViewCellsRange];
    XCTAssertEqual((NSUInteger)0, visibleViewCellsRange.location, @"check first visible view cell is 0");
    XCTAssertEqual((NSUInteger)2, visibleViewCellsRange.length, @"check that 2 views are visibke");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(70, 0)];
    [carouselView layoutIfNeeded];
    visibleViewCellsRange = [carouselView visibleViewCellsRange];
    XCTAssertEqual((NSUInteger)1, visibleViewCellsRange.location, @"check first visible view cell is 1");
    XCTAssertEqual((NSUInteger)2, visibleViewCellsRange.length, @"check that 2 views are visibke");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 0 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 2)reuseIdentifier:cellIdentifier];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView setContentOffset: CGPointMake(40, 0)];
    [carouselView layoutIfNeeded];
    visibleViewCellsRange = [carouselView visibleViewCellsRange];
    XCTAssertEqual((NSUInteger)0, visibleViewCellsRange.location, @"check first visible view cell is 1");
    XCTAssertEqual((NSUInteger)2, visibleViewCellsRange.length, @"check that 2 views are visibke");
}

- (void)testItShouldReturnNewVisibleViewCellsRangeWhenScrolling
{
    NSUInteger numberOfCellViews = 3;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 3)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 3)];
    UIView *view2 = [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(0, 3)reuseIdentifier:cellIdentifier];
    [carouselView setContentOffset: CGPointMake(60, 0) animated: YES];
    [carouselView layoutIfNeeded];
    NSRange visibleViewCellsRange = [carouselView visibleViewCellsRange];
    XCTAssertEqual((NSUInteger)0, visibleViewCellsRange.location, @"check first visible view cell is 0");
    XCTAssertEqual((NSUInteger)3, visibleViewCellsRange.length, @"check that 3 views are visibles");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view2 forIndex: 2 amongVisibleViewCellsRange: NSMakeRange(2, 1)];
    [carouselView setContentOffset: CGPointMake(145, 0) animated: YES];
    [carouselView layoutIfNeeded];
    visibleViewCellsRange = [carouselView visibleViewCellsRange];
    XCTAssertEqual((NSUInteger)2, visibleViewCellsRange.location, @"check first visible view cell is 2");
    XCTAssertEqual((NSUInteger)1, visibleViewCellsRange.length, @"check that 1 view is visible");
}

- (void)testItShouldScrollViewToViewCellAtIndex
{
    NSUInteger numberOfCellViews = 4;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 1 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(70, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    UIView *view2 = [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier ];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 3 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(180, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view2 forIndex: 2 amongVisibleViewCellsRange: NSMakeRange(2, 2)];
    [self expectViewForCellAtIndex: 3 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(2, 2) reuseIdentifier:cellIdentifier];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 0 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}

- (void)testItShouldScrollViewToViewCellAtIndexWithSpacing
{
    NSUInteger numberOfCellViews = 4;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 5.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 1 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(75, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(1, 2)];
    UIView *view2 = [self expectViewForCellAtIndex: 2 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(1, 2) reuseIdentifier:cellIdentifier];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 3 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(180, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: view2 forIndex: 2 amongVisibleViewCellsRange: NSMakeRange(2, 2)];
    [self expectViewForCellAtIndex: 3 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(2, 2) reuseIdentifier:cellIdentifier];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 0 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}

- (void)testItShouldScrollViewToViewCellWithBoundedStrategyWithMagnetizedOffset
{
    NSUInteger numberOfCellViews = 10;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 6 animated: YES offset: -20];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(400, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 5 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(5, 3) reuseIdentifier: cellIdentifier];
    [self expectViewForCellAtIndex: 6 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(5, 3) reuseIdentifier: cellIdentifier];
    [self expectViewForCellAtIndex: 7 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(5, 3) reuseIdentifier: cellIdentifier];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(400, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}

- (void)testItShouldScrollViewToLastViewCellWithBoundedStrategy
{
    NSUInteger numberOfCellViews = 10;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 9 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(600, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 8 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(8, 2) reuseIdentifier: cellIdentifier];
    [self expectViewForCellAtIndex: 9 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(8, 2) reuseIdentifier: cellIdentifier];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(600, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}

- (void)testItShouldScrollViewToViewCellBeforeTheVisibleOneWithInfiniteStrategy
{
    NSUInteger numberOfCellViews = 10;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROInfiniteCarouselStrategy *strategy = [[SROInfiniteCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];

    [carouselView scrollViewToViewCellAtIndex: 7 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));

    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 7 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(7, 2) reuseIdentifier: cellIdentifier];
    [self expectViewForCellAtIndex: 8 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(7, 2) reuseIdentifier: cellIdentifier];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(200, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}

- (void)testItShouldScrollViewToViewCellAfterTheVisibleOneWithInfiniteStrategy
{
    NSUInteger numberOfCellViews = 30;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROInfiniteCarouselStrategy *strategy = [[SROInfiniteCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    
    [carouselView scrollViewToViewCellAtIndex: 8 animated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));

    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [self expectViewForCellAtIndex: 8 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(8, 2) reuseIdentifier: cellIdentifier];
    [self expectViewForCellAtIndex: 9 withCarouselView: carouselView withVisibleViewCellsRange: NSMakeRange(8, 2) reuseIdentifier: cellIdentifier];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(200, 0), carouselView.contentOffset), @"check content offset :%@", NSStringFromCGPoint(carouselView.contentOffset));
}
- (void)testItShouldMagnetizeViewViewInRightDirection
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                             withStrategy : strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check initial content offset");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset has not changed");
    
    id mockPanGestureReconizer = [OCMockObject partialMockForObject: carouselView.panGestureRecognizer];
    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(-60, 0)]] translationInView: carouselView];
    NSUInteger targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(70, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(1, targetIndex);
}

- (void)testItShouldMagnetizeViewViewInRightDirectionWithMagnetizeOffset
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 60.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = -10.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100) withStrategy : strategy withCarouselDatasource: self.mockDataSource andCarouselDelegate: nil];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check initial content offset");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset has not changed");
    
    id mockPanGestureReconizer = [OCMockObject partialMockForObject: carouselView.panGestureRecognizer];
    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(-60, 0)]] translationInView: carouselView];
    NSUInteger targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(50, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(1, targetIndex);
}

- (void)testItShouldMagnetizeViewViewInLeftDirection
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 0.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100) withStrategy : strategy withCarouselDatasource: self.mockDataSource andCarouselDelegate: nil];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check initial content offset");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset has not changed");
    
    id mockPanGestureReconizer = [OCMockObject partialMockForObject: carouselView.panGestureRecognizer];
    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(-60, 0)]] translationInView: carouselView];
	NSUInteger targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(70, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(1, targetIndex);

    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(20, 0)]] translationInView: carouselView];
    targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(0, targetIndex);
}

- (void)testItShouldMagnetizeViewViewInLeftDirectionWithSpacing
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 70.f;
    CGFloat spacing = 5.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    NSArray *visibleCells = [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                                          withSpacing: spacing
                                                  withMagnetizeOffset: magnetizeOffset
                                                    withCellViewWidth: cellViewWidth
                                                       withFrameWidth: 100
                                                      reuseIdentifier: cellIdentifier
                                                    visibleCellsCount: 2];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100) withStrategy : strategy withCarouselDatasource: self.mockDataSource andCarouselDelegate: nil];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"check initial content offset");
    
    [self expectCarouselView: carouselView
       withNumberOfCellViews: numberOfCellViews
                 withSpacing: spacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: cellViewWidth];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[0] forIndex: 0 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: visibleCells[1] forIndex: 1 amongVisibleViewCellsRange: NSMakeRange(0, 2)];
    [carouselView layoutIfNeeded];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset has not changed");
    
    id mockPanGestureReconizer = [OCMockObject partialMockForObject: carouselView.panGestureRecognizer];
    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(-60, 0)]] translationInView: carouselView];
    NSUInteger targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(75, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(1, targetIndex);

    [[[mockPanGestureReconizer expect] andReturnValue: [NSValue valueWithCGPoint: CGPointMake(20, 0)]] translationInView: carouselView];
    targetIndex = [carouselView magnetizeViewCellInDirectionAnimated: YES];
    XCTAssertTrue(CGPointEqualToPoint(CGPointMake(0, 0), carouselView.contentOffset), @"content offset %@ should be set on next cell", NSStringFromCGPoint(carouselView.contentOffset));
	XCTAssertEqual(0, targetIndex);
}

- (void)testItShouldReloadData
{
    NSUInteger numberOfCellViews = 5;
    CGFloat cellViewWidth = 30.f;
    CGFloat spacing = 5.f;
    CGFloat magnetizeOffset = 0.f;
    static NSString *cellIdentifier = @"cell";
    
    SROBoundedCarouselStrategy *strategy = [[SROBoundedCarouselStrategy alloc] init];
    [self mockDataSourceWithNumberOfCellViews: numberOfCellViews
                                  withSpacing: spacing
                          withMagnetizeOffset: magnetizeOffset
                            withCellViewWidth: cellViewWidth
                               withFrameWidth: 100
                              reuseIdentifier: cellIdentifier
                            visibleCellsCount: 3];
    
    SROCarouselView *carouselView = [[SROCarouselView alloc] initWithFrame: CGRectMake(0, 0, 100, 100)
                                                              withStrategy: strategy
                                                    withCarouselDatasource: self.mockDataSource
                                                       andCarouselDelegate: nil];
    
    XCTAssertEqual(100.f, carouselView.contentSize.height, @"height should be the frame height");
    XCTAssertEqual(numberOfCellViews * cellViewWidth, carouselView.contentSize.width, @"width should be numberOfCellViews * cellViewWidth");

    NSUInteger newNumberOfCellViews = 5;
    CGFloat newCellViewWidth = 30.f;
    CGFloat newSpacing = 5.f;
    [self expectCarouselView: carouselView
       withNumberOfCellViews: newNumberOfCellViews
                 withSpacing: newSpacing
         withMagnetizeOffset: magnetizeOffset
           withCellViewWidth: newCellViewWidth];
    [carouselView reloadData];

    XCTAssertEqual(100.f, carouselView.contentSize.height, @"height should be the frame height");
    XCTAssertEqual(newNumberOfCellViews * newCellViewWidth, carouselView.contentSize.width, @"width should be numberOfCellViews * cellViewWidth");
}

#pragma mark - Private

- (SROCarouselViewCell *)expectViewForCellAtIndex:(NSUInteger)index withCarouselView:(SROCarouselView *)carouselView withVisibleViewCellsRange:(NSRange)visibleViewCellsRange reuseIdentifier:(NSString *)identifier
{
    SROCarouselViewCell *cellView = [[SROCarouselViewCell alloc] initWithFrame: CGRectZero reuseIdentifier:identifier];
    [[[self.mockDataSource expect] andReturn: cellView] carouselView: carouselView viewCellForIndex: index];
    [[self.mockDataSource expect] carouselView: carouselView configureViewCell: cellView forIndex: index amongVisibleViewCellsRange: visibleViewCellsRange];
    return cellView;
}

- (void)expectCarouselView:(SROCarouselView *)carouselView
     withNumberOfCellViews:(NSUInteger)numberOfCellViews
               withSpacing:(CGFloat)spacing
       withMagnetizeOffset:(CGFloat)magnetizeOffset
         withCellViewWidth:(CGFloat)cellViewWidth
{
    [[[self.mockDataSource expect] andReturnValue: OCMOCK_VALUE(numberOfCellViews)] numberOfViewsCellsInCarouselView: carouselView];
    [[[self.mockDataSource expect] andReturnValue: OCMOCK_VALUE(spacing)] cellViewSpacingInCarouselView: carouselView];
    [[[self.mockDataSource expect] andReturnValue: OCMOCK_VALUE(magnetizeOffset)] cellViewMagnetizeOffset: carouselView];
    [[[self.mockDataSource expect] andReturnValue: OCMOCK_VALUE(cellViewWidth)] cellViewWidthInCarouselView: carouselView];
}

- (NSArray *)mockDataSourceWithNumberOfCellViews:(NSUInteger)numberOfCellViews
                                     withSpacing:(CGFloat)spacing
                             withMagnetizeOffset:(CGFloat)magnetizeOffset
                               withCellViewWidth:(CGFloat)cellViewWidth
                                  withFrameWidth:(CGFloat)width
                                 reuseIdentifier:(NSString *)identifier
                               visibleCellsCount:(NSUInteger)visibleCellsCount
{
    id carouselViewClassChecker =  [OCMArg checkWithBlock:^BOOL(id value) {
        return [value isKindOfClass: [SROCarouselView class]];
    }];
    id mockDataSource = [OCMockObject mockForProtocol: @protocol(SROCarouselViewDataSource)];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(numberOfCellViews)] numberOfViewsCellsInCarouselView: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(spacing)] cellViewSpacingInCarouselView: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(magnetizeOffset)] cellViewMagnetizeOffset: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(cellViewWidth)] cellViewWidthInCarouselView: carouselViewClassChecker];
    NSMutableArray *visibleCells = [NSMutableArray array];
    for (NSUInteger index = 0; index < visibleCellsCount; index++)
    {
        UIView *cellView = [[SROCarouselViewCell alloc] initWithFrame: CGRectZero reuseIdentifier:identifier];
        [[[mockDataSource expect] andReturn: cellView] carouselView: carouselViewClassChecker viewCellForIndex: index];
        [visibleCells addObject: cellView];
    }
    self.mockDataSource = mockDataSource;
    return visibleCells;
}

- (id)mockDataSourceWithNumberOfCellViews:(NSUInteger)numberOfCellViews
                              withSpacing:(CGFloat)spacing
                      withMagnetizeOffset:(CGFloat)magnetizeOffset
                        withCellViewWidth:(CGFloat)cellViewWidth
{
    id carouselViewClassChecker =  [OCMArg checkWithBlock:^BOOL(id value) {
        return [value isKindOfClass: [SROCarouselView class]];
    }];
    id mockDataSource = [OCMockObject mockForProtocol: @protocol(SROCarouselViewDataSource)];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(numberOfCellViews)] numberOfViewsCellsInCarouselView: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(spacing)] cellViewSpacingInCarouselView: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(magnetizeOffset)] cellViewMagnetizeOffset: carouselViewClassChecker];
    [[[mockDataSource expect] andReturnValue: OCMOCK_VALUE(cellViewWidth)] cellViewWidthInCarouselView: carouselViewClassChecker];
    UIView *cellView = [[UIView alloc] initWithFrame: CGRectZero];
    [[[mockDataSource expect] andReturn: cellView] carouselView: carouselViewClassChecker viewCellForIndex: 0];
    [[[mockDataSource expect] andReturn: cellView] carouselView: carouselViewClassChecker viewCellForIndex: 1];
    [[[mockDataSource expect] andReturn: cellView] carouselView: carouselViewClassChecker viewCellForIndex: 2];
    [[[mockDataSource expect] andReturn: cellView] carouselView: carouselViewClassChecker viewCellForIndex: 3];
    return mockDataSource;
}

@end
