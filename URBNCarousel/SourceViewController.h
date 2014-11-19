//
//  SourceViewController.h
//  URBNCarousel
//
//  Created by Demetri Miller on 10/30/14.
//  Copyright (c) 2014 Demetri Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "URBNCarouselTransitionController.h"

@interface SourceViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, URBNCarouselTransitioning>

@property(nonatomic, strong) UICollectionView *collectionView;

@end

