//
//  UIScrollView+TDScrollView.m
//  Ouye
//
//  Created by tradata Client on 2018/6/19.
//  Copyright © 2018年 董家祎. All rights reserved.
//

#import "UIScrollView+TDScrollView.h"
#import <MJRefresh/MJRefresh.h>

#import <objc/runtime.h>

@interface TDScrollViewWeakObjectContainer : NSObject
@property(nonatomic,readonly,weak) id  weakObject;
- (instancetype)initWithWeakObject:(id)object;
@end

@implementation TDScrollViewWeakObjectContainer

- (instancetype)initWithWeakObject:(id)object{
    
    self = [super init];
    if (self) {
        _weakObject = object;
    }
    
    return self;
}

@end

@interface UIScrollView ()

//MARK: 0 不显示空白页面  1 显示空白页面
@property(nonatomic,strong)NSString* isDisplyEmpty;

@property(nonatomic,strong)UIImage * errorImage;
@property(nonatomic,strong)NSString * errorMsg;

@property(nonatomic,strong)UIActivityIndicatorView * indicatorView;

@property(nonatomic,strong)UILabel * reminderLabel;

@end

@implementation UIScrollView (TDScrollView)

-(BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    if ([self.tdDelegate respondsToSelector:@selector(tdIsEmptyDataSetShouldAllowScroll:)]) {
        return [self.tdDelegate tdIsEmptyDataSetShouldAllowScroll:scrollView];
    }
    
    return YES;
}

#pragma mark:空白页面相关

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView{
    
    if ([self.tdDelegate respondsToSelector:@selector(tdClientEmptyCustomView)]) {
        UIView * emptyView = [self.tdDelegate tdClientEmptyCustomView];
        
        return  emptyView;
    }
    
    
    return  nil;
    
}

-(UIImage*) imageForEmptyDataSet:(UIScrollView *)scrollView{
    
    if ([self.tdDelegate respondsToSelector:@selector(tdClientEmptyImage)]) {
        
        UIImage * emptyImage = [self.tdDelegate tdClientEmptyImage];
        
        return emptyImage;
    }
    if (self.errorImage != nil) {
        UIImage * errorImage = self.errorImage;
        return errorImage;
    }
    
    return [UIImage imageNamed:@"icon_search_main_placeholder"];
}

-(CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    
    if ([self.tdDelegate respondsToSelector:@selector(tdClientVerticalOffsetEmpty)]) {
        
        return [self.tdDelegate tdClientVerticalOffsetEmpty];
    }
    return 0.0;
}

-(CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView{
    return 20.0;
}
- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"暂时没有数据";
    if ([self.tdDelegate respondsToSelector:@selector(tdClientEmptyTitle)]) {
        NSString * emptyString = [self.tdDelegate tdClientEmptyTitle];
        text = emptyString;
    }
    if (self.errorMsg != nil) {
        text = self.errorMsg;
    }
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:25/255.0 green:33/255.0 blue:52/255.0 alpha:1.0],
                                 NSParagraphStyleAttributeName:paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}



-(BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    
    
    
    
    return [self.isDisplyEmpty isEqualToString:@"0"] ? NO : YES;
}


#pragma mark: addRefresh
-(void)addBeginRefreshHeader{
    
    if ([self isKindOfClass:[UITableView class]]) {
        if (@available(iOS 11.0, *)) {
            UITableView * tableView = (UITableView*)self;
            tableView.estimatedRowHeight = 0;
        }
    }
    
    if ([self.tdDelegate respondsToSelector:@selector(tdClientBeginRefresh)]) {
        
        MJRefreshNormalHeader *refreshHeader =  [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDataAction)];
        refreshHeader.lastUpdatedTimeLabel.hidden =  YES;
        [refreshHeader setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
        [refreshHeader setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
        [refreshHeader setTitle:@"松手刷新" forState:MJRefreshStatePulling];
        self.mj_header = refreshHeader;
    }
    
    if ([self.tdDelegate respondsToSelector:@selector(isAutoRefresh)]) {
        BOOL isAutoRefresh = [self.tdDelegate isAutoRefresh];
        
        if (isAutoRefresh == YES) {
            [self td_headerRefresh];
        }
    }
    
}
-(void)addLoadMoreRefreshFooter{
 
    if ([self.tdDelegate respondsToSelector:@selector(tdClientLoadMoreRefresh)] && self.mj_footer == nil) {
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataAction)];
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        
        [footer setTitle:@"正在加载数据" forState:MJRefreshStateRefreshing];
        [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
        
        self.mj_footer = footer;
        
    }
    
}


