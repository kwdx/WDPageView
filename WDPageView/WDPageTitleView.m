//
//  WDPageTitleView.m
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "WDPageTitleView.h"

@interface WDPageTitleView ()

@property (nonatomic, strong) WDPageConfig *pageConfig;

@property (nonatomic, assign) NSInteger currentIdx;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *titleLabels;
@property (nonatomic, strong) UIView *scrollLine;
@property (nonatomic, strong) UIView *bottomLine;

@end

@implementation WDPageTitleView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig {
    if (self = [self init]) {
        self.pageConfig = pageConfig;
        [self setupSubviews];
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark - UI Layout

- (void)setupSubviews {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
}

#pragma mark - Event

- (void)titleLabelClick:(UITapGestureRecognizer *)tap {
    // 0. 获取当前点击的Label
    UILabel *currentLabel = (UILabel *)tap.view;
    if (![currentLabel isKindOfClass:UILabel.class]) {
        return;
    }
    
    // 1.如果是重复点击用一个title，那么直接返回
    if (currentLabel.tag == _currentIdx) {
        return;
    }
    
    // 2.获取之前的label
    UILabel *oldLabel = self.titleLabels[_currentIdx];
    
    // 3.保存最新label的下标
    _currentIdx = currentLabel.tag;
    
    // 4.计算滚动条位置
    CGRect frame = [self getScrollLineFrameForLabel:currentLabel];

    // 动画
    [UIView animateWithDuration:0.25 animations:^{
        // 5.切换字体颜色
        oldLabel.textColor = self.pageConfig.normalColor.color;
        oldLabel.font = self.pageConfig.normalFont.font;
        currentLabel.textColor = self.pageConfig.selectedColor.color;
        currentLabel.font = self.pageConfig.selectedFont.font;

        // 6.滚动条位置发生改变
        self.scrollLine.frame = frame;
    }];
    
    for (UILabel *label in self.titleLabels) {
        if (label != currentLabel && label != oldLabel) {
            label.textColor = _pageConfig.normalColor.color;
            label.font = _pageConfig.normalFont.font;
        }
    }
    
    // 7.通知代理
    if (self.delegate) {
        [self.delegate pageTitleView:self didSelectedIndex:_currentIdx];
    }
    
    CGFloat scrollWidth = _scrollView.frame.size.width;
    if (scrollWidth > 0) {
        CGFloat offsetX = currentLabel.center.x - scrollWidth * 0.5;
        
        CGFloat maxOffsetX = _scrollView.contentSize.width - scrollWidth;
        offsetX = MIN(maxOffsetX, MAX(offsetX, 0));
        
        [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
}

#pragma mark - Public

- (void)setTitleWithProgress:(CGFloat)progress sourceIndex:(NSInteger)sourceIndex targetIndex:(NSInteger)targetIndex {
    // 1.取出sourceLabel/targetLabel
    UILabel *sourceLabel = self.titleLabels[sourceIndex];
    UILabel *targetLabel = self.titleLabels[targetIndex];
    
    // 2.处理滑块的逻辑
    CGRect scrollLineFrame = [self getScrollLineFrameForLabel:sourceLabel];
    CGRect sourceFrame = [self getScrollLineFrameForLabel:sourceLabel];
    CGRect targetFrame = [self getScrollLineFrameForLabel:targetLabel];
    scrollLineFrame.origin.x -= (sourceFrame.origin.x - targetFrame.origin.x) * progress;
    scrollLineFrame.size.width -= (sourceFrame.size.width - targetFrame.size.width) * progress;
    self.scrollLine.frame = scrollLineFrame;
    
    // 3.颜色的渐变
    // 3.1 取出变化的范围
    WDPageColor *sourceColor = self.pageConfig.selectedColor.copy;
    WDPageColor *targetColor = self.pageConfig.normalColor.copy;
    WDPageFont *sourceFont = self.pageConfig.selectedFont.copy;
    WDPageFont *targetFont = self.pageConfig.normalFont.copy;
    CGFloat deltaRed = sourceColor.red - targetColor.red;
    CGFloat deltaGreen = sourceColor.green - targetColor.green;
    CGFloat deltaBlue = sourceColor.blue - targetColor.blue;
    CGFloat deltaFontSize = sourceFont.fontSize - targetFont.fontSize;
    CGFloat deltaFontWeight = sourceFont.fontWeight - targetFont.fontWeight;
    sourceColor.red -= deltaRed * progress;
    sourceColor.green -= deltaGreen * progress;
    sourceColor.blue -= deltaBlue * progress;
    targetColor.red += deltaRed * progress;
    targetColor.green += deltaGreen * progress;
    targetColor.blue += deltaBlue * progress;
    sourceFont.fontSize -= deltaFontSize * progress;
    sourceFont.fontWeight -= deltaFontWeight * progress;
    targetFont.fontSize += deltaFontSize * progress;
    targetFont.fontWeight += deltaFontWeight * progress;

    // 3.2 变化sourceLabel
    sourceLabel.textColor = sourceColor.color;
    sourceLabel.font = sourceFont.font;
    // 3.3 变化sourceLabel
    targetLabel.textColor = targetColor.color;
    targetLabel.font = targetFont.font;

    NSInteger start = MAX(0, MIN(sourceIndex, targetIndex) - 1);
    NSInteger end = MIN(self.titleLabels.count - 1, MAX(sourceIndex, targetIndex) + 1);
    for (NSInteger i = start; i <= end; i++) {
        UILabel *label = self.titleLabels[i];
        if (label == sourceLabel && label != targetLabel) {
            sourceLabel.textColor = sourceColor.color;
            sourceLabel.font = sourceFont.font;
        } else if (label == targetLabel) {
            targetLabel.textColor = targetColor.color;
            targetLabel.font = targetFont.font;
        } else {
            label.font = self.pageConfig.normalFont.font;
            label.textColor = self.pageConfig.normalColor.color;
        }
    }
    
    // 4.记录最新的index
    _currentIdx = targetIndex;

    CGFloat scrollWidth = _scrollView.frame.size.width;
    if (scrollWidth > 0) {
        CGFloat sourceOffsetX = sourceLabel.center.x - scrollWidth * 0.5;
        CGFloat targetOffsetX = targetLabel.center.x - scrollWidth * 0.5;
        
        CGFloat maxOffsetX = _scrollView.contentSize.width - scrollWidth;
        sourceOffsetX = MIN(maxOffsetX, MAX(sourceOffsetX, 0));
        targetOffsetX = MIN(maxOffsetX, MAX(targetOffsetX, 0));

        CGFloat offsetX = sourceOffsetX + (targetOffsetX - sourceOffsetX) * progress;
        
        _scrollView.contentOffset = CGPointMake(offsetX, 0);
    }
}

#pragma mark - Setter

- (void)setTitles:(NSArray<NSString *> *)titles {
    _titles = titles;
    for (UIView *subview in self.titleLabels) {
        [subview removeFromSuperview];
    }
    self.titleLabels = nil;
    
    __block CGFloat itemX = _pageConfig.titlePaddingLeft;
    CGFloat itemPadding = _pageConfig.itemPaddingH;
    CGFloat itemMargin = _pageConfig.itemMargin;
    CGFloat itemWidth = _pageConfig.itemWidth;
    CGFloat itemHeight = _pageConfig.itemHeight + _pageConfig.itemPaddingV * 2;
    CGFloat itemY = (_pageConfig.titleHeight - itemHeight) / 2;

    NSMutableArray *labels = [[NSMutableArray alloc] initWithCapacity:titles.count];
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.text = obj;
        label.tag = idx;
        label.font = self.pageConfig.normalFont.font;
        label.textColor = self.pageConfig.normalColor.color;
        label.textAlignment = NSTextAlignmentCenter;
        
        [label sizeToFit];
        if (itemWidth == 0) {
            // 自适应
            label.frame = CGRectMake(itemX, itemY, label.frame.size.width + itemPadding * 2, itemHeight);
        } else {
            label.frame = CGRectMake(itemX, itemY, itemWidth + itemPadding * 2, itemHeight);
        }
        itemX += label.frame.size.width + itemMargin;
        
        // 给Label添加手势
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleLabelClick:)];
        [label addGestureRecognizer:tap];
        
        [self.scrollView addSubview:label];
        [labels addObject:label];
    }];

    _scrollView.contentSize = CGSizeMake(itemX - itemMargin + _pageConfig.titlePaddingRight, _pageConfig.titleHeight);
    if (labels.count > 0) {
        self.titleLabels = [NSArray arrayWithArray:labels];
        self.scrollLine.hidden = NO;
    } else {
        self.scrollLine.hidden = YES;
    }
    
    // 默认第一个Label
    UILabel *firstLabel = labels.firstObject;
    if (firstLabel) {
        firstLabel.textColor = _pageConfig.selectedColor.color;
        firstLabel.font = _pageConfig.selectedFont.font;
        _scrollLine.frame = [self getScrollLineFrameForLabel:firstLabel];
    }
    _scrollView.contentOffset = CGPointZero;
    _currentIdx = 0;
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.scrollsToTop = NO;
    }
    return _scrollView;
}

- (UIView *)scrollLine {
    if (!_scrollLine) {
        _scrollLine = [[UIView alloc] init];
        _scrollLine.backgroundColor = self.pageConfig.lineColor;
    }
    return _scrollLine;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = self.pageConfig.bottomLineColor;
    }
    return _bottomLine;
}

- (CGRect)getScrollLineFrameForLabel:(UILabel *)label {
    CGPoint origin = label.frame.origin;
    CGSize size = label.frame.size;
    if (_pageConfig.lineWidth == 0) {
        return CGRectMake(origin.x + _pageConfig.itemPaddingH, origin.y + size.height + _pageConfig.lineMarginTop, size.width - _pageConfig.itemPaddingH * 2, _pageConfig.lineHeight);
    } else {
        return CGRectMake(origin.x + (size.width - _pageConfig.lineWidth) / 2, origin.y + size.height + _pageConfig.lineMarginTop, _pageConfig.lineWidth, _pageConfig.lineHeight);
    }
}

@end
