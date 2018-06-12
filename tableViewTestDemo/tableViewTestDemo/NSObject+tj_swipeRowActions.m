//
//  NSObject+tj_swipeRowActions.m
//  tableViewTestDemo
//
//  Created by GC_tandy on 2018/6/9.
//  Copyright © 2018年 唐健. All rights reserved.
//

#import "NSObject+tj_swipeRowActions.h"

#import <objc/runtime.h>
#import <objc/message.h>



static NSString *swipeRowActionsKey  = @"swipeRowActionsKey";

@implementation SwipeRowAction

+ (instancetype)swipeRowActionWithTitle:(NSString *)title image:(UIImage *)image backgroundColor:(UIColor *)bgColor titleColor:(UIColor *)titleColor swipeRowAction:(void(^)(UITableView *tableView,NSIndexPath *indexPath))swipeRowAction{
    SwipeRowAction *action = [SwipeRowAction new];
    action.title = title;
    action.image = image;
    action.bgColor = bgColor;
    action.titleColor = titleColor;
    action.swipeRowAction = swipeRowAction;
    return action;
}

- (UIColor *)bgColor{
    if(_bgColor == nil){
        _bgColor = [UIColor clearColor];
    }
    return _bgColor;
}
- (UIFont *)titleFont{
    if(_titleFont == nil){
        _titleFont = [UIFont systemFontOfSize:15];
    }
    return _titleFont;
}

- (UIColor *)titleColor{
    if(_titleColor == nil){
        _titleColor = [UIColor grayColor];
    }
    return _titleColor;
}

#define placeHolderStr  @"tj_"
static NSInteger appending = 1;

- (NSString *)title{
    if(_title == nil){
        _title = [placeHolderStr stringByAppendingString:@(appending++).stringValue];
    }
    return _title;
}

@end



@implementation NSObject (tj_swipeRowActions)


- (void)setSwipeRowActions:(NSArray *)swipeRowActions {
    for(id obj in swipeRowActions){
     NSCAssert([obj isKindOfClass:[SwipeRowAction class]], @"SwipeRowActions contains a no SwipeRowAction object");
    }
    
    if(swipeRowActions.count == 0)return;
    
    [self changeSelfClassToSubClass];
    
    objc_setAssociatedObject(self, &swipeRowActionsKey, swipeRowActions, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)swipeRowActions {
    return objc_getAssociatedObject(self, &swipeRowActionsKey);
}

static char *TJ_subClassKey  = "TJ_subClassKey";

- (void)changeSelfClassToSubClass{
 
    if([NSStringFromClass([self class]) containsString:@"TJ_subClassKey"]){
        return;
    }
    Class TJ_subClass = objc_allocateClassPair([self class], TJ_subClassKey, 0);
    
    IMP imp = [self methodForSelector:@selector(tj_tableView:editActionsForRowAtIndexPath:)];
    
    class_addMethod(TJ_subClass, @selector(tableView:editActionsForRowAtIndexPath:), (IMP)imp, "v@:@");
    objc_registerClassPair(TJ_subClass);
    
    object_setClass(self, TJ_subClass);
    
}

- (nullable NSArray<UITableViewRowAction *> *)tj_tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *arrM = @[].mutableCopy;
    for(SwipeRowAction *action_tj in self.swipeRowActions){
        UITableViewRowAction *action_sys = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:action_tj.title handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            if(action_tj.swipeRowAction){
                action_tj.swipeRowAction(tableView, indexPath);
            }
        }];
        action_sys.backgroundColor = action_tj.bgColor;
        [arrM addObject:action_sys];
    }
    return arrM;
}


@end



@implementation UITableView (SwipeActionView)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class aClass = [self class];
        
        SEL originalSelector = @selector(layoutSubviews);
        SEL swizzledSelector = @selector(layoutSubviews_swizzle);
        
        Method originalMethod = class_getInstanceMethod(aClass, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}




- (SwipeRowAction *)mappingTheRightActionWith:(UIColor *)bgColor title:(NSString *)title {
    NSObject *delegate = self.delegate;
    NSArray <SwipeRowAction*>* swipeRowActions = delegate.swipeRowActions;
    
    SwipeRowAction *action_match = nil;
    
    for(SwipeRowAction *action in swipeRowActions){
        if(((title.length == 0) && (action.title.length == 0))||
           [title isEqualToString:action.title] ){
            action_match = action;
        }
    }
    NSCAssert(action_match,@"action_match == nil!!!");
    return action_match;
}



#define bgView_tj_Tag      99990
#define titleLabel_tj_Tag  99991
#define imageView_tj_Tag   99992

#define image_title_space   5

