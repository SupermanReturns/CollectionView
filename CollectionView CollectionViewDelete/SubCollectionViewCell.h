//
//  CollectionViewCell.h
//  CollectionView CollectionViewDelete
//
//  Created by Superman on 2018/7/12.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *reusableCell = @"SubCollectionViewCell";

static NSString *editStateChanged = @"editStateChanged";

static NSString *deleteCell = @"deleteCellNotification";

@interface SubCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel  *titleLabel;
@property(strong,nonatomic) UIButton *headerButton;
@property(strong,nonatomic)UIButton *deleteButton;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)shake;

- (void)stopShake;

@end
