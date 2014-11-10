//
//  GalleryTransitionController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "URBNCarouselTransitionController.h"
#import "URBNCarouselTransitionView.h"
#import "UIImageView+ImageFrame.h"

@interface URBNCarouselTransitionController()

@property(nonatomic, strong) NSMapTable *viewInteractionBlocks;
@property(nonatomic, strong) id <UIViewControllerContextTransitioning> context;
@property(nonatomic, strong) URBNCarouselTransitionView *transitionView;

@property(nonatomic, assign) CGRect originalSelectedCellFrame;
@property(nonatomic, assign) CGFloat startScale;
@property(nonatomic, assign) CGFloat completionSpeed;

@end



@implementation URBNCarouselTransitionController

- (id)init
{
    self = [super init];
    if (self) {
        self.viewInteractionBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
        
        self.completionSpeed = 3.2;
        self.interactive = NO;
    }
    return self;
}

#pragma mark - Convenience
- (URBNCarouselTransitionView *)configuredTransitionImageViewWithFrame:(CGRect)frame image:(UIImage *)image
{
    URBNCarouselTransitionView *view = [[URBNCarouselTransitionView alloc] initWithFrame:frame image:image];
    return view;
}

- (void)prepareForTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];

    UIViewController<URBNCarouselTransitioning> *topFromVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextFromViewControllerKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];
    
    
    NSAssert([topFromVC conformsToProtocol:@protocol(URBNCarouselTransitioning)], @"GalleryTransitionController -- fromVC doesn't conform to protocol");
    NSAssert([topToVC conformsToProtocol:@protocol(URBNCarouselTransitioning)], @"GalleryTransitionController -- toVC doesn't conform to protocol");
    
    if ([topFromVC respondsToSelector:@selector(willBeginGalleryTransition)]) {
        [topFromVC willBeginGalleryTransition];
    }
    
    if ([topToVC respondsToSelector:@selector(willBeginGalleryTransition)]) {
        [topToVC willBeginGalleryTransition];
    }
    
    // Create an imageView that will act as our animation
    CGRect convertedStartingFrame = [topFromVC imageFrameForGalleryTransitionWithContainerView:containerView];
    UIImage *image = [topFromVC imageForGalleryTransition];
    self.transitionView = [self configuredTransitionImageViewWithFrame:convertedStartingFrame image:image];
    
    // Add the toView to the container
    [containerView addSubview:toView];
    [containerView addSubview:fromView];
    [containerView addSubview:self.transitionView];
}

- (void)finishTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    
    UIViewController<URBNCarouselTransitioning> *topFromVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextFromViewControllerKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];

    [self.transitionView removeFromSuperview];
    self.transitionView = nil;
    
    fromView.alpha = 1.0;
    toView.alpha = 1.0;
    
    if ([topFromVC respondsToSelector:@selector(didEndGalleryTransition)]) {
        [topFromVC didEndGalleryTransition];
    }
    
    if ([topToVC respondsToSelector:@selector(didEndGalleryTransition)]) {
        [topToVC didEndGalleryTransition];
    }
    
    self.interactive = NO;
}

- (UIViewController<URBNCarouselTransitioning> *)trueContextViewControllerFromContext:(id <UIViewControllerContextTransitioning>)transitionContext withKey:(NSString *)key
{
    UIViewController<URBNCarouselTransitioning> *vc = (UIViewController<URBNCarouselTransitioning> *)[transitionContext viewControllerForKey:key];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = (UIViewController<URBNCarouselTransitioning> *)[((UINavigationController *)vc) topViewController];
    }
    return vc;
}


#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.7;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;
    UIView *containerView = [transitionContext containerView];
    
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];
    
    [self prepareForTransitionWithContext:transitionContext];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        
        fromView.alpha = 0.0;
        toView.alpha = 1.0;
        self.transitionView.frame = [topToVC imageFrameForGalleryTransitionWithContainerView:containerView];
        
        if ([topToVC respondsToSelector:@selector(configureAnimatingTransitionImageView:)]) {
            [topToVC configureAnimatingTransitionImageView:self.transitionView.imageView];
        }
        
    } completion:^(BOOL finished) {
        [self finishTransitionWithContext:transitionContext];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}


#pragma mark - UIViewControllerInteractiveTransitioning
- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    [self prepareForTransitionWithContext:transitionContext];
}

- (void)updateWithPercent:(CGFloat)percent
{
    [self.context updateInteractiveTransition:percent];
}

- (void)end:(BOOL)cancelled
{
    UIViewController<URBNCarouselTransitioning> *toVC = [self trueContextViewControllerFromContext:self.context withKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [self.context containerView];
    
    if (cancelled) {
        [UIView animateWithDuration:self.completionSpeed animations:^{
            self.transitionView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self finishTransitionWithContext:self.context];
            [self.context cancelInteractiveTransition];
            [self.context completeTransition:NO];
        }];
    } else {
        [UIView animateWithDuration:self.completionSpeed animations:^{
            self.transitionView.transform = CGAffineTransformIdentity;
            self.transitionView.frame = [toVC imageFrameForGalleryTransitionWithContainerView:containerView];
            
        } completion:^(BOOL finished) {
            [self finishTransitionWithContext:self.context];
            [self.context finishInteractiveTransition];
            [self.context completeTransition:YES];
        }];
    }
}


#pragma mark - Gesture Handling
- (void)registerInteractiveGesturesWithView:(UIView *)view interactionBeganBlock:(URBNCarouselViewInteractionBeganBlock)interactionBeganBlock
{
    NSAssert(interactionBeganBlock, @"Cannot register view with interactionBeganBlock. Block is needed by VC to kick of transition by modifying VC stack.");
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [view addGestureRecognizer:pan];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    pinch.delegate = self;
    [view addGestureRecognizer:pinch];
    
    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    rotate.delegate = self;
    [view addGestureRecognizer:rotate];
    
    [self.viewInteractionBlocks setObject:interactionBeganBlock forKey:view];
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    CGFloat scale = pinch.scale;
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan: {
            self.startScale = scale;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat percent = (1.0 - scale/self.startScale);
            self.transitionView.transform = CGAffineTransformScale(self.transitionView.transform, scale, scale);
            pinch.scale = 1;
            [self updateWithPercent:(percent < 0.0) ? 0.0 : percent];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            BOOL cancelled = (scale < 1.5);
            [self end:cancelled];
            break;
        }
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    if (!self.context) {
        return;
    }
    UIView *containerView = [self.context containerView];
    CGPoint translation = [pan translationInView:containerView];
    self.transitionView.center = CGPointMake(self.transitionView.center.x + translation.x, self.transitionView.center.y + translation.y);
    [pan setTranslation:CGPointZero inView:containerView];
}

- (void)handleRotation:(UIRotationGestureRecognizer *)rotate
{
    if (!self.context) {
        return;
    }
    
    CGFloat rotation = rotate.rotation;
    self.transitionView.transform = CGAffineTransformRotate(self.transitionView.transform, rotation);
    rotate.rotation = 0;
    
}


#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    self.interactive = YES;
    URBNCarouselViewInteractionBeganBlock block = [self.viewInteractionBlocks objectForKey:gestureRecognizer.view];
    if (block) {
        block(self, gestureRecognizer.view);
    }

    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}



@end
