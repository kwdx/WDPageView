//
//  WDPageView.m
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "WDPageView.h"
#import "WDPageTitleView.h"
#import "WDPageContentView.h"

@interface WDPageView () <WDPageTitleViewDelegate, WDPageContentViewDelegate>

@property (nonatomic, strong) WDPageConfig *pageConfig;
@property (nonatomic, strong) WDPageTitleView *titleView;
@property (nonatomic, strong) WDPageContentView *contentView;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation WDPageView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig {
    if (self = [super initWithFrame:CGRectZero]) {
        self.pageConfig = pageConfig;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithPageConfig:[WDPageConfig defaultConfig]];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithPageConfig:[WDPageConfig defaultConfig]];
}

#pragma mark - UI Layout

- (void)setupSubviews {
    [self addSubview:self.titleView];
    [self addSubview:self.contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _titleView.frame = CGRectMake(0, 0, self.bounds.size.width, _pageConfig.titleHeight);
    _contentView.frame = CGRectMake(0, _pageConfig.titleHeight, self.bounds.size.width, self.bounds.size.height - _pageConfig.titleHeight);
}

#pragma mark - Public Method

- (void)scrollToIndex:(NSUInteger)index {
    if (index >= _titleView.titles.count) {
        return;
    }
    if (self.currentIndex == index) {
        return;
    }
    [_titleView scrollToIndex:index];
    [_contentView setCurrentIndex:index];
    _currentIndex = index;
}

#pragma mark - WDPageTitleViewDelegate

- (void)pageTitleView:(WDPageTitleView *)pageTitleView didSelectedIndex:(NSInteger)index {
    [_contentView setCurrentIndex:index];
    self.currentIndex = index;
}

#pragma mark - WDPageContentViewDelegate

- (void)pageContentView:(WDPageContentView *)pageContentView dragAtPageProgress:(CGFloat)pageProgress {
    [_titleView currentScrollAt:pageProgress];
    self.currentIndex = _titleView.currentIndex;
    if ([self.delegate respondsToSelector:@selector(pageView:dragAtPageProgress:)]) {
        [self.delegate pageView:self dragAtPageProgress:pageProgress];
    }
}

#pragma mark - Setter

- (void)setTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<UIViewController *> *)viewControllers {
    if (titles.count != viewControllers.count) {
        return;
    }
    _titleView.titles = titles;
    _contentView.childVCs = viewControllers;
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    if (_currentIndex == currentIndex) {
        return;
    }
    _currentIndex = currentIndex;
    if ([self.delegate respondsToSelector:@selector(pageView:didSelectedIndex:)]) {
        [self.delegate pageView:self didSelectedIndex:currentIndex];
    }
}

#pragma mark - Getter

- (WDPageTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[WDPageTitleView alloc] initWithPageConfig:self.pageConfig];
        _titleView.delegate = self;
    }
    return _titleView;
}

- (WDPageContentView *)contentView {
    if (!_contentView) {
        _contentView = [[WDPageContentView alloc] initWithPageConfig:self.pageConfig];
        _contentView.delegate = self;
    }
    return _contentView;
}

@end
