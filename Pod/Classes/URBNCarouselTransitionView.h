//
//  URBNCarouselTransitionView.h
//  ANT
//
//  Created by Demetri Miller on 11/6/14.
//  Copyright (c) 2014 Urban Outfitters. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface URBNCarouselTransitionView : UIView

@property(nonatomic, strong) UIImageView *imageView;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image;

@end
