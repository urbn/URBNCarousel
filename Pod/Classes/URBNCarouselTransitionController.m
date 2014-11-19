//
//  GalleryTransitionController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "URBNCarouselTransitionController.h"
#import "UIImageView+URBNImageFrame.h"

typedef NS_ENUM(NSUInteger, URBNCarouselTransitionState) {
    URBNCarouselTransitionStateStart,
    URBNCarouselTransitionStateEnd,
};

@interface URBNCarouselTransitionController()

@property(nonatomic, readwrite) BOOL interactive;
@property(nonatomic, strong) NSMapTable *viewInteractionBlocks;
@property(nonatomic, strong) id <UIViewControllerContextTransitioning> context;
@property(nonatomic, strong) UIImageView *transitionView;

@property(nonatomic, assign) CGRect originalSelectedCellFrame;
@property(nonatomic, assign) CGFloat startScale;
@property(nonatomic, assign) CGFloat springCompletionSpeed;
@property(nonatomic, assign) CGFloat completionSpeed;


@end



@implementation URBNCarouselTransitionController


#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        self.viewInteractionBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
        
        self.startScale = -1;
        self.springCompletionSpeed = 0.6;
        self.completionSpeed = 0.2;
        self.interactive = NO;
    }
    return self;
}


#pragma mark - Convenience
- (UIViewController<URBNCarouselTransitioning> *)trueContextViewControllerFromContext:(id <UIViewControllerContextTransitioning>)transitionContext withKey:(NSString *)key
{
    UIViewController<URBNCarouselTransitioning> *vc = (UIViewController<URBNCarouselTransitioning> *)[transitionContext viewControllerForKey:key];
    if ([vc isKindOfClass:[UINavigationController class]]) {
        vc = (UIViewController<URBNCarouselTransitioning> *)[((UINavigationController *)vc) topViewController];
    }
    return vc;
}

- (CGFloat)transitionViewPercentScaledForStartScale:(CGFloat)startScale
{
    CGSize scale = [self scaleForTransform:self.transitionView.transform];
    CGFloat percent = ((scale.width - self.startScale) / (1 - self.startScale));
    return percent;
}


#pragma mark - Transition Setup/Teardown
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
    
    // Create a view for our animation
    UIImage *image = [topFromVC imageForGalleryTransition];
    CGRect convertedStartingFrame = [topFromVC fromImageFrameForGalleryTransitionWithContainerView:containerView];
    CGRect convertedEndingFrame = [topToVC toImageFrameForGalleryTransitionWithContainerView:containerView sourceImageFrame:convertedStartingFrame];
    
    // Set the view's frame to the final dimensions and transform it down to match starting dimensions.
    self.transitionView = [[UIImageView alloc] initWithFrame:convertedEndingFrame];
    self.transitionView.contentMode = UIViewContentModeScaleToFill;
    self.transitionView.image = image;
    
    CGFloat scaleX = convertedStartingFrame.size.width / convertedEndingFrame.size.width;
    CGFloat scaleY = convertedStartingFrame.size.height / convertedEndingFrame.size.height;
    CGAffineTransform t = CGAffineTransformMakeScale(scaleX, scaleY);
    self.transitionView.transform = t;
    self.transitionView.center = CGPointMake(CGRectGetMidX(convertedStartingFrame), CGRectGetMidY(convertedStartingFrame));
    
    // Add the toView to the container
    [containerView addSubview:toView];
    [containerView addSubview:fromView];
    [containerView addSubview:self.transitionView];
}

- (void)restoreTransitionViewToState:(URBNCarouselTransitionState)state withContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    
    UIViewController<URBNCarouselTransitioning> *topFromVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextFromViewControllerKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];
    
    CGRect convertedStartingFrame = [topFromVC fromImageFrameForGalleryTransitionWithContainerView:containerView];
    CGRect convertedEndingFrame = [topToVC toImageFrameForGalleryTransitionWithContainerView:containerView sourceImageFrame:convertedStartingFrame];
    
    CGPoint center;
    CGAffineTransform t;
    if (state == URBNCarouselTransitionStateStart) {
        CGFloat scaleX = convertedStartingFrame.size.width / convertedEndingFrame.size.width;
        CGFloat scaleY = convertedStartingFrame.size.height / convertedEndingFrame.size.height;
        t = CGAffineTransformMakeScale(scaleX, scaleY);
        center = CGPointMake(CGRectGetMidX(convertedStartingFrame), CGRectGetMidY(convertedStartingFrame));
    } else {
        t = CGAffineTransformIdentity;
        center = CGPointMake(CGRectGetMidX(convertedEndingFrame), CGRectGetMidY(convertedEndingFrame));
    }
    
    self.transitionView.center = center;
    self.transitionView.transform = t;
}

