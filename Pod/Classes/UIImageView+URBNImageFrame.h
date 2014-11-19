#import <UIKit/UIKit.h>

@interface UIImageView (URBNImageFrame)

+ (CGSize)urbn_aspectFitSizeForImageSize:(CGSize)imageSize inRect:(CGRect)rect;
- (CGRect)urbn_imageFrame;

@end
