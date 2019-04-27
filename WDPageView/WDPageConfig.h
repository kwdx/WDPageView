//
//  WDPageConfig.h
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, WDPageTitleLineStyle) {
    WDPageTitleLineStyleFlexible,   ///< 拉动
    WDPageTitleLineStyleSlide,      ///< 移动
};

@interface WDPageConfig : NSObject

+ (WDPageConfig *)defaultConfig;

@property (nonatomic, assign) CGFloat titleHeight;              ///< 分类导航栏高度
@property (nonatomic, assign) CGFloat titlePaddingLeft;         ///< 分类导航栏左间距，默认为10
@property (nonatomic, assign) CGFloat titlePaddingRight;        ///< 分类导航栏右间距，默认为10

@property (nonatomic, strong) UIFont *normalFont;               ///< 正常状态字体
@property (nonatomic, strong) UIFont *selectedFont;             ///< 选中状态字体
@property (nonatomic, strong) UIColor *normalColor;             ///< 正常状态字体颜色
@property (nonatomic, strong) UIColor *selectedColor;           ///< 选中状态字体颜色
@property (nonatomic, assign) CGFloat itemWidth;                ///< 分类Item宽度（0是自动，默认，会加上itemPadding）
@property (nonatomic, assign) CGFloat itemPaddingH;             ///< 分类Item水平内边距
@property (nonatomic, assign) CGFloat itemPaddingV;             ///< 分类Item垂直内边距
@property (nonatomic, assign) CGFloat itemMargin;               ///< 分类Item之间的边距
@property (nonatomic, assign) CGFloat itemHeight;               ///< 分类Item高度（不加itemPaddingV）

@property (nonatomic, strong) UIColor *lineColor;               ///< 线条颜色
@property (nonatomic, assign) CGFloat lineWidth;                ///< 线条宽度，0为Item宽度（不加itemPaddingH）
@property (nonatomic, assign) CGFloat lineHeight;               ///< 线条高度
@property (nonatomic, assign) CGFloat lineMarginTop;            ///< 线条距离分类Item的间距

@property (nonatomic, assign) WDPageTitleLineStyle lineStyle;   ///< 线条动画类型

@property (nonatomic, assign) BOOL contentScrollAnimation;      ///< 内容页是否有滑动效果

@end

NS_ASSUME_NONNULL_END
