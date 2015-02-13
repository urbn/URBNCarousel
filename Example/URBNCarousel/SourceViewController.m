//
//  SourceViewController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 10/30/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <URBNCarousel/URBNCarousel.h>
#import "URBNCarouselZoomableCell.h"
#import "DestinationViewController.h"
#import "SourceViewController.h"

@interface SourceViewController ()

@property(nonatomic, strong) URBNHorizontalPagedFlowLayout *inlineLayout;
@property(nonatomic, strong) URBNCarouselTransitionController *transitionController;
@property(nonatomic, assign) CGFloat startScale;
@property(nonatomic, weak) URBNCarouselZoomableCell *selectedCell;


@end


@implementation SourceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.inlineLayout = [[URBNHorizontalPagedFlowLayout alloc] init];
    _inlineLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _inlineLayout.minimumLineSpacing = 15;
    _inlineLayout.minimumInteritemSpacing = 0;
    _inlineLayout.itemSize = CGSizeMake(280, 200);
    
    self.collectionView = [[URBNScrollSyncCollectionView alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, 200) collectionViewLayout:_inlineLayout];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.view addSubview:self.collectionView];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[URBNCarouselZoomableCell class] forCellWithReuseIdentifier:@"cell"];
    
    typeof(self) __weak __self = self;
    [self.collectionView setDidSyncBlock:^(UICollectionView *collectionView, NSIndexPath *indexPath) {
        UICollectionViewLayoutAttributes *attr = [__self.inlineLayout layoutAttributesForItemAtIndexPath:indexPath];
        [__self.collectionView setContentOffset:CGPointMake(attr.frame.origin.x - __self.inlineLayout.sectionInset.left, 0) animated:NO];
        __self.selectedCell = (URBNCarouselZoomableCell *)[collectionView cellForItemAtIndexPath:indexPath];
    }];
    
    self.transitionController = [[URBNCarouselTransitionController alloc] init];
}

#pragma mark - Convenience
- (void)presentGalleryController
{
    DestinationViewController *vc = [[DestinationViewController alloc] initWithTransitionController:self.transitionController];
    vc.transitioningDelegate = self.transitionController;
    
    //  In some cases the iOS will use your rootViewController as the presenting view controller - from documentation on presenting view controllers -
    //  "When a view controller is presented, iOS searches for a presentation context. It starts at the presenting view controller by reading its definesPresentationContext property. If the value of this property is YES, then the presenting view controller defines the presentation context. Otherwise, it continues up through the view controller hierarchy until a view controller returns YES or until it reaches the window’s root view controller."
    //  iOS8 allows this property to be set on iPhone view controllers, BUT iOS7 will ignore it.  The transition controller however has a check built in to set the correct presenting view controller in the event of iOS7.
    if ([self respondsToSelector:@selector(setDefinesPresentationContext:)]) {
        self.definesPresentationContext = YES;
    }
    
    [self presentViewController:vc animated:YES completion:^{
        [self.collectionView registerForSynchronizationWithCollectionView:vc.collectionView];
    }];
}

#pragma mark - GalleryTransitioning
- (void)willBeginGalleryTransitionWithImageView:(UIImageView *)imageView isToVC:(BOOL)isToVC
{
    self.selectedCell.hidden = YES;
}

- (void)didEndGalleryTransitionWithImageView:(UIImageView *)imageView isToVC:(BOOL)isToVC
{
    self.selectedCell.hidden = NO;
}

- (UIImage *)imageForGalleryTransition
{
    return self.selectedCell.imageView.image;
}

- (CGRect)fromImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView
{
    CGRect imageFrame = [self.selectedCell.imageView urbn_imageFrame];
    return [containerView convertRect:imageFrame fromView:self.selectedCell];
}

- (CGRect)toImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView sourceImageFrame:(CGRect)sourceImageFrame
{
    CGSize size = [UIImageView urbn_aspectFitSizeForImageSize:sourceImageFrame.size inRect:self.selectedCell.imageView.frame];
    CGRect convertedRect = [containerView convertRect:self.selectedCell.frame fromView:self.collectionView];
    CGFloat originX = CGRectGetMidX(convertedRect) - (size.width / 2);
    CGFloat originY = CGRectGetMidY(convertedRect) - (size.height / 2);
    CGRect imageFrame = CGRectMake(originX, originY, size.width, size.height);
    return imageFrame;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = (URBNCarouselZoomableCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self presentGalleryController];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    URBNCarouselZoomableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"150x350"];
    
    typeof(self) __weak __self = self;
    [self.transitionController registerInteractiveGesturesWithView:cell interactionBeganBlock:^(URBNCarouselTransitionController *controller, UIView *view) {
        __self.selectedCell = (URBNCarouselZoomableCell *)cell;
        [__self presentGalleryController];
    }];
    
    return cell;
}

@end
