//
//  DestinationViewController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "GalleryCollectionViewCell.h"
#import "DestinationViewController.h"
#import "UIImageView+ImageFrame.h"

@interface DestinationViewController ()
@property(nonatomic, strong) URBNCarouselTransitionController *transitionController;
@property(nonatomic, weak) GalleryCollectionViewCell *selectedCell;
@end

@implementation DestinationViewController

- (id)initWithTransitionController:(URBNCarouselTransitionController *)controller
{
    self = [super init];
    if (self) {
        self.transitionController = controller;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.view.frame.size;
    layout.minimumInteritemSpacing = 10;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[GalleryCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}


#pragma mark - GalleryTransitioning
- (void)willBeginGalleryTransition
{
    if (self.selectedCell) {
        self.selectedCell.hidden = YES;
    } else {
        self.collectionView.hidden = YES;
    }
}

- (void)didEndGalleryTransition
{
    if (self.selectedCell) {
        self.selectedCell.hidden = NO;
    } else {
        self.collectionView.hidden = NO;
    }
}

- (UIImage *)imageForGalleryTransition
{
    return self.selectedCell.imageView.image;
}

- (CGRect)fromImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView
{
    NSAssert(self.selectedCell, @"Cell should be selected for \"from\" transition");
    CGSize size = [UIImageView aspectFitSizeForImageSize:self.selectedCell.imageView.image.size inRect:self.selectedCell.frame];

    CGFloat originX = CGRectGetMidX(self.view.bounds) - (size.width / 2);
    CGFloat originY = CGRectGetMidY(self.view.bounds) - (size.height / 2);
    CGRect frame = CGRectMake(originX, originY, size.width, size.height);
    return [containerView convertRect:frame fromView:self.collectionView];
}

- (CGRect)toImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView sourceImageFrame:(CGRect)sourceImageFrame
{
    CGSize size = [UIImageView aspectFitSizeForImageSize:sourceImageFrame.size inRect:self.view.bounds];
    CGFloat originX = CGRectGetMidX(self.view.bounds) - (size.width / 2);
    CGFloat originY = CGRectGetMidY(self.view.bounds) - (size.height / 2);
    CGRect frame = CGRectMake(originX, originY, size.width, size.height);
    return frame;
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCell = (GalleryCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self dismissViewControllerAnimated:YES completion:nil];
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

    typeof(self) __weak __self = self;
    [self.transitionController registerInteractiveGesturesWithView:cell interactionBeganBlock:^(URBNCarouselTransitionController *controller, UIView *view) {
        __self.selectedCell = (GalleryCollectionViewCell *)cell;
        [__self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    return cell;
}

@end
