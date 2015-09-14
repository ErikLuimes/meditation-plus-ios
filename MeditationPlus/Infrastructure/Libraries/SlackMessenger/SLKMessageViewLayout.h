//
//  SLKMessageViewLayout.h
//  Messenger
//
//  Created by Ignacio Romero Z. on 11/4/14.
//  Copyright (c) 2014 Slack Technologies, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SLKMessageViewLayoutDelegate;

@interface SLKMessageViewLayout : UICollectionViewFlowLayout

@end

@protocol SLKMessageViewLayoutDelegate <UICollectionViewDelegateFlowLayout>
@required

- (CGFloat)collectionView:(UICollectionView *)collectionView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
