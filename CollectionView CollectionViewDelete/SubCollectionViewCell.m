//
//  CollectionViewCell.m
//  CollectionView CollectionViewDelete
//
//  Created by Superman on 2018/7/12.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import "SubCollectionViewCell.h"
#define angelToRandian(x)  ((x)/180.0*M_PI)
static NSString *animationKey = @"PagingShakeAnimation";

@interface SubCollectionViewCell()
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@end

@implementation SubCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
//        @property (strong, nonatomic) UILabel  *titleLabel;
//        @property(strong,nonatomic) UIButton *headerButton;
//        @property(strong,nonatomic)UIButton *deleteButton;
        UILabel  *titleLabel=[[UILabel alloc]init];
        [self.contentView addSubview:titleLabel];
        _titleLabel=titleLabel;
        
        UIButton *headerButton=[[UIButton alloc]init];
        [self.contentView addSubview:headerButton];
        _headerButton=headerButton;
        
        UIButton *deleteButton=[[UIButton alloc]init];
        [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteButton];
        _deleteButton=deleteButton;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShake:) name:editStateChanged object:nil];

    }
    return self;
}
-(void)layoutUI{
    
}
-(void)clickDeleteButton{
    [[NSNotificationCenter defaultCenter] postNotificationName:deleteCell object:self];
}
- (void)handleShake:(NSNotification*)sender
{
    if ([sender.object intValue] == YES) {
        
        self.deleteButton.hidden = NO;
        self.deleteButton.userInteractionEnabled = YES;
        
    }else{
        self.deleteButton.hidden = YES;
        
    }
}

@end
