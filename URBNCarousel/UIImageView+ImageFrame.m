#import "UIImageView+ImageFrame.h"

@implementation UIImageView (ImageFrame)

- (CGRect)imageFrame
{
    CGSize imageSize = self.image.size;
    CGSize frameSize = self.frame.size;
    
    CGRect resultFrame = CGRectZero;
    
    BOOL imageSmallerThanFrame = (imageSize.width < frameSize.width) && (imageSize.height < frameSize.height);
    if (imageSmallerThanFrame == YES)
    {
        resultFrame.size = imageSize;
    }
    else
    {
        CGFloat widthRatio  = imageSize.width  / frameSize.width;
        CGFloat heightRatio = imageSize.height / frameSize.height;
        CGFloat maxRatio = MAX(widthRatio, heightRatio);
        
        resultFrame.size = (CGSize){ roundf(imageSize.width / maxRatio), roundf(imageSize.height / maxRatio) };
    }
    
    resultFrame.origin  = (CGPoint) {roundf(self.center.x - resultFrame.size.width / 2), roundf(self.center.y - resultFrame.size.height / 2) };
    
    return resultFrame;
}

@end
