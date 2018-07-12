//
//  PagingCollectionViewLayout.h
//  CollectionView CollectionViewDelete
//
//  Created by Superman on 2018/7/12.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PagingCollectionViewLayout : UICollectionViewLayout

@property (nonatomic) CGFloat minimumLineSpacing; //行间距

@property (nonatomic) CGFloat minimumInteritemSpacing; //item间距

@property (nonatomic) CGSize itemSize; //item大小

@property (nonatomic) UIEdgeInsets sectionInset;

- (instancetype)init;


@end
