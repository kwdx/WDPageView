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

@property (nonatomic, assign) CGFloat startOffsetX;
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
    
    _startOffsetX = scrollView.contentOffset.x;
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
    CGFloat progress = 0;
    NSInteger sourceIndex = 0;
    NSInteger targetIndex = 0;
    
    // 2.判断是左滑还是右滑
    CGFloat currentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollViewW = scrollView.bounds.size.width;
    
    if (currentOffsetX > _startOffsetX) {   // 左滑
        // 1.计算progress
        progress = (currentOffsetX / scrollViewW) - floor(currentOffsetX / scrollViewW);
        
        // 2.计算sourceIndex
        sourceIndex = @(currentOffsetX / scrollViewW).integerValue;
    
        // 3.计算targetIndex
        targetIndex = sourceIndex + 1;
        if (targetIndex >= _childVCs.count) {
            targetIndex = _childVCs.count - 1;
        }

        // 4.如果完全划过去了，就停止吧
        if (currentOffsetX - _startOffsetX == scrollViewW) {
            _startOffsetX = currentOffsetX;
            progress = 1;
            targetIndex = sourceIndex;
        }
    } else {    // 右滑
        // 1.计算progress
        progress = 1 - ((currentOffsetX / scrollViewW) - floor(currentOffsetX / scrollViewW));
        
        // 2.计算sourceIndex
        targetIndex = @(currentOffsetX / scrollViewW).integerValue;
        
        // 3.计算sourceIndex
        sourceIndex = targetIndex + 1;
        if (sourceIndex >= _childVCs.count) {
            sourceIndex = _childVCs.count - 1;
        }
    
        // 4.如果完全划过去了，就停止吧
        if (_startOffsetX - currentOffsetX == scrollViewW) {
            _startOffsetX = currentOffsetX;
            progress = 1;
            sourceIndex = targetIndex;
        }
    }

    if (targetIndex < _childVCs.count && targetIndex >= 0) {
        UIViewController *vc = _childVCs[targetIndex];
        [_scrollView addSubview:vc.view];
        CGRect frame = _scrollView.bounds;
        frame.origin.x = targetIndex * _scrollView.frame.size.width;
        vc.view.frame = frame;
    }
    
    if (sourceIndex == targetIndex) {
        progress = 1;
    }
    // 3.将progress/sourceIndex/targetIndex传递给titleView
    if (self.delegate) {
        [self.delegate pageContentView:self dragProgress:progress sourceIndex:sourceIndex targetIndex:targetIndex];
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
    }
    return _scrollView;
}

@end
