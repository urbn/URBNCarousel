#import "UIImageView+ImageFrame.h"

@implementation UIImageView (ImageFrame)

+ (CGSize)aspectFitSizeForImageSize:(CGSize)imageSize inRect:(CGRect)rect
{
    CGFloat hfactor = imageSize.width / rect.size.width;
    CGFloat vfactor = imageSize.height / rect.size.height;
    
    CGFloat factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    CGFloat newWidth = imageSize.width / factor;
    CGFloat newHeight = imageSize.height / factor;
    
    return CGSizeMake(newWidth, newHeight);
}

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
