//
//  SourceViewController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 10/30/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "ANTGuidedScrollFlowLayout.h"
#import "GalleryCollectionViewCell.h"
#import "URBNCarouselTransitionController.h"
#import "DestinationViewController.h"
#import "SourceViewController.h"
#import "UIImageView+ImageFrame.h"

@interface SourceViewController ()

@property(nonatomic, strong) ANTGuidedScrollFlowLayout *inlineLayout;
@property(nonatomic, strong) UICollectionViewFlowLayout *fullSizeLayout;
@property(nonatomic, strong) URBNCarouselTransitionController *transitionController;
@property(nonatomic, assign) CGFloat startScale;
@property(nonatomic, weak) GalleryCollectionViewCell *selectedCell;


@end


@implementation SourceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fullSizeLayout = [[UICollectionViewFlowLayout alloc] init];
    _fullSizeLayout.itemSize = CGSizeMake(320, 500);
    _fullSizeLayout.minimumInteritemSpacing = 10;
    _fullSizeLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.inlineLayout = [[ANTGuidedScrollFlowLayout alloc] init];
    _inlineLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _inlineLayout.minimumLineSpacing = 15;
    _inlineLayout.minimumInteritemSpacing = 0;
    _inlineLayout.itemSize = CGSizeMake(280, 200);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 200) collectionViewLayout:_inlineLayout];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.collectionView];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[GalleryCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    
    self.transitionController = [[URBNCarouselTransitionController alloc] init];
}


#pragma mark - Convenience
- (void)presentGalleryController
{
    DestinationViewController *vc = [[DestinationViewController alloc] initWithTransitionController:self.transitionController];
    vc.transitioningDelegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - GalleryTransitioning
- (void)willBeginGalleryTransition
{
    self.selectedCell.hidden = YES;
}

- (void)didEndGalleryTransition
{
    self.selectedCell.hidden = NO;
}

- (UIImage *)imageForGalleryTransition
{
    return self.selectedCell.imageView.image;
}

- (CGRect)imageFrameForGalleryTransitionWithContainerView:(UIView *)containerView
{
    CGRect imageFrame = [self.selectedCell.imageView imageFrame];
    return [containerView convertRect:imageFrame fromView:self.selectedCell];
}


#pragma mark - UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.transitionController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.transitionController;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return (self.transitionController.interactive) ? self.transitionController : nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator
{
    return (self.transitionController.interactive) ? self.transitionController : nil;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = (GalleryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self presentGalleryController];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GalleryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"150x350"];
    
//    typeof(self) __weak __self = self;
//    [self.transitionController registerInteractiveGesturesWithView:cell interactionBeganBlock:^(URBNCarouselTransitionController *controller, UIView *view) {
//        __self.selectedCell = (GalleryCollectionViewCell *)cell;
//        [__self presentGalleryController];
//    }];
    
    return cell;
}

@end