#pragma mark: refresh 相关
-(void)td_headerRefresh{
    [self.mj_header beginRefreshing];
}
-(void)td_endBeginRefresh{
    if (self.mj_header && [self.mj_header isRefreshing]) {
        
        [self.mj_header endRefreshing];
        
    }
}
-(void)td_displayEmpty{
    if ([self.tdDelegate respondsToSelector:@selector(isEmptyDataSet)]) {
        
        BOOL isEmpty = [self.tdDelegate isEmptyDataSet];
        self.isDisplyEmpty = isEmpty == YES ? @"1" : @"0";
        
    }else{
        self.isDisplyEmpty = @"1";
    }
}

-(void)td_endLoadMoreRefresh:(NSInteger)count{
    
    if ([self.mj_header isRefreshing]){
        [self.mj_footer endRefreshing];
    }
    
    if (self.mj_footer && [self.mj_footer isRefreshing]) {
        
        if (count == 0) {
            
            if ([self isKindOfClass:[UITableView class]]) {
                UITableView * tableView = (UITableView*)self;
                [self tableRowCount:tableView];
            }
            if ([self isKindOfClass:[UICollectionView class]]) {
                UICollectionView * collectioinView = (UICollectionView*)self;
                [self collectionRowCount:collectioinView];
            }
            [self.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.mj_footer endRefreshing];
        }
        
    }
}


-(void)collectionRowCount:(UICollectionView*)collectionView{
    NSInteger items = 0;
    id<UICollectionViewDataSource> dataSource = collectionView.dataSource;
     NSInteger sections = 1;
    if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInCollectionView:)]) {
        sections = [dataSource numberOfSectionsInCollectionView:collectionView];
    }
    
    if (dataSource && [dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
        for (NSInteger section = 0; section < sections; section ++) {
            items += [dataSource collectionView:collectionView numberOfItemsInSection:section];
        }
        
    }
    if (items == 0) {
        self.mj_footer = nil;
        
    }else{
        [self addLoadMoreRefreshFooter];
        
    }
    
}
-(void)tableRowCount:(UITableView*)tableView{
    NSInteger items = 0;
    
    id <UITableViewDataSource> dataSource = tableView.dataSource;
    
    NSInteger sections = 1;
    
    if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [dataSource numberOfSectionsInTableView:tableView];
    }
    
    if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        for (NSInteger section = 0; section < sections; section++) {
            items += [dataSource tableView:tableView numberOfRowsInSection:section];
        }
    }
    
    if (items == 0) {
        self.mj_footer = nil;
        
    }else{
        [self addLoadMoreRefreshFooter];
        
    }
    
    
}

-(void)dealloc{
    [self td_stopIndicator];
}

#pragma mark: reload 相关


-(void)td_reloadAtErrorImage:(UIImage*)errorImage withErrorMsg:(NSString*)errorMsg{
    self.errorImage  = errorImage;
    self.errorMsg = errorMsg;
    [self td_reload:-1];
}

-(void)td_reload:(NSInteger)count{
    
    [self td_endBeginRefresh];
    [self td_endLoadMoreRefresh:count];
    [self td_displayEmpty];
    [self td_reloadData];
    [self reloadEmptyDataSet];
    [self td_stopIndicator];
    
}

-(void)td_reloadEmpty{
    
    [self reloadEmptyDataSet];
}

-(void)td_reloadData{
    
    if ([self isKindOfClass:[UICollectionView class]]) {
        UICollectionView * collectionView = (UICollectionView*)self;
        [collectionView reloadData];
    }
    
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView * tableView = (UITableView*)self;
        
        [tableView reloadData];
    }
    
}

#pragma mark:加载tableView拖动排序


#pragma mark:刷新样式相关
-(void)loadNewDataAction{
    
    if ([self.mj_footer isRefreshing]) {
        
        [self td_endLoadMoreRefresh:-1];
    }
    
    [self.tdDelegate performSelector:@selector(tdClientBeginRefresh)];
    
}

-(void)loadMoreDataAction{
    if ([self.mj_header isRefreshing]) {
        return;
    }
    [self.tdDelegate performSelector:@selector(tdClientLoadMoreRefresh)];
    
}

