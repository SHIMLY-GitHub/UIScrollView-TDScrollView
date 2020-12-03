//
//  UIScrollView+TDScrollView.h
//  Ouye
//
//  Created by tradata Client on 2018/6/19.
//  Copyright © 2018年 董家祎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"

@protocol TDScrollviewDelegate  <NSObject>

@optional
/** 下拉刷新 */
-(void)tdClientBeginRefresh;

/** 上拉加载更多 */

-(void)tdClientLoadMoreRefresh;

/** 是否自动刷新 不实现此协议 默认为NO */
-(BOOL)isAutoRefresh;

/** 是否需要显示空白页面 默认为YES */

-(BOOL)isEmptyDataSet;


/**自定义空白页面 */
-(UIView*)tdClientEmptyCustomView;
/** 空白图片 */

-(UIImage*)tdClientEmptyImage;

/** 空白标题 */

-(NSString*)tdClientEmptyTitle;

/** 空白页面垂直偏移量 */

-(CGFloat)tdClientVerticalOffsetEmpty;


/**空的scrollow是否可以滚动 默认YES*/
-(BOOL)tdIsEmptyDataSetShouldAllowScroll:(UIScrollView*)scrollView;

/*返回重新排序的数据源*/
- (NSArray *)originalArrayForTableView:(UITableView *)tableView;


@end


@interface UIScrollView (TDScrollView)<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
/**
 UIScrollView+TDScrollView delegate;
 */
@property(nonatomic,weak)IBOutlet id<TDScrollviewDelegate> tdDelegate;



/**
 加载菊花 有提示文字

 @param reminder 提示文字
 */
-(void)td_startIndicatorReminder:(NSString*)reminder;
/**
 加载菊花 没有提示文字
 */
-(void)td_startIndicator;
/**
 停止加载
 */
-(void)td_stopIndicator;

/**
 停止加载菊花

 @param errorImage 提示图片
 @param errorMsg 提示文字
 */
-(void)td_stopIndicatorAtErrorImage:(UIImage*)errorImage withErrorMsg:(NSString*)errorMsg;

/**
 下拉刷新
 */
-(void)td_headerRefresh;

/**
 此方法用于处理异常情况的空白页面

 @param errorImage 错误图片 不穿 会使用默认图片
 @param errorMsg 错误提示语
 */
-(void)td_reloadAtErrorImage:(UIImage*)errorImage withErrorMsg:(NSString*)errorMsg;

/**
 刷新方法

 @param count count = 0 的时候 会显示没有更多数据
 */
-(void)td_reload:(NSInteger)count;

/**
 刷新空白页面
 */
-(void)td_reloadEmpty;
@end
