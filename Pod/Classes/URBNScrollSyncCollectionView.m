//
//  URBNScrollLinkedCollectionView.m
//  Pods
//
//  Created by Demetri Miller on 11/14/14.
//
//

#import "URBNScrollSyncCollectionView.h"

const struct URBNScrollSyncCollectionViewIndexChangedNotification {
    __unsafe_unretained NSString * name;
    __unsafe_unretained NSString * indexPathKey;
} URBNScrollSyncCollectionViewIndexChangedNotification;


const struct URBNScrollSyncCollectionViewIndexChangedNotification URBNScrollSyncCollectionViewIndexChangedNotification = {
    .name = @"URBNScrollSyncCollectionViewIndexChangedNotification",
    .indexPathKey = @"indexPathKey"
};

@interface URBNScrollSyncCollectionView()
@property(nonatomic, weak) id<UICollectionViewDelegate> passThroughDelegate;
@end



@implementation URBNScrollSyncCollectionView

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self sharedInit];
}

- (void)sharedInit
{
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"Cannot use URBNScrollSyncCollectionView with non flow layout");
    self.animateScrollSync = NO;
    self.delegate = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.passThroughDelegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.passThroughDelegate;
}


#pragma mark - Notifications
- (void)registerForSynchronizationWithCollectionView:(URBNScrollSyncCollectionView *)collectionView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncIndexPathChanged:) name:URBNScrollSyncCollectionViewIndexChangedNotification.name object:collectionView];
}

- (void)unregisterForSynchronizationWithCollectionView:(URBNScrollSyncCollectionView *)collectionView
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:URBNScrollSyncCollectionViewIndexChangedNotification.name object:collectionView];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

#pragma mark - Scroll Sync
- (void)syncIndexPathChanged:(NSNotification *)note
{
    NSIndexPath *indexPath = note.userInfo[URBNScrollSyncCollectionViewIndexChangedNotification.indexPathKey];

    // Call scroll to get the collection view to load the proper cells
    [self scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    [self reloadItemsAtIndexPaths:@[indexPath]];

    if (self.didSyncBlock) {
        self.didSyncBlock(self, indexPath);
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *path = [self indexPathForItemAtPoint:self.contentOffset];
    if (path) {
        NSDictionary *userInfo = @{URBNScrollSyncCollectionViewIndexChangedNotification.indexPathKey : path};
        [[NSNotificationCenter defaultCenter] postNotificationName:URBNScrollSyncCollectionViewIndexChangedNotification.name object:self userInfo:userInfo];
    }
}

@end
