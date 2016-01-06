#import "SROCarouselViewCell.h"

@interface SROCarouselViewCell ()

@property (nonatomic, strong) NSString *reuseIdentifier;

@end

@implementation SROCarouselViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}
    
#pragma mark - Accessor

- (NSString*)reuseIdentifier
{
    return _reuseIdentifier;
}

@end
