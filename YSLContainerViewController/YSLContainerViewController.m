//
//  YSLContainerViewController.m
//  YSLContainerViewController
//
//  Created by yamaguchi on 2015/02/10.
//  Copyright (c) 2015年 h.yamaguchi. All rights reserved.
//

#import "YSLContainerViewController.h"
#import "YSLScrollMenuView.h"

static const CGFloat kYSLScrollMenuViewHeight = 40;

@interface YSLContainerViewController () <UIScrollViewDelegate, YSLScrollMenuViewDelegate>

@property (nonatomic, assign) CGFloat           topBarHeight;
@property (nonatomic, assign) NSInteger         currentIndex;
@property (nonatomic, strong) YSLScrollMenuView *menuView;

@end

@implementation YSLContainerViewController

#pragma mark -- LifeCycle
- (instancetype)initWithControllers:(NSArray *)controllers topBarHeight:(CGFloat)topBarHeight parentViewController:(UIViewController *)parentViewController
{
    self = [super init];
    
    if (self == nil) {
        return nil;
    }
    
    [parentViewController addChildViewController:self];
    [self didMoveToParentViewController:parentViewController];
    
    _topBarHeight     = topBarHeight;
    _titles           = [[NSMutableArray alloc] init];
    _childControllers = [[NSMutableArray alloc] init];
    _childControllers = [controllers mutableCopy];
    
    NSMutableArray *titles = [NSMutableArray array];
    for (UIViewController *vc in _childControllers) {
        [titles addObject:[vc valueForKey:@"title"]];
    }
    _titles = [titles mutableCopy];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setupViews
    UIView *viewCover = [[UIView alloc] init];
    
    [self.view addSubview:viewCover];
    
    // ContentScrollview setup
    _contentScrollView = [[UIScrollView alloc] init];
    
    _contentScrollView.frame = CGRectMake(0,
                                          _topBarHeight + kYSLScrollMenuViewHeight,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height - (_topBarHeight + kYSLScrollMenuViewHeight));
    
    _contentScrollView.backgroundColor = [UIColor clearColor];
    _contentScrollView.pagingEnabled   = YES;
    _contentScrollView.delegate        = self;
    _contentScrollView.scrollsToTop    = NO;
    
    _contentScrollView.showsHorizontalScrollIndicator = NO;
    
    [self.view addSubview:_contentScrollView];
    
    _contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width * self.childControllers.count, _contentScrollView.frame.size.height);
    
    // ContentViewController setup
    [self.childControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController*)obj;
            
            CGFloat scrollWidth = _contentScrollView.frame.size.width;
            CGFloat scrollHeght = _contentScrollView.frame.size.height;
            
            controller.view.frame = CGRectMake(idx * scrollWidth, 0, scrollWidth, scrollHeght);
            
            [_contentScrollView addSubview:controller.view];
        }
    }];
    
    // meunView
    _menuView = [self setupMenuView];

    [self.view addSubview:_menuView];
    
    [_menuView setShadowView];
    
    [self scrollMenuViewSelectedIndex:0];
}

#pragma mark -- private
- (void)setChildViewControllerWithCurrentIndex:(NSInteger)currentIndex
{
    [self.childControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController*)obj;
            
            if (idx == currentIndex) {
                [controller willMoveToParentViewController:self];
                [self addChildViewController:controller];
                [controller didMoveToParentViewController:self];
            } else {
                [controller willMoveToParentViewController:self];
                [controller removeFromParentViewController];
                [controller didMoveToParentViewController:self];
            }
        }
    }];
}

