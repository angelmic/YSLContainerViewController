//
//  YSLContainerViewController.h
//  YSLContainerViewController
//
//  Created by yamaguchi on 2015/02/10.
//  Copyright (c) 2015年 h.yamaguchi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSLScrollMenuView;

@protocol YSLContainerViewControllerDelegate <NSObject>

- (void)containerViewItemIndex:(NSInteger)index currentController:(UIViewController *)controller;

@end

@interface YSLContainerViewController : UIViewController

@property (nonatomic, weak) id <YSLContainerViewControllerDelegate> delegate;

@property (nonatomic, strong) UIScrollView             *contentScrollView;
@property (nonatomic, strong, readonly) NSMutableArray *titles;
@property (nonatomic, strong, readonly) NSMutableArray *childControllers;

@property (nonatomic, strong) UIFont  *menuItemFont;
@property (nonatomic, strong) UIColor *menuItemTitleColor;
@property (nonatomic, strong) UIColor *menuItemSelectedTitleColor;
@property (nonatomic, strong) UIColor *menuBackGroudColor;
@property (nonatomic, strong) UIColor *menuIndicatorColor;

@property (nonatomic, assign) CGFloat menuViewHeight;
@property (nonatomic, assign) CGFloat scrollMenuViewWidth;
@property (nonatomic, assign) CGFloat menuIndicatorHeight;

- (instancetype)initWithControllers:(NSArray *)controllers topBarHeight:(CGFloat)topBarHeight parentViewController:(UIViewController *)parentViewController;

- (YSLScrollMenuView *)setupMenuView;
- (void)scrollMenuViewSelectedIndex:(NSInteger)index;

@end
