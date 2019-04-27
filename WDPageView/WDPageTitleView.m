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

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *titleLabels;
@property (nonatomic, strong) UIView *scrollLine;

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
    
    CGFloat itemHeight = _pageConfig.itemHeight + _pageConfig.itemPaddingV * 2;
    CGFloat itemY = (self.frame.size.height - itemHeight) / 2;
    for (UILabel *label in _titleLabels) {
        CGRect labelFrame = label.frame;
        labelFrame.origin.y = itemY;
        label.frame = labelFrame;
    }
    if (_currentIndex < _titleLabels.count) {
        UILabel *label = _titleLabels[_currentIndex];
        CGRect scrollLineFrame = _scrollLine.frame;
        scrollLineFrame.origin.y = CGRectGetMaxY(label.frame) + _pageConfig.lineMarginTop;
        _scrollLine.frame = scrollLineFrame;
    } else {
        _scrollLine.frame = CGRectZero;
    }
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
    if (currentLabel.tag == _currentIndex) {
        return;
    }
    
    // 2.滑动到当前index
    [self scrollToIndex:currentLabel.tag];
    
    // 3.通知代理
    if (self.delegate) {
        [self.delegate pageTitleView:self didSelectedIndex:_currentIndex];
    }
}

#pragma mark - Public

- (void)scrollToIndex:(NSInteger)index {
    if (index >= _titleLabels.count) {
        return;
    }
    UILabel *currentLabel = _titleLabels[index];
    _currentIndex = index;
    CGRect frame = [self getScrollLineFrameForLabel:currentLabel];
    
    CGFloat scrollWidth = _scrollView.frame.size.width;
    CGFloat maxOffsetX = _scrollView.contentSize.width - scrollWidth;
    CGFloat offsetX = currentLabel.center.x - scrollWidth * 0.5;
    offsetX = MIN(MAX(maxOffsetX, 0), MAX(offsetX, 0));
    
    [UIView animateWithDuration:0.25 animations:^{
        currentLabel.textColor = self.pageConfig.selectedColor;
        currentLabel.font = self.pageConfig.selectedFont;
        self.scrollLine.frame = frame;
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    }];
    
    for (UILabel *label in self.titleLabels) {
        if (label != currentLabel) {
            label.textColor = _pageConfig.normalColor;
            label.font = _pageConfig.normalFont;
        }
    }
}

- (void)currentScrollAt:(CGFloat)pageFloat {
    NSInteger left = 0;
    NSInteger right = 0;
    if (CGFLOAT_IS_DOUBLE) {
        left = @(floor(pageFloat)).integerValue;
        right = @(ceil(pageFloat)).integerValue;
    } else {
        left = @(floorf(pageFloat)).integerValue;
        right = @(ceilf(pageFloat)).integerValue;
    }
    if (right >= self.titles.count || left < 0) {
        return;
    }
    CGFloat progress = pageFloat - left;
    if (left == right) {
        progress = 1;
    }
    [self scrollBetween:left and:right withProgress:progress];
}

#pragma mark - Private

- (void)scrollBetween:(NSInteger)left and:(NSInteger)right withProgress:(CGFloat)progress {
    NSInteger leftIndex = left < right ? left : right;
    NSInteger rightIndex = left < right ? right : left;
    
    UILabel *leftLabel = _titleLabels[leftIndex];
    UILabel *rightLabel = _titleLabels[rightIndex];
    
    CGRect lineFrame = [self getScrollLineFrameForLabel:leftLabel];
    CGRect toLineFrame = [self getScrollLineFrameForLabel:rightLabel];
    if (_pageConfig.lineStyle == WDPageTitleLineStyleFlexible) {
        if (progress <= 0.5) {
            lineFrame.size.width += (CGRectGetMaxX(toLineFrame) - CGRectGetMaxX(lineFrame)) * (progress / 0.5);
        } else {
            lineFrame.size.width = (toLineFrame.origin.x - lineFrame.origin.x) * ((1 - progress) / 0.5) + toLineFrame.size.width;
            lineFrame.origin.x = CGRectGetMaxX(toLineFrame) - lineFrame.size.width;
        }
    } else {
        lineFrame.origin.x -= (lineFrame.origin.x - toLineFrame.origin.x) * progress;
        lineFrame.size.width -= (lineFrame.size.width - toLineFrame.size.width) * progress;
    }
    _scrollLine.frame = lineFrame;
    
    CGFloat r1, g1, b1, a1;
    CGFloat r2, g2, b2, a2;
    [_pageConfig.selectedColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [_pageConfig.normalColor getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat deltaR = r1 - r2;
    CGFloat deltaG = g1 - g2;
    CGFloat deltaB = b1 - b2;
    CGFloat deltaA = a1 - a2;
    UIColor *leftColor = [UIColor colorWithRed:(r1 - deltaR * progress) green:(g1 - deltaG * progress) blue:(b1 - deltaB * progress) alpha:(a1 - deltaA * progress)];
    UIColor *rightColor = [UIColor colorWithRed:(r2 + deltaR * progress) green:(g2 + deltaG * progress) blue:(b2 + deltaB * progress) alpha:(a2 + deltaA * progress)];
    
    UIFont *leftFont = _pageConfig.selectedFont;
    UIFont *rightFont = _pageConfig.normalFont;
    if (progress > 0.5) {
        leftFont = _pageConfig.normalFont;
        rightFont = _pageConfig.selectedFont;
    }
    
    for (UILabel *label in _titleLabels) {
        if (label == leftLabel && label != rightLabel) {
            leftLabel.textColor = leftColor;
            leftLabel.font = leftFont;
        } else if (label == rightLabel) {
            rightLabel.textColor = rightColor;
            rightLabel.font = rightFont;
        } else {
            label.textColor = _pageConfig.normalColor;
            label.font = _pageConfig.normalFont;
        }
    }
    
    _currentIndex = progress > 0.5 ? rightIndex : leftIndex;
    
    CGFloat scrollWidth = _scrollView.frame.size.width;
    if (scrollWidth > 0) {
        CGFloat leftOffSetX = leftLabel.center.x - scrollWidth * 0.5;
        CGFloat rightOffsetX = rightLabel.center.x - scrollWidth * 0.5;
        
        CGFloat maxOffsetX = _scrollView.contentSize.width - scrollWidth;
        
        CGFloat offsetX = leftOffSetX + (rightOffsetX - leftOffSetX) * progress;
        offsetX = MIN(MAX(maxOffsetX, 0), MAX(offsetX, 0));
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
        label.font = self.pageConfig.normalFont;
        label.textColor = self.pageConfig.normalColor;
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
        firstLabel.textColor = _pageConfig.selectedColor;
        firstLabel.font = _pageConfig.selectedFont;
        _scrollLine.frame = [self getScrollLineFrameForLabel:firstLabel];
    }
    _scrollView.contentOffset = CGPointZero;
    _currentIndex = 0;
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.scrollsToTop = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
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
