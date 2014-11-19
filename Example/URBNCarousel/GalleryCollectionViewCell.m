//
//  GalleryCollectionViewCell.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/4/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "GalleryCollectionViewCell.h"

@implementation GalleryCollectionViewCell
{
    UIPinchGestureRecognizer *_pinchGesture;
}

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.borderColor = [UIColor redColor].CGColor;
        _imageView.layer.borderWidth = 2.0;
        [self.contentView addSubview:_imageView];
        
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 2.0;

    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.contentView.frame = self.bounds;
}


@end
