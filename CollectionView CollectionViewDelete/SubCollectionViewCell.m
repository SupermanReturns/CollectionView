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

        UILabel  *titleLabel=[[UILabel alloc]init];
        [self.contentView addSubview:titleLabel];
        _titleLabel=titleLabel;
        
        UIButton *headerButton=[[UIButton alloc]init];
        [self.contentView addSubview:headerButton];
        _headerButton=headerButton;
        
        UIButton *deleteButton=[[UIButton alloc]init];
        [deleteButton setBackgroundImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(clickDeleteButton) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.hidden=YES;
        [_headerButton addSubview:deleteButton];

        _deleteButton=deleteButton;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleShake:) name:editStateChanged object:nil];

    }
    return self;
}

-(void)layoutSubviews{
    _headerButton.frame=CGRectMake(5, 5, 60, 60);
    _titleLabel.frame=CGRectMake(0, 67, 70, 18);
    _deleteButton.frame=CGRectMake(0, 0,20, 20);
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
