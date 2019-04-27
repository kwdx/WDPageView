//
//  WDPageContentView.m
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "WDPageContentView.h"

@interface WDPageContentView () <UIScrollViewDelegate>

@property (nonatomic, strong) WDPageConfig *pageConfig;

@property (nonatomic, assign) BOOL isClickScrollDelegate;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WDPageContentView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig {
    if (self = [self init]) {
        self.pageConfig = pageConfig;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - UI Layout

- (void)setupSubviews {
    [self addSubview:self.scrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _scrollView.frame = self.bounds;
    
    if (_childVCs.count > 0) {
        UIViewController *vc = _childVCs[self.currentIndex];
        frame.origin.x = self.currentIndex * frame.size.width;
        vc.view.frame = frame;
    }
    CGSize contentSize = CGSizeMake(frame.size.width * _childVCs.count, frame.size.height);
    _scrollView.contentSize = contentSize;
}

#pragma mark - Private

- (void)removeOtherView {
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isViewLoaded && self.currentIndex != idx) {
            [obj.view removeFromSuperview];
        }
    }];
}

#pragma mark - Public

- (void)setCurrentIndex:(NSUInteger)currentIndex {
    _isClickScrollDelegate = YES;
    
    CGFloat offsetX = currentIndex * _scrollView.frame.size.width;
    if (currentIndex >= 0 && currentIndex < _childVCs.count) {
        UIViewController *vc = _childVCs[currentIndex];
        [_scrollView addSubview:vc.view];
        CGRect frame = _scrollView.bounds;
        frame.origin.x = currentIndex * _scrollView.frame.size.width;
        vc.view.frame = frame;
    }
    if (_pageConfig.contentScrollAnimation) {
        [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    } else {
        _currentIndex = currentIndex;
        [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        [self removeOtherView];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isClickScrollDelegate = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 1.计算当前的index
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    NSInteger currentIdx = @(offsetX / scrollViewW).integerValue;
    if (offsetX != scrollViewW * currentIdx) {
        return;
    }

    _currentIndex = currentIdx;
    // 2.将其他页面移除
    [self removeOtherView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 1.计算当前的index
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    _currentIndex = @(offsetX / scrollViewW).integerValue;
    
    // 2.将其他页面移除
    [self removeOtherView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 0.判断是否是点击事件
    if (_isClickScrollDelegate) {
        return;
    }
    
    // 1.定义获取需要的数据
    CGFloat pageProgress = scrollView.contentOffset.x / scrollView.bounds.size.width;
    NSInteger left = 0;
    NSInteger right = 0;
    if (CGFLOAT_IS_DOUBLE) {
        left = @(floor(pageProgress)).integerValue;
        right = @(ceil(pageProgress)).integerValue;
    } else {
        left = @(floorf(pageProgress)).integerValue;
        right = @(ceilf(pageProgress)).integerValue;
    }
    
    if (right >= _childVCs.count || left < 0) {
        return;
    }
    
    _currentIndex = (pageProgress - left) > 0.5 ? right : left;
    
    // 2.将pageProgress传递出去
    if (self.delegate) {
        [self.delegate pageContentView:self dragAtPageProgress:pageProgress];
    }
    
    if (left != right) {
        UIViewController *leftVC = _childVCs[left];
        UIViewController *rightVC = _childVCs[right];
        CGRect frame = _scrollView.bounds;
        frame.origin.x = left * frame.size.width;
        leftVC.view.frame = frame;
        frame.origin.x += frame.size.width;
        rightVC.view.frame = frame;
        [_scrollView addSubview:leftVC.view];
        [_scrollView addSubview:rightVC.view];
    } else {
        UIViewController *leftVC = _childVCs[left];
        CGRect frame = _scrollView.bounds;
        frame.origin.x = left * frame.size.width;
        leftVC.view.frame = frame;
        [_scrollView addSubview:leftVC.view];
    }
}

#pragma mark - Setter

- (void)setChildVCs:(NSArray<UIViewController *> *)childVCs {
    _childVCs = childVCs;
    
    NSArray *subviews = _scrollView.subviews;
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    _currentIndex = 0;
    [_scrollView addSubview:childVCs.firstObject.view];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [_scrollView setContentOffset:CGPointZero];
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

@end