#pragma mark: 菊花提示相关
-(void)initiReminderLabel{
    self.reminderLabel = [UILabel new];
    self.reminderLabel.font = [UIFont systemFontOfSize:12];
    self.reminderLabel.textColor = [UIColor darkGrayColor];
    self.reminderLabel.frame = CGRectMake(0, self.indicatorView.frame.size.height+self.indicatorView.frame.origin.y+10, [UIScreen mainScreen].bounds.size.width, 10);
    self.reminderLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.reminderLabel];
}


-(void)initiActivityIndicatorView{
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicatorView.frame  =CGRectMake(0, 0, 30, 30);
    
    CGFloat vertical = 0.0;
    if ([self.tdDelegate respondsToSelector:@selector(tdClientVerticalOffsetEmpty)]) {
        vertical = [self.tdDelegate tdClientVerticalOffsetEmpty];
    }
    self.indicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,[UIScreen mainScreen].bounds.size.height/2-64 + vertical);
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView * tableView = (UITableView*)self;
        
        tableView.tableHeaderView.hidden = YES;
        tableView.tableFooterView.hidden = YES;
    }
    [self addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
}

-(void)td_startIndicatorReminder:(NSString *)reminder{
    if (self.indicatorView == nil) {
        [self initiActivityIndicatorView];
    }
    if (self.reminderLabel == nil &&  reminder!= nil) {
        
        [self initiReminderLabel];
    }
    self.reminderLabel.text = reminder;
}


-(void)td_startIndicator{
    [self td_startIndicatorReminder:nil];
}
-(void)td_stopIndicatorAtErrorImage:(UIImage *)errorImage withErrorMsg:(NSString *)errorMsg{
    [self td_stopIndicator];
    
    self.isDisplyEmpty = @"1";
    self.emptyDataSetSource = self;
    self.errorImage  =  errorImage;
    self.errorMsg    =  errorMsg;
    [self reloadEmptyDataSet];
}

-(void)td_stopIndicator{
    [self.indicatorView stopAnimating];
    if ([self isKindOfClass:[UITableView class]]) {
        UITableView* tableView = (UITableView*)self;
        tableView.tableHeaderView.hidden = NO;
        tableView.tableFooterView.hidden = NO;
    }
    
    self.indicatorView = nil;
    self.reminderLabel.text = @"";
    [self.reminderLabel removeFromSuperview];
}

#pragma mark: runtime get set

-(void)setErrorImage:(UIImage *)errorImage{
    objc_setAssociatedObject(self, @selector(errorImage), errorImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
-(UIImage*)errorImage{
    return objc_getAssociatedObject(self, @selector(errorImage));
}

-(void)setErrorMsg:(NSString *)errorMsg{
    objc_setAssociatedObject(self, @selector(errorMsg), errorMsg, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString*)errorMsg{
    
    return  objc_getAssociatedObject(self, @selector(errorMsg));
}

-(void)setIndicatorView:(UIActivityIndicatorView *)indicatorView{
    objc_setAssociatedObject(self, @selector(indicatorView), indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIActivityIndicatorView*)indicatorView{
    
    return objc_getAssociatedObject(self, @selector(indicatorView));
}

-(void)setIsDisplyEmpty:(NSString*)isDisplyEmpty{
    objc_setAssociatedObject(self, @selector(isDisplyEmpty), isDisplyEmpty, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString*)isDisplyEmpty{
    return objc_getAssociatedObject(self, @selector(isDisplyEmpty));
}

-(void)setReminderLabel:(UILabel *)reminderLabel{
    objc_setAssociatedObject(self, @selector(reminderLabel), reminderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UILabel*)reminderLabel{
    
    return objc_getAssociatedObject(self, @selector(reminderLabel));
}

-(void)setTdDelegate:(id<TDScrollviewDelegate>)tdDelegate{
    
    
    objc_setAssociatedObject(self, @selector(tdDelegate), [[TDScrollViewWeakObjectContainer alloc] initWithWeakObject:tdDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.emptyDataSetDelegate = self;
    self.emptyDataSetSource = self;
    
    self.isDisplyEmpty = @"0";
    
    [self addBeginRefreshHeader];
    [self addLoadMoreRefreshFooter];
    
}

-(id<TDScrollviewDelegate>) tdDelegate{
    
    TDScrollViewWeakObjectContainer * container = objc_getAssociatedObject(self, @selector(tdDelegate));
    
    return container.weakObject;
    
}



@end



