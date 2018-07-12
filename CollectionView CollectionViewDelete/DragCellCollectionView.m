//
//  DragCellCollectionView.m
//  CollectionView CollectionViewDelete
//
//  Created by Superman on 2018/7/12.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import "DragCellCollectionView.h"
#import "SubCollectionViewCell.h"

#import <AudioToolbox/AudioToolbox.h>

#define angelToRandian(x)  ((x)/180.0*M_PI)

typedef NS_ENUM(NSUInteger, DragCellCollectionViewScrollDirection) {
    DragCellCollectionViewScrollDirectionNone = 0,
    DragCellCollectionViewScrollDirectionLeft,
    DragCellCollectionViewScrollDirectionRight,
    DragCellCollectionViewScrollDirectionUp,
    DragCellCollectionViewScrollDirectionDown
};
@interface DragCellCollectionView ()

@property (nonatomic, strong) NSIndexPath *originalIndexPath;
@property (nonatomic, strong) NSIndexPath *moveIndexPath;
@property (nonatomic, weak) UIView *tempMoveCell;
@property (nonatomic, weak) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) CADisplayLink *edgeTimer;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) DragCellCollectionViewScrollDirection scrollDirection;
@property (nonatomic, assign) CGFloat oldMinimumPressDuration;
@property (nonatomic, assign, getter=isObservering) BOOL observering;

@end

@implementation DragCellCollectionView{
    NSTimer *_scrollerTimer;
}
@dynamic delegate;
@dynamic dataSource;


static NSString * const reuseIdentifier = @"Cell";

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    // Uncomment the following line to preserve selection between presentations
//    // self.clearsSelectionOnViewWillAppear = NO;
//
//    // Register cell classes
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
//
//    // Do any additional setup after loading the view.
//}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self p_initializeProperty];
        [self p_addGesture];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self p_initializeProperty];
        [self p_addGesture];
    }
    return self;
}

- (void)p_initializeProperty{
    _minimumPressDuration = 5;
    _edgeScrollEable = YES;
    _shakeWhenMoveing = YES;
    _shakeLevel = 4.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionViewdeleteCell:) name:deleteCell object:nil];
}

#pragma mark - longPressGesture methods

/**
 *  添加一个自定义的滑动手势
 */
- (void)p_addGesture{
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(p_longPressed:)];
    
    longPress.minimumPressDuration = _minimumPressDuration;
    _longPressGesture = longPress;
    [self addGestureRecognizer:longPress];
    
}


/**
 *  监听手势的改变
 */
- (void)p_longPressed:(UILongPressGestureRecognizer *)longPressGesture{
    if (longPressGesture.state == UIGestureRecognizerStateBegan) {
        [self p_gestureBegan:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateChanged) {
        [self p_gestureChange:longPressGesture];
    }
    if (longPressGesture.state == UIGestureRecognizerStateCancelled ||
        longPressGesture.state == UIGestureRecognizerStateEnded){
        [self p_gestureEndOrCancle:longPressGesture];
    }
}

/**
 *  手势开始
 */
- (void)p_gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{
    
    //获取手指所在的cell
    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
    cell.hidden = YES;
    _tempMoveCell = tempMoveCell;
    _tempMoveCell.frame = cell.frame;
    [self addSubview:_tempMoveCell];
    
    //    //开启边缘滚动定时器
    [self p_setEdgeTimer];
    //开启抖动
    if (_shakeWhenMoveing && !_editing) {
        [self p_shakeAllCell];
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:cellWillBeginMoveAtIndexPath:)]) {
        [self.delegate dragCellCollectionView:self cellWillBeginMoveAtIndexPath:_originalIndexPath];
    }
}
/**
 *  手势拖动
 */
- (void)p_gestureChange:(UILongPressGestureRecognizer *)longPressGesture{
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellisMoving:)]) {
        [self.delegate dragCellCollectionViewCellisMoving:self];
    }
    
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    [self p_moveCell];
}

/**
 *  手势取消或者结束
 */
- (void)p_gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.userInteractionEnabled = NO;
    [self p_stopEdgeTimer];
    //通知代理
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionViewCellEndMoving:)]) {
        [self.delegate dragCellCollectionViewCellEndMoving:self];
    }
    [UIView animateWithDuration:0.25 animations:^{
        _tempMoveCell.center = cell.center;
    } completion:^(BOOL finished) {
        [self p_stopShakeAllCell];
        [_tempMoveCell removeFromSuperview];
        cell.hidden = NO;
        self.userInteractionEnabled = YES;
    }];
}



#pragma mark - setter methods

- (void)setMinimumPressDuration:(NSTimeInterval)minimumPressDuration{
    _minimumPressDuration = minimumPressDuration;
    _longPressGesture.minimumPressDuration = minimumPressDuration;
}

- (void)setShakeLevel:(CGFloat)shakeLevel{
    CGFloat level = MAX(1.0f, shakeLevel);
    _shakeLevel = MIN(level, 10.0f);
}

#pragma mark - timer methods

- (void)p_setEdgeTimer{
    if (!_edgeTimer && _edgeScrollEable) {
        _edgeTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_edgeScroll)];
        [_edgeTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)p_stopEdgeTimer{
    if (_edgeTimer) {
        [_edgeTimer invalidate];
        _edgeTimer = nil;
    }
}


#pragma mark - private methods

- (void)collectionViewdeleteCell:(NSNotification*)noti
{
    UICollectionViewCell *cell = noti.object;
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    NSMutableArray *orignalSection = temp[indexPath.section];
    [orignalSection removeObjectAtIndex:indexPath.item];
    //    [orignalSection removeObject:orignalSection[indexPath.item]]; //这种删除方式当数据有相同时，会出现bug
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
    [self deleteItemsAtIndexPaths:@[indexPath]];
}

