//
//  GalleryCollectionViewCell.h
//  URBNCarousel
//
//  Created by Demetri Miller on 11/4/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GalleryCollectionViewCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, copy) void (^pinchGestureBlock)(UICollectionViewCell *cell, UIPinchGestureRecognizer *pinch);

@end
