//
//  DestinationViewController.m
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <URBNCarousel/URBNCarousel.h>
#import "URBNCarouselZoomableCell.h"
#import "DestinationViewController.h"


@interface DestinationViewController ()
@property(nonatomic, strong) URBNCarouselTransitionController *transitionController;
@property(nonatomic, weak) URBNCarouselZoomableCell *selectedCell;
@end

@implementation DestinationViewController

- (id)initWithTransitionController:(URBNCarouselTransitionController *)controller
{
    self = [super init];
    if (self) {
        self.transitionController = controller;
        self.transitionController.interactiveDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.view.frame.size;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[URBNScrollSyncCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.collectionView.pagingEnabled = YES;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[URBNCarouselZoomableCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(self.view.frame.size.width - 70, 20, 50, 30);
    [closeButton setTitle:@"close" forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeButton];
}

- (void)dealloc {
    NSLog( @"%p: %s (%d)",self, __PRETTY_FUNCTION__, __LINE__);
}

- (void)closeButtonTapped
{
    self.selectedCell = (URBNCarouselZoomableCell *)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathsForVisibleItems][0]];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - URBNCarouselInteractiveDelegate
- (BOOL)shouldBeginInteractiveTransitionWithView:(UIView *)view direction:(URBNCarouselTransitionInteractiveDirection)direction
{
    URBNCarouselZoomableCell *cell = (URBNCarouselZoomableCell *)view;
    if (cell.scrollView.zoomScale <= 1 && direction == URBNCarouselTransitionInteractiveDirectionScaleDown) {
        return YES;
    } else {
        return NO;
    }
}


#pragma mark - URBNCarouselTransitioning
- (void)willBeginGalleryTransitionWithImageView:(UIImageView *)imageView isToVC:(BOOL)isToVC
{
    if (self.selectedCell) {
        self.selectedCell.hidden = YES;
    } else {
        self.collectionView.hidden = YES;
    }
}

- (void)didEndGalleryTransitionWithImageView:(UIImageView *)imageView isToVC:(BOOL)isToVC
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
    CGSize size = [UIImageView urbn_aspectFitSizeForImageSize:self.selectedCell.imageView.image.size inRect:self.selectedCell.frame];

    CGFloat originX = CGRectGetMidX(self.selectedCell.frame) - (size.width / 2);
    CGFloat originY = CGRectGetMidY(self.selectedCell.frame) - (size.height / 2);
    CGRect frame = CGRectMake(originX, originY, size.width, size.height);
    frame = [containerView convertRect:frame fromView:self.collectionView];
    return frame;
}

- (CGRect)toImageFrameForGalleryTransitionWithContainerView:(UIView *)containerView sourceImageFrame:(CGRect)sourceImageFrame
{
    CGSize size = [UIImageView urbn_aspectFitSizeForImageSize:sourceImageFrame.size inRect:self.view.bounds];
    CGFloat originX = CGRectGetMidX(self.view.bounds) - (size.width / 2);
    CGFloat originY = CGRectGetMidY(self.view.bounds) - (size.height / 2);
    CGRect frame = CGRectMake(originX, originY, size.width, size.height);
    return frame;
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
    cell.scrollView.userInteractionEnabled = YES;
    
    typeof(self) __weak __self = self;
    [self.transitionController registerInteractiveGesturesWithView:cell interactionBeganBlock:^(URBNCarouselTransitionController *controller, UIView *view) {
        __self.selectedCell = (URBNCarouselZoomableCell *)cell;
        [__self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    return cell;
}

@end