- (void)p_moveCell{
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            _moveIndexPath = [self indexPathForCell:cell];
            //更新数据源
            [self p_updateDataSource];
            //移动
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            
            
            //通知代理
            if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:moveCellFromIndexPath:toIndexPath:)]) {
                [self.delegate dragCellCollectionView:self moveCellFromIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            }
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
            break;
        }
    }
}

/**
 *  更新数据源
 */
- (void)p_updateDataSource{
    NSMutableArray *temp = @[].mutableCopy;
    //获取数据源
    if ([self.dataSource respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.dataSource dataSourceArrayOfCollectionView:self]];
    }
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }else{
        
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
        
    }
    //将重排好的数据传递给外部
    if ([self.delegate respondsToSelector:@selector(dragCellCollectionView:newDataArrayAfterMove:)]) {
        [self.delegate dragCellCollectionView:self newDataArrayAfterMove:temp.copy];
    }
}

- (void)p_edgeScroll{
    [self p_setScrollDirection];
    switch (_scrollDirection) {
        case DragCellCollectionViewScrollDirectionLeft:{
            //这里的动画必须设为NO
            [self setContentOffset:CGPointMake(self.contentOffset.x - 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x - 4, _tempMoveCell.center.y);
            _lastPoint.x -= 4;
            
        }
            break;
        case DragCellCollectionViewScrollDirectionRight:{
            [self setContentOffset:CGPointMake(self.contentOffset.x + 4, self.contentOffset.y) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x + 4, _tempMoveCell.center.y);
            _lastPoint.x += 4;
            
        }
            break;
        case DragCellCollectionViewScrollDirectionUp:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y - 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y - 4);
            _lastPoint.y -= 4;
        }
            break;
        case DragCellCollectionViewScrollDirectionDown:{
            [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentOffset.y + 4) animated:NO];
            _tempMoveCell.center = CGPointMake(_tempMoveCell.center.x, _tempMoveCell.center.y + 4);
            _lastPoint.y += 4;
        }
            break;
        default:
            break;
    }
    
}

- (void)p_shakeAllCell{
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"transform.rotation";
    anim.values=@[@(angelToRandian(-_shakeLevel)),@(angelToRandian(_shakeLevel)),@(angelToRandian(-_shakeLevel))];
    anim.repeatCount=MAXFLOAT;
    anim.autoreverses = YES;
    anim.duration=0.2;
    //    anim.removedOnCompletion = NO;
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        
        /**如果加了shake动画就不用再加了*/
        if (![cell.layer animationForKey:@"shake"]) {
            [cell.layer addAnimation:anim forKey:@"shake"];
        }
    }
    if (![_tempMoveCell.layer animationForKey:@"shake"]) {
        [_tempMoveCell.layer addAnimation:anim forKey:@"shake"];
    }
    
}

- (void)p_stopShakeAllCell{
    if (!_shakeWhenMoveing || _editing) {
        return;
    }
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        [cell.layer removeAllAnimations];
    }
    [_tempMoveCell.layer removeAllAnimations];
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)p_setScrollDirection{
    _scrollDirection = DragCellCollectionViewScrollDirectionNone;
    if (self.bounds.size.height + self.contentOffset.y - _tempMoveCell.center.y < _tempMoveCell.bounds.size.height / 2 && self.bounds.size.height + self.contentOffset.y < self.contentSize.height) {
        _scrollDirection = DragCellCollectionViewScrollDirectionDown;
    }
    if (_tempMoveCell.center.y - self.contentOffset.y < _tempMoveCell.bounds.size.height / 2 && self.contentOffset.y > 0) {
        _scrollDirection = DragCellCollectionViewScrollDirectionUp;
    }
    if (self.bounds.size.width + self.contentOffset.x - _tempMoveCell.center.x < _tempMoveCell.bounds.size.width / 2 && self.bounds.size.width + self.contentOffset.x < self.contentSize.width) {
        _scrollDirection = DragCellCollectionViewScrollDirectionRight;
    }
    
    if (_tempMoveCell.center.x - self.contentOffset.x < _tempMoveCell.bounds.size.width / 2 && self.contentOffset.x > 0) {
        _scrollDirection = DragCellCollectionViewScrollDirectionLeft;
    }
}

#pragma mark - public methods

- (void)_enterEditingModel{
    _editing = YES;
    _oldMinimumPressDuration =  _longPressGesture.minimumPressDuration;
    _longPressGesture.minimumPressDuration = 0.4;
    if (_shakeWhenMoveing) {
        [self p_shakeAllCell];
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        //添加cell通知
        [[NSNotificationCenter defaultCenter] postNotificationName:editStateChanged object:@YES];
    }
}

- (void)_stopEditingModel{
    _editing = NO;
    _longPressGesture.minimumPressDuration = _oldMinimumPressDuration;
    [self p_stopShakeAllCell];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    //添加cell通知
    [[NSNotificationCenter defaultCenter] postNotificationName:editStateChanged object:@NO];
}


#pragma mark - overWrite methods

/**
 *  重写hitTest事件，判断是否应该相应自己的滑动手势，还是系统的滑动手势
 */

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    _longPressGesture.enabled = [self indexPathForItemAtPoint:point];
    return [super hitTest:point withEvent:event];
}

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (_observering) {
            return;
        }else{
            _observering = YES;
        }
    }
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (!_observering) {
            return;
        }else{
            _observering = NO;
        }
    }
    [super removeObserver:observer forKeyPath:keyPath];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    [self p_shakeAllCell];
}

#pragma mark - notification

- (void)p_foreground{
    if (_editing) {
        [self p_shakeAllCell];
    }
}

- (void)dealloc{
    [self removeObserver:self forKeyPath:@"contentOffset"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 0;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
