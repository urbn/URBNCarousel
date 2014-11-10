//
//  DestinationViewController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import "GalleryCollectionViewCell.h"
#import "DestinationViewController.h"


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

- (CGRect)imageFrameForGalleryTransitionWithContainerView:(UIView *)containerView
{
    CGRect frame;
    if (self.selectedCell) {
        frame = [containerView convertRect:self.selectedCell.frame fromView:self.collectionView];
    } else {
        frame = [containerView convertRect:self.view.bounds fromView:self.view];
    }
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
//    [self.transitionController registerInteractiveGesturesWithView:cell interactionBeganBlock:^(GalleryTransitionController *controller, UIView *view) {
//        __self.selectedCell = (GalleryCollectionViewCell *)cell;
//        [__self dismissViewControllerAnimated:YES completion:nil];
//    }];
    
    return cell;
}

@end
