//
//  URBNScrollLinkedCollectionView.h
//  Pods
//
//  Created by Demetri Miller on 11/14/14.
//
//

#import <UIKit/UIKit.h>

/** 
    Custom subclass of UICollectionView that handles auto-scrolling itself
    when necessary.
 
    This collectionView should be used when you have two photo galleries displaying
    the same content and want the indexPaths to stay synced.
 */

typedef void(^URBNScrollSyncCollectionViewDidSyncBlock)(UICollectionView *collectionView, NSIndexPath *indexPath);

@interface URBNScrollSyncCollectionView : UICollectionView <UICollectionViewDelegate>

@property(nonatomic, assign) BOOL animateScrollSync;    // Defaults to NO

// Use this block to make modifications to content offset, or update state variables when a collectionView
// syncs itself.
@property(nonatomic, copy) URBNScrollSyncCollectionViewDidSyncBlock didSyncBlock;
- (void)setDidSyncBlock:(URBNScrollSyncCollectionViewDidSyncBlock)didSyncBlock;

- (void)registerForSynchronizationWithCollectionView:(URBNScrollSyncCollectionView *)collectionView;
- (void)unregisterForSynchronizationWithCollectionView:(URBNScrollSyncCollectionView *)collectionView;


@end