#pragma mark -- public
- (YSLScrollMenuView *)setupMenuView
{
    YSLScrollMenuView *menuView = [[YSLScrollMenuView alloc] initWithFrame:CGRectMake(0, _topBarHeight, self.view.frame.size.width, kYSLScrollMenuViewHeight)];
    
    menuView.kYSLScrollMenuViewWidth  = 90.0;
    menuView.kYSLIndicatorHeight      = 3.0;
    menuView.kYSLScrollMenuViewMargin = 10.0;
    
    menuView.backgroundColor    = [UIColor clearColor];
    menuView.delegate           = self;
    menuView.viewbackgroudColor = self.menuBackGroudColor;
    menuView.itemfont           = self.menuItemFont;
    menuView.itemTitleColor     = self.menuItemTitleColor;
    menuView.itemIndicatorColor = self.menuIndicatorColor;
    
    menuView.scrollView.scrollsToTop = NO;
    
    [menuView setItemTitleArray:self.titles];
    
    return menuView;
}

#pragma mark -- YSLScrollMenuView Delegate

- (void)scrollMenuViewSelectedIndex:(NSInteger)index
{
    [_contentScrollView setContentOffset:CGPointMake(index * _contentScrollView.frame.size.width, 0.) animated:YES];
    
    // item color
    [_menuView setItemTextColor:self.menuItemTitleColor
           seletedItemTextColor:self.menuItemSelectedTitleColor
                   currentIndex:index];
    
    [self setChildViewControllerWithCurrentIndex:index];
    
    if (index == self.currentIndex) { return; }
    self.currentIndex = index;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewItemIndex:currentController:)]) {
        [self.delegate containerViewItemIndex:self.currentIndex currentController:_childControllers[self.currentIndex]];
    }
}

#pragma mark -- ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat oldPointX = self.currentIndex * scrollView.frame.size.width;
    CGFloat ratio     = (scrollView.contentOffset.x - oldPointX) / scrollView.frame.size.width;
    
    BOOL isToNextItem     = (_contentScrollView.contentOffset.x > oldPointX);
    NSInteger targetIndex = (isToNextItem) ? self.currentIndex + 1 : self.currentIndex - 1;
    
    CGFloat nextItemOffsetX    = 1.0f;
    CGFloat currentItemOffsetX = 1.0f;
    
    nextItemOffsetX    = (_menuView.scrollView.contentSize.width - _menuView.scrollView.frame.size.width) * targetIndex / (_menuView.itemViewArray.count - 1);
    currentItemOffsetX = (_menuView.scrollView.contentSize.width - _menuView.scrollView.frame.size.width) * self.currentIndex / (_menuView.itemViewArray.count - 1);
    
    if (targetIndex >= 0 && targetIndex < self.childControllers.count) {
        // MenuView Move
        CGFloat indicatorUpdateRatio = ratio;
        if (isToNextItem) {
            
            CGPoint offset = _menuView.scrollView.contentOffset;
            offset.x = (nextItemOffsetX - currentItemOffsetX) * ratio + currentItemOffsetX;
            [_menuView.scrollView setContentOffset:offset animated:NO];
            
            indicatorUpdateRatio = indicatorUpdateRatio * 1;
            [_menuView setIndicatorViewFrameWithRatio:indicatorUpdateRatio isNextItem:isToNextItem toIndex:self.currentIndex];
        } else {
            
            CGPoint offset = _menuView.scrollView.contentOffset;
            offset.x = currentItemOffsetX - (nextItemOffsetX - currentItemOffsetX) * ratio;
            [_menuView.scrollView setContentOffset:offset animated:NO];
            
            indicatorUpdateRatio = indicatorUpdateRatio * -1;
            [_menuView setIndicatorViewFrameWithRatio:indicatorUpdateRatio isNextItem:isToNextItem toIndex:targetIndex];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentIndex = scrollView.contentOffset.x / _contentScrollView.frame.size.width;
    
    if (currentIndex == self.currentIndex) {
        return;
    }
    
    self.currentIndex = currentIndex;
    
    // item color
    [_menuView setItemTextColor:self.menuItemTitleColor
           seletedItemTextColor:self.menuItemSelectedTitleColor
                   currentIndex:currentIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(containerViewItemIndex:currentController:)]) {
        [self.delegate containerViewItemIndex:self.currentIndex currentController:_childControllers[self.currentIndex]];
    }
    
    [self setChildViewControllerWithCurrentIndex:self.currentIndex];
}

@end
