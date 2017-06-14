//
//  GalleryCollectionViewCell.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/4/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "URBNCarouselZoomableCell.h"

@implementation URBNCarouselZoomableCell


#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.userInteractionEnabled = NO;
        _scrollView.maximumZoomScale = 2.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.zoomScale = 1.0;
        _scrollView.delegate = self;
        [self.contentView addSubview:_scrollView];
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.scrollView addSubview:_imageView];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self.scrollView addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

#pragma mark - Layout
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.scrollView setZoomScale:1.0 animated:YES];
    self.contentView.frame = self.bounds;
    self.scrollView.frame = self.contentView.bounds;
    self.imageView.frame = self.contentView.bounds;
    self.scrollView.contentSize = self.imageView.bounds.size;
}

#pragma mark - Gestures
- (void)handleDoubleTap:(UIGestureRecognizer *)gr {
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else {
        CGPoint point = [gr locationInView:self.scrollView];
        CGPoint contentOffset = CGPointMake(point.x - (self.scrollView.frame.size.width / 2), point.y - (self.scrollView.frame.size.height / 2));
        
        [UIView animateWithDuration:0.4 animations:^{
            [self.scrollView setContentOffset:contentOffset];
            [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:NO];
        }];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    // Center the view at the end of scrolling
    [UIView animateWithDuration:0.2 animations:^{
        view.center = CGPointMake(scrollView.bounds.size.width/2 * scale, scrollView.bounds.size.height/2 * scale);
    }];
}

@end
