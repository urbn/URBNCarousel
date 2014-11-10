//
//  URBNCarouselTransitionView.m
//  ANT
//
//  Created by Demetri Miller on 11/6/14.
//  Copyright (c) 2014 Urban Outfitters. All rights reserved.
//

#import "URBNCarouselTransitionView.h"


@implementation URBNCarouselTransitionView

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.image = image;
        self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.imageView.layer.borderWidth = 2.0;
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    // The border should be sitting behind the imageView
    CGSize aspectFitSize = [self aspectFitSizeForImage:self.imageView.image inRect:frame];
    self.imageView.bounds = CGRectMake(0, 0, aspectFitSize.width, aspectFitSize.height);
    self.imageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
}

- (CGSize)aspectFitSizeForImage:(UIImage *)image inRect:(CGRect)rect
{
    CGFloat hfactor = image.size.width / rect.size.width;
    CGFloat vfactor = image.size.height / rect.size.height;
    
    CGFloat factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the vertical or horizontal shrinkage factor
    CGFloat newWidth = image.size.width / factor;
    CGFloat newHeight = image.size.height / factor;
    
    return CGSizeMake(newWidth, newHeight);
}


@end
