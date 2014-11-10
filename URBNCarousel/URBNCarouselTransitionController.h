//
//  GalleryTransitionController.h
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class URBNCarouselTransitionController;

typedef void(^URBNCarouselViewInteractionBeganBlock)(URBNCarouselTransitionController *controller, UIView *view);

@protocol URBNCarouselTransitioning <NSObject>

@optional
- (void)willBeginGalleryTransition;
- (void)didEndGalleryTransition;
- (void)configureAnimatingTransitionImageView:(UIImageView *)imageView;

@required
- (UIImage *)imageForGalleryTransition;
- (CGRect)imageFrameForGalleryTransitionWithContainerView:(UIView *)containerView;

@end



@interface URBNCarouselTransitionController : NSObject <UIGestureRecognizerDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

@property(nonatomic, assign) BOOL interactive;  // Defaults to NO
@property(nonatomic, weak) id<URBNCarouselTransitioning> interactionDelegate;

- (void)registerInteractiveGesturesWithView:(UIView *)view interactionBeganBlock:(URBNCarouselViewInteractionBeganBlock)interactionBeganBlock;

@end
