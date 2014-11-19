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


/** 
    Delegate protocol that should be implemented by any view controller wishing to use
    the URBNCarouselTransitionController. 
*/
@protocol URBNCarouselTransitioning <NSObject>

@optional
- (void)willBeginGalleryTransition;
- (void)didEndGalleryTransition;

// Called inside the animation block of a non-interactive transition.
- (void)configureAnimatingTransitionImageView:(UIImageView *)imageView;

@required
// Return the image to transition
- (UIImage *)imageForGalleryTransition;
- (CGRect)fromImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView;
- (CGRect)toImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView sourceImageFrame:(CGRect)sourceImageFrame;

@end



/** 
    Animation controller built to handle transitions between two images in separate view controllers.
    By default, this class supports non-interactive transitions. To enable interactive transitions, register
    a view for them using the registration method provided.
 
    This class implements the UIViewControllerTransitioningDelegate protocol. As a consumer, you only need to implement
    the URBNCarouselTransitioning protocol.
 
    For the time being, this controller only supports transitions between images.
 */
@interface URBNCarouselTransitionController : NSObject <UIGestureRecognizerDelegate, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate>

@property(nonatomic, readonly) BOOL interactive;  // Defaults to NO
@property(nonatomic, weak) id<URBNCarouselTransitioning> interactionDelegate;

- (void)registerInteractiveGesturesWithView:(UIView *)view interactionBeganBlock:(URBNCarouselViewInteractionBeganBlock)interactionBeganBlock;

@end
