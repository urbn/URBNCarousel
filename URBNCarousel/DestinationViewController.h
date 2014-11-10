//
//  FullGalleryViewController.h
//  URBNCarousel
//
//  Created by Demetri Miller on 11/3/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URBNCarouselTransitionController.h"


@interface DestinationViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, URBNCarouselTransitioning>

@property(nonatomic, strong) UICollectionView *collectionView;

- (id)initWithTransitionController:(URBNCarouselTransitionController *)controller;

@end
