#import <UIKit/UIKit.h>

@interface UIImageView (ImageFrame)

+ (CGSize)aspectFitSizeForImageSize:(CGSize)imageSize inRect:(CGRect)rect;
- (CGRect)imageFrame;

@end
