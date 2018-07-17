//
//  ViewController.m
//  CollectionView CollectionViewDelete
//
//  Created by Superman on 2018/7/12.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import "ViewController.h"
#import "SubCollectionViewCell.h"
#import "PagingCollectionViewLayout.h"
#import "DragCellCollectionView.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,DragCellCollectionViewDelegate,DragCellCollectionViewDataSource>
@property (nonatomic, strong) NSArray *data;

@property (nonatomic, strong) NSArray *data2;

@property (nonatomic, strong) NSArray *dataAll;

@property (nonatomic, strong) DragCellCollectionView *homeCollectionV;
@end

@implementation ViewController{
    BOOL _select;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    PagingCollectionViewLayout *layout = [[PagingCollectionViewLayout alloc]init];
    
    NSArray *datas = @[@"alipay_r",@"bitcoin_r",@"dianpin_r",@"douban_r",@"dribbble_r",@"dropbox_r",@"email_r",@"evernote_r",@"facebook_r",@"google-plus_r",@"instagram_r",@"instapaper_r",@"line_r",@"linkedin_r",@"path_r",@"snapchat_r",@"path_r",@"snapchat_r",@"pinterest_r",@"pocket_r",@"qq_r",@"quora_r",@"qzone_r",@"readability_r",@"reddit_r",@"path_r",@"snapchat_r",@"pinterest_r",@"pocket_r",@"qq_r",@"quora_r",@"qzone_r",@"readability_r",@"reddit_r"];
    NSArray *dataTwo = @[@"path_r",@"snapchat_r",@"pinterest_r",@"pocket_r",@"qq_r",@"quora_r",@"qzone_r",@"readability_r",@"reddit_r"];
    
    
    _data2 = dataTwo;
    self.data = datas;
    self.dataAll = @[self.data];
    
    
    self.homeCollectionV = [[DragCellCollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 - 150) collectionViewLayout:layout];
    self.homeCollectionV.backgroundColor = [UIColor clearColor];
    self.homeCollectionV.tag = 100;
    self.homeCollectionV.delegate = self;
    self.homeCollectionV.dataSource = self;
    self.homeCollectionV.shakeLevel = 3.0f;
    [self.homeCollectionV setMinimumPressDuration:1.5];
    self.homeCollectionV.showsVerticalScrollIndicator = NO;
    self.homeCollectionV.showsHorizontalScrollIndicator = NO;
    self.homeCollectionV.pagingEnabled = YES;
    self.homeCollectionV.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:self.homeCollectionV];

    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    button.backgroundColor = [UIColor cyanColor];
    [button addTarget:self action:@selector(handle) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _select = NO;

    [self.homeCollectionV registerClass:[SubCollectionViewCell class] forCellWithReuseIdentifier:reusableCell];
}
- (void)handle{
    if (_select == NO) {
        [self.homeCollectionV enterEditingModel];
    }else{
        [self.homeCollectionV stopEditingModel];
    }
    _select = !_select;
}



- (void)dragCellCollectionView:(DragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    
    self.dataAll = newDataArray;
    
}

- (NSArray *)dataSourceArrayOfCollectionView:(DragCellCollectionView *)collectionView{
    return  self.dataAll;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataAll.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.dataAll[section];
    return array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{

    SubCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reusableCell   forIndexPath:indexPath];

    NSString *name;
    NSArray *array =  self.dataAll[indexPath.section];
    
    name = [array objectAtIndex:indexPath.item];
    //    cell.backgroundColor = [UIColor greenColor];
    [cell.headerButton setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    if ([cell.layer animationForKey:@"shake"]) {
        cell.deleteButton.hidden = NO;
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"%ld",indexPath.item];
    //    cell.titleLabel.text = name;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