- (void)finishInteractiveTransition:(BOOL)cancelled withVelocity:(CGFloat)velocity
{
    UIView *toView = [self.context viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [self.context viewForKey:UITransitionContextFromViewKey];
    
    [UIView animateWithDuration:self.springCompletionSpeed delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:velocity options:0 animations:^{
        URBNCarouselTransitionState state = cancelled ? URBNCarouselTransitionStateStart : URBNCarouselTransitionStateEnd;
        [self restoreTransitionViewToState:state withContext:self.context];
        
    } completion:^(BOOL finished) {
        [self finishTransitionWithContext:self.context];
        [self.context cancelInteractiveTransition];
        [self.context completeTransition:!cancelled];
    }];
    
    [UIView animateWithDuration:self.completionSpeed animations:^{
        toView.alpha = cancelled ? 0.0 : 1.0;
        fromView.alpha = cancelled ? 1.0 : 0.0;
    } completion:nil];
}

- (void)finishTransitionWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIViewController<URBNCarouselTransitioning> *topFromVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextFromViewControllerKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];
    
    [self.transitionView removeFromSuperview];
    self.transitionView = nil;
    self.startScale = -1;
    
    fromView.alpha = 1.0;
    toView.alpha = 1.0;
    
    if ([topFromVC respondsToSelector:@selector(didEndGalleryTransition)]) {
        [topFromVC didEndGalleryTransition];
    }
    
    if ([topToVC respondsToSelector:@selector(didEndGalleryTransition)]) {
        [topToVC didEndGalleryTransition];
    }
    
    fromVC.view = fromView;
    toVC.view = toView;
    self.interactive = NO;
}



#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];

    [self prepareForTransitionWithContext:transitionContext];
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
        
        fromView.alpha = 0.0;
        toView.alpha = 1.0;
        [self restoreTransitionViewToState:URBNCarouselTransitionStateEnd withContext:transitionContext];
        
        if ([topToVC respondsToSelector:@selector(configureAnimatingTransitionImageView:)]) {
            [topToVC configureAnimatingTransitionImageView:self.transitionView];
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
    UIView *fromView = [self.context viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [self.context viewForKey:UITransitionContextToViewKey];

    fromView.alpha = (1.0 - percent);
    toView.alpha = percent;
}


#pragma mark - Gesture Handling
- (void)registerInteractiveGesturesWithView:(UIView *)view interactionBeganBlock:(URBNCarouselViewInteractionBeganBlock)interactionBeganBlock
{
    NSAssert(interactionBeganBlock, @"Cannot register view without interactionBeganBlock. Block is needed by VC to kick of transition by modifying VC stack.");
    
    for (UIGestureRecognizer *g in view.gestureRecognizers) {
        [view removeGestureRecognizer:g];
    }
    
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

- (CGSize)scaleForTransform:(CGAffineTransform)t
{
    // Square root of the sum of the squares
    CGFloat xScale = sqrt(t.a * t.a + t.c * t.c);
    CGFloat yScale = sqrt(t.b * t.b + t.d * t.d);
    return CGSizeMake(xScale, yScale);
}

- (void)handlePinch:(UIPinchGestureRecognizer *)pinch
{
    CGFloat scale = pinch.scale;
    switch (pinch.state) {
        case UIGestureRecognizerStateBegan: {
            URBNCarouselViewInteractionBeganBlock block = [self.viewInteractionBlocks objectForKey:pinch.view];
            if (block) {
                block(self, pinch.view);
            }

            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (self.startScale < 0) {
                self.startScale = [self scaleForTransform:self.transitionView.transform].width;
            }
            self.transitionView.transform = CGAffineTransformScale(self.transitionView.transform, scale, scale);
            
            CGFloat percent = [self transitionViewPercentScaledForStartScale:self.startScale];
            pinch.scale = 1;
            [self updateWithPercent:percent];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGFloat percent = [self transitionViewPercentScaledForStartScale:self.startScale];

            BOOL cancelled = (percent < 0.4);
            [self finishInteractiveTransition:cancelled withVelocity:pinch.velocity];
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
    UIPinchGestureRecognizer *pinch;
    for (UIGestureRecognizer *g in gestureRecognizer.view.gestureRecognizers) {
        if ([g isKindOfClass:[UIPinchGestureRecognizer class]]) {
            pinch = (UIPinchGestureRecognizer *)g;
            break;
        }
    }
    
    BOOL pinchStarted = (pinch.state != UIGestureRecognizerStatePossible || (gestureRecognizer == pinch));

    if (pinchStarted) {
        self.interactive = YES;
    }

    return pinchStarted;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return ![otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return (self.interactive) ? self : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return (self.interactive) ? self : nil;
}




@end
