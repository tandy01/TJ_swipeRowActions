//
//  NSObject+tj_swipeRowActions.h
//  tableViewTestDemo
//
//  Created by GC_tandy on 2018/6/9.
//  Copyright © 2018年 唐健. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SwipeRowAction;

@interface NSObject (tj_swipeRowActions)

/**
 对此属性赋值 可以自定义cell编辑的格式
 
 注意！！！！
 1.此属性设置后 需要设置一下tableView的代理    (tableView.delegate = self;)
 2.swipeRowAction中 title可以为空 但是不能相同 (毕竟title一般都不会相同)
 3.背景色不能设置透明度或设置无色 （掩盖背后的真相）
 */
@property (nonatomic,strong) NSArray <SwipeRowAction *>*swipeRowActions;

@end



@interface SwipeRowAction : NSObject

@property (nonatomic,copy) NSString *title;/*------- 文字 --------*/

@property (nonatomic,strong) UIImage *image;/*------- 图标 --------*/

@property (nonatomic,strong) UIColor *bgColor;/*------- 背景颜色 --------*/

@property (nonatomic,strong) UIColor *titleColor;/*------- 文字颜色 --------*/

@property (nonatomic,strong) UIFont *titleFont;/*------- 默认15号字体 --------*/

@property (nonatomic,assign) CGPoint offset;/*------- 默认居中，可设置偏移值 --------*/

@property (nonatomic,copy) void(^swipeRowAction)(UITableView *tableView,NSIndexPath *indexPath);

+ (instancetype)swipeRowActionWithTitle:(NSString *)title image:(UIImage *)image backgroundColor:(UIColor *)bgColor titleColor:(UIColor *)titleColor swipeRowAction:(void(^)(UITableView *tableView,NSIndexPath *indexPath))swipeRowAction;


@end


@interface UITableView (SwipeActionView)

@end

