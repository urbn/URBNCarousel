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
@property(nonatomic, strong) NSMapTable *viewPinchTransitionGestureRecognizers;
@property(nonatomic, weak) id <UIViewControllerContextTransitioning> context;
@property(nonatomic, strong) UIImageView *transitionView;

@property(nonatomic, assign) CGRect originalSelectedCellFrame;
@property(nonatomic, assign) CGFloat startScale;
@property(nonatomic, assign) CGFloat springCompletionSpeed;
@property(nonatomic, assign) CGFloat completionSpeed;
@property(nonatomic, strong) UIViewController *sourceViewController;

@end



@implementation URBNCarouselTransitionController


#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self) {
        self.viewInteractionBlocks = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsCopyIn capacity:10];
        self.viewPinchTransitionGestureRecognizers = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory capacity:10];
        
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
    
    // Unless the view controller who called presentViewController sets definePresentationContext = YES; (on iPhone, +iOS8 , the vc will be the rootViewController, who will not conform to the URBNTransitioning protocol.  In this case the trueContextViewController should be the source set by animationControllerForPresentedController.
    if (![vc conformsToProtocol:@protocol(URBNCarouselTransitioning)]) {
        vc = (UIViewController<URBNCarouselTransitioning> *)self.sourceViewController;
    }
    
    // Here we're using topViewController directly to account for really custom transitions.
    // If you have an un-traditional viewController stack then your custom containerVC can override this
    // method to supply the topViewController
    if ([vc respondsToSelector:@selector(topViewController)]) {
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
    
    if ([topFromVC respondsToSelector:@selector(willBeginGalleryTransitionWithImageView:isToVC:)]) {
        [topFromVC willBeginGalleryTransitionWithImageView:self.transitionView isToVC:NO];
    }
    
    if ([topToVC respondsToSelector:@selector(willBeginGalleryTransitionWithImageView:isToVC:)]) {
        [topToVC willBeginGalleryTransitionWithImageView:self.transitionView isToVC:YES];
    }
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
    UIViewController *fromVC = [self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
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
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    UIViewController<URBNCarouselTransitioning> *topFromVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextFromViewControllerKey];
    UIViewController<URBNCarouselTransitioning> *topToVC = [self trueContextViewControllerFromContext:transitionContext withKey:UITransitionContextToViewControllerKey];
    
    if ([topFromVC respondsToSelector:@selector(didEndGalleryTransitionWithImageView:isToVC:)]) {
        [topFromVC didEndGalleryTransitionWithImageView:self.transitionView isToVC:NO];
    }
    
    if ([topToVC respondsToSelector:@selector(didEndGalleryTransitionWithImageView:isToVC:)]) {
        [topToVC didEndGalleryTransitionWithImageView:self.transitionView isToVC:YES];
    }
    
    [self.transitionView removeFromSuperview];
    self.transitionView = nil;
    self.startScale = -1;
    
    fromView.alpha = 1.0;
    toView.alpha = 1.0;
    
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
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
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
    UIViewController *fromVC = [self.context viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;

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
    [self.viewPinchTransitionGestureRecognizers setObject:pinch forKey:view];
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
    UIPinchGestureRecognizer *pinch = [self.viewPinchTransitionGestureRecognizers objectForKey:gestureRecognizer.view];
    BOOL pinchStarted = (pinch.state != UIGestureRecognizerStatePossible);
    BOOL isPinch = (gestureRecognizer == pinch);

    BOOL shouldBeginTransition = YES;
    if (isPinch && !pinchStarted && self.interactiveDelegate && [self.interactiveDelegate respondsToSelector:@selector(shouldBeginInteractiveTransitionWithView:direction:)]) {
        CGFloat scale = pinch.scale;
        NSAssert(scale != 1, @"Scale shouldn't be equal to one for the current logic to work");
        URBNCarouselTransitionInteractiveDirection direction = (scale > 1) ? URBNCarouselTransitionInteractiveDirectionScaleUp : URBNCarouselTransitionInteractiveDirectionScaleDown;
        shouldBeginTransition = [self.interactiveDelegate shouldBeginInteractiveTransitionWithView:gestureRecognizer.view direction:direction];
    }
    
    if (isPinch && !pinchStarted && shouldBeginTransition) {
        self.interactive = YES;
    }

    BOOL shouldBegin = (shouldBeginTransition || (!isPinch && pinchStarted));
    return shouldBegin;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    // In iOS7 the default presentingSourceViewController is the rootViewController, while the source VC, the one we actually want as the fromVC, is the source (who calls the presentViewController method)
    self.sourceViewController = source;
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
