//
//  ANTGuidedScrollFlowLayout.m
//  ANT
//
//  Created by Demeti Miller on 11/5/14.
//  Copyright (c) 2014 Urban Outfitters. All rights reserved.
//

#import "URBNHorizontalPagedFlowLayout.h"

@interface URBNHorizontalPagedFlowLayout ()

@end

@implementation URBNHorizontalPagedFlowLayout

// Modified from: http://stackoverflow.com/questions/13492037/targetcontentoffsetforproposedcontentoffsetwithscrollingvelocity-without-subcla
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGFloat offSetAdjustment = MAXFLOAT;
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray *array = [self layoutAttributesForElementsInRect:targetRect];
    for (UICollectionViewLayoutAttributes *layoutAttributes in array)
    {
        if(layoutAttributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            CGFloat itemOriginX = layoutAttributes.frame.origin.x;
            if (ABS(itemOriginX - proposedContentOffset.x) < ABS(offSetAdjustment))
            {
                offSetAdjustment = itemOriginX - proposedContentOffset.x;
            }
        }
    }
    
    CGFloat nextOffset = proposedContentOffset.x + offSetAdjustment - self.sectionInset.left;
    
    do {
        proposedContentOffset.x = nextOffset;
        CGFloat deltaX = proposedContentOffset.x - self.collectionView.contentOffset.x;
        CGFloat velX = velocity.x;
        
        if(deltaX == 0.0 || velX == 0 || (velX > 0.0 && deltaX > 0.0) || (velX < 0.0 && deltaX < 0.0))
        {
            break;
        }
        
        if(velocity.x > 0.0)
        {
            nextOffset += [self snapStep];
        }
        else if(velocity.x < 0.0)
        {
            nextOffset -= [self snapStep];
        }
    } while ([self isValidOffset:nextOffset]);
    
    proposedContentOffset.y = 0.0;
    
    return proposedContentOffset;
}

- (BOOL)isValidOffset:(CGFloat)offset
{
    return (offset >= [self minContentOffset] && offset <= [self maxContentOffset]);
}

- (CGFloat)minContentOffset
{
    return -self.collectionView.contentInset.left;
}

- (CGFloat)maxContentOffset
{
    return [self minContentOffset] + self.collectionView.contentSize.width - self.itemSize.width;
}

- (CGFloat)snapStep
{
    return self.itemSize.width + self.minimumLineSpacing;
}

@end
