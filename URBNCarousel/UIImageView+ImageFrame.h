#import <UIKit/UIKit.h>

@interface UIImageView (ImageFrame)

// Returns the bounding box size for the imageSize passed if the image were to
// be placed in rect.
+ (CGSize)aspectFitSizeForImageSize:(CGSize)imageSize inRect:(CGRect)rect;

// Returns the actual frame for the image inside the image view (assumes aspect fit).
- (CGRect)imageFrame;

@end