- (void)layoutSubviews_swizzle{
        for(UIView *pullView in self.subviews){
            if([pullView isMemberOfClass:NSClassFromString(@"UISwipeActionPullView")]){
                for(UIButton *btn in pullView.subviews){
                    btn.clipsToBounds = YES;
                    UIView *bgView_sys = nil;
                    UILabel *titleLabel_sys = nil;
                    UIImageView *imageView_sys = nil;

                    for(UIView *view in btn.subviews){
                         if([view isKindOfClass:NSClassFromString(@"UIButtonLabel")]){
                             titleLabel_sys = (UILabel *)view;
                         }
                          if([view isMemberOfClass:[UIView class]]){
                              bgView_sys = view;
                          }
                        if([view isKindOfClass:[UIImageView class]]){
                            imageView_sys = (UIImageView *)view;
                        }
                    }
                    
                    SwipeRowAction *action = [self mappingTheRightActionWith:bgView_sys.backgroundColor title:titleLabel_sys.text];
                    
                    UIView *bgView_tj = [btn viewWithTag:bgView_tj_Tag];
                    if(bgView_tj == nil){
                        bgView_tj = [[UIView alloc]init];
                        
                        bgView_tj.tag = bgView_tj_Tag;
                        bgView_tj.backgroundColor = action.bgColor;
                        
                        NSInteger index = [btn.subviews indexOfObject:titleLabel_sys];
                        
                        [btn insertSubview:bgView_tj atIndex:index+1];
                        bgView_sys.hidden = YES;
                    }
                    
                    
                    UILabel *titleLabel_tj = [btn viewWithTag:titleLabel_tj_Tag];
                    if(titleLabel_tj == nil){
                       
                        titleLabel_tj = [[UILabel alloc]init];
                        titleLabel_tj.tag = titleLabel_tj_Tag;
                        titleLabel_tj.font = action.titleFont;
                        titleLabel_tj.textColor = action.titleColor;
                        
                        if([titleLabel_sys.text containsString:placeHolderStr] == NO){
                            titleLabel_tj.text = action.title;
                        }
                        titleLabel_tj.textAlignment = NSTextAlignmentCenter;
                        
                        [btn addSubview:titleLabel_tj];
                    }
                    
                    UIImageView *imageView_tj = [btn viewWithTag:imageView_tj_Tag];
                    if(imageView_tj == nil){
                        imageView_tj = [[UIImageView alloc]init];
                        imageView_tj.tag = imageView_tj_Tag;
                        imageView_tj.image = action.image;
                        imageView_tj.contentMode = UIViewContentModeScaleAspectFill;
                        
                        [btn addSubview:imageView_tj];
                        imageView_sys.hidden = YES;
                    }
                    

                    CGRect titleLabelFrame = CGRectMake(0, 0, 0, 0);
                    CGRect imagvFrame = CGRectMake(0, 0, action.image.size.width, action.image.size.height);
                    
                    CGFloat midX_titleLabel_sys = CGRectGetMidX(titleLabel_sys.frame);
                    CGFloat midX_imageView_sys = CGRectGetMidX(titleLabel_sys.frame);
                    
                    imagvFrame.origin.x = (midX_titleLabel_sys>midX_imageView_sys?midX_titleLabel_sys:midX_imageView_sys)-action.image.size.width/2.0;
                    imagvFrame.origin.y = (CGRectGetHeight(btn.bounds) - (action.titleFont.pointSize + image_title_space + action.image.size.height))/2.0;
                    
                    
                    titleLabelFrame.origin.y = imagvFrame.origin.y + imagvFrame.size.height + image_title_space;
                    titleLabelFrame.size.width = action.titleFont.pointSize * (action.title.length + 2);
                    titleLabelFrame.origin.x = imagvFrame.origin.x + CGRectGetWidth(imagvFrame)/2.0 - titleLabelFrame.size.width/2.0;

                    titleLabelFrame.size.height = action.titleFont.pointSize;
                    
                    if( [titleLabel_sys.text containsString:placeHolderStr] == YES){
                        imagvFrame.origin.y = CGRectGetHeight(bgView_sys.bounds)/2.0 - imagvFrame.size.height/2.0;
                    }
                    
                    imagvFrame.origin.x =  imagvFrame.origin.x+action.offset.x;
                    imagvFrame.origin.y =  imagvFrame.origin.y+action.offset.y;
                    
                    titleLabelFrame.origin.x = titleLabelFrame.origin.x + action.offset.x;
                    titleLabelFrame.origin.y = titleLabelFrame.origin.y + action.offset.y;
                    
                    
                    imageView_tj.frame = imagvFrame;
                    titleLabel_tj.frame = titleLabelFrame;
                     bgView_tj.frame = bgView_sys.frame;
                    
                }
            }
        }

    [self layoutSubviews_swizzle];
}

@end

