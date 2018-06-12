//
//  ViewController.m
//  tableViewTestDemo
//
//  Created by 唐健 on 2018/6/9.
//  Copyright © 2018年 唐健. All rights reserved.
//

#import "ViewController.h"
#import "TestCell.h"
#import "NSObject+tj_swipeRowActions.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation ViewController
- (IBAction)refreshDataAction:(id)sender {
    [self.tableView reloadData];
}
- (IBAction)editdingAction:(UIButton *)sender {
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    sender.selected = !sender.selected;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    SwipeRowAction *action_1 = [SwipeRowAction swipeRowActionWithTitle:nil image:[UIImage imageNamed:@"a_show_delete"] backgroundColor:[UIColor magentaColor] titleColor:[UIColor blackColor] swipeRowAction:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        
        
    }];
    action_1.offset = CGPointMake(5, 10);
    
    SwipeRowAction *action_2 = [SwipeRowAction swipeRowActionWithTitle:@"哦哦" image:nil backgroundColor:[UIColor greenColor] titleColor:[UIColor redColor] swipeRowAction:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        
        
    }];
    
    SwipeRowAction *action_3 = [SwipeRowAction swipeRowActionWithTitle:nil image:[UIImage imageNamed:@"a_quote_delete"] backgroundColor:[UIColor grayColor] titleColor:[UIColor blackColor] swipeRowAction:^(UITableView *tableView, NSIndexPath *indexPath) {
        
        
        
    }];
    
    self.swipeRowActions = @[action_1,action_2,action_3];
    self.swipeRowActions = @[action_1,action_2,action_3];
    
    _dataSource = @[].mutableCopy;
    for(int i = 0 ; i < 20 ; i++){
        [_dataSource addObject:[NSString stringWithFormat:@"第%d个cell",i]];
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height - 50) style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.rowHeight = 90;
    [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([TestCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([TestCell class])];
    [self.view addSubview:_tableView];

    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TestCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([TestCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.dataSource[indexPath.row];
//    cell.shouldIndentWhileEditing = NO;
    return cell;
}

#pragma mark - tableView editting

// 8.0版本后加入的UITableViewRowAction不在这个回调的控制范围内，UITableViewRowAction有单独的回调Block。

//打开后 cell会变成可编辑
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *style = nil;
    switch (editingStyle) {
        case UITableViewCellEditingStyleNone:
            style = @"UITableViewCellEditingStyleNone";
            break;
        case UITableViewCellEditingStyleDelete:
            style = @"UITableViewCellEditingStyleDelete";
            break;
        case UITableViewCellEditingStyleInsert:
            style = @"UITableViewCellEditingStyleInsert";
            break;
            case UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete:
             style = @"UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete";
            break;
    }
    NSLog(@"commitEditingStyle%@",style);
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

}

// 这个回调实现了以后，就会出现更换位置的按钮，回调本身用来处理更换位置后的数据交换。
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
//    [self.dataSource exchangeObjectAtIndex:sourceIndexPath.row
//                         withObjectAtIndex:destinationIndexPath.row];
    
    id obj = self.dataSource[sourceIndexPath.row];
    [self.dataSource removeObject:obj];
    [self.dataSource insertObject:obj atIndex:destinationIndexPath.row];
}

// 这个回调决定了在当前indexPath的Cell是否可以编辑。
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

// 这个回调决定了在当前indexPath的Cell是否可以移动。
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSInteger i = indexPath.row%2;
//
//    return !((BOOL)i);
    return  YES;
}

// 这个回调很关键，返回Cell的编辑样式。
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger i = indexPath.row;
    UITableViewCellEditingStyle style =   UITableViewCellEditingStyleNone;
    switch (i%5) {
        case UITableViewCellEditingStyleNone:
            style = UITableViewCellEditingStyleNone;
            break;
            
        case UITableViewCellEditingStyleDelete:
            style = UITableViewCellEditingStyleDelete;
            break;
        case UITableViewCellEditingStyleInsert:
            style = UITableViewCellEditingStyleInsert;
            break;
        case 4:
            style = UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
            break;
    }
    return style;
}

// 删除按钮的文字
- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0) __TVOS_PROHIBITED{
    return [NSString stringWithFormat:@"删除_%@",_dataSource[indexPath.row]];
}

// 8.0后侧滑菜单的新接口，支持多个侧滑按钮。
//- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED{
//
//    /**
//     @property (nonatomic, readonly) UITableViewRowActionStyle style;
//     @property (nonatomic, copy, nullable) NSString *title;
//     @property (nonatomic, copy, nullable) UIColor *backgroundColor; // default background color is dependent on style
//     @property (nonatomic, copy, nullable) UIVisualEffect* backgroundEffect;
//     */
//
//
//    UITableViewRowAction *action_Normal = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Normal" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//    action_Normal.backgroundColor = [UIColor clearColor];
//    action_Normal.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//
//    UITableViewRowAction *action_Default = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Default" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//    UITableViewRowAction *action_Destructive = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Destructive" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//    }];
//
//
//    return @[action_Destructive,action_Default,action_Normal];
//}


//- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    UIContextualAction *Action_Normal = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"Action_Normal" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        
//    }];
//        Action_Normal.image = [UIImage imageNamed:@"a_quote_delete"];
//    Action_Normal.title = @"Action_Normal";
////    Action_Normal.backgroundColor = [UIColor greenColor];
//    
//    UIContextualAction *Action_Destructive = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Action_Destructive" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
//        
//    }];
//    Action_Destructive.title = @"Action_Destructive";
////    Action_Destructive.backgroundColor = [UIColor blueColor];
//    Action_Destructive.image = [UIImage imageNamed:@"a_show_delete"];
//    
//    
//    UISwipeActionsConfiguration *swipeActions = [UISwipeActionsConfiguration configurationWithActions:@[Action_Normal,Action_Destructive]];
//    swipeActions.performsFirstActionWithFullSwipe = NO;
//    return swipeActions;
//}

// 这个接口决定编辑状态下的Cell是否需要缩进。
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{

    return YES;
}

// 这是两个状态回调
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED{
    
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath __TVOS_PROHIBITED{
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
}


@end
