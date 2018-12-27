//
//  WDPageConfig.m
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "WDPageConfig.h"

@implementation WDPageColor

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDPageColor *color = [[WDPageColor allocWithZone:zone] init];
    color.red = self.red;
    color.green = self.green;
    color.blue = self.blue;
    return color;
}

- (UIColor *)color {
    return [UIColor colorWithRed:(self.red/255.0) green:(self.green/255.0) blue:(self.blue/255.0) alpha:1];
}

+ (WDPageColor *)normalColor {
    return [self colorWithRed:102 green:102 blue:102];
}

+ (WDPageColor *)selectedColor {
    return [self colorWithRed:249 green:58 blue:58];
}

+ (WDPageColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    WDPageColor *pageColor = [WDPageColor new];
    pageColor.red = red;
    pageColor.green = green;
    pageColor.blue = blue;
    
    return pageColor;
}

@end

@implementation WDPageFont

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    WDPageFont *font = [[WDPageFont allocWithZone:zone] init];
    font.fontSize = self.fontSize;
    font.fontWeight = self.fontWeight;
    return font;
}

+ (WDPageFont *)normalFont {
    return [self fontWithSize:15 weight:UIFontWeightRegular];
}

+ (WDPageFont *)selectedFont {
    return [self fontWithSize:15 weight:UIFontWeightHeavy];
}

+ (WDPageFont *)fontWithSize:(CGFloat)fontSize weight:(CGFloat)fontWeight {
    WDPageFont *font = [WDPageFont new];
    font.fontSize = fontSize;
    font.fontWeight = fontWeight;
    return font;
}

- (UIFont *)font {
    return [UIFont systemFontOfSize:self.fontSize weight:self.fontWeight];
}

@end

@implementation WDPageConfig

+ (WDPageConfig *)defaultConfig {
    WDPageConfig *defaultConfig = [[WDPageConfig alloc] init];
    defaultConfig.titleHeight = 46;
    defaultConfig.titlePaddingLeft = 10;
    defaultConfig.titlePaddingRight = 10;
    
    defaultConfig.normalFont = [WDPageFont normalFont];
    defaultConfig.selectedFont = [WDPageFont selectedFont];
    defaultConfig.normalColor = [WDPageColor normalColor];
    defaultConfig.selectedColor = [WDPageColor selectedColor];
    defaultConfig.itemWidth = 0;
    defaultConfig.itemPaddingH = 50;
    defaultConfig.itemMargin = 0;
    defaultConfig.itemHeight = 22;
    
    defaultConfig.lineColor = defaultConfig.selectedColor.color;
    defaultConfig.lineWidth = 0;
    defaultConfig.lineHeight = 2;
    defaultConfig.lineMarginTop = 6;
    defaultConfig.bottomLineColor = [UIColor colorWithRed:0.855 green:0.855 blue:0.855 alpha:1.00];
    
    defaultConfig.contentScrollAnimation = NO;
    
    return defaultConfig;
}

@end
