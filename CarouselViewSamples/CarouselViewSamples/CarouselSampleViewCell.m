#import "CarouselSampleViewCell.h"
#import "UIView+CustomLayout.h"

@implementation CarouselSampleViewCell

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame: CGRectZero];
        _imageView.backgroundColor = [UIColor clearColor];
        [self addSubview: _imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.center = CGPointMake(self.width/2, self.height/2 - 8);
}

#pragma mark - Public

- (void)setImage: (UIImage *)image
{
    self.imageView.image = image;
    [self.imageView sizeToFit];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
