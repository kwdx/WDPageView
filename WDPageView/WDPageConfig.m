//
//  WDPageConfig.m
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "WDPageConfig.h"

@implementation WDPageConfig

+ (WDPageConfig *)defaultConfig {
    WDPageConfig *defaultConfig = [[WDPageConfig alloc] init];
    defaultConfig.titleHeight = 46;
    defaultConfig.titlePaddingLeft = 10;
    defaultConfig.titlePaddingRight = 10;
    
    defaultConfig.normalFont = [UIFont systemFontOfSize:15];
    defaultConfig.selectedFont = [UIFont boldSystemFontOfSize:15];
    defaultConfig.normalColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    defaultConfig.selectedColor = [UIColor colorWithRed:0.976 green:0.227 blue:0.227 alpha:1.];
    defaultConfig.itemWidth = 0;
    defaultConfig.itemPaddingH = 50;
    defaultConfig.itemMargin = 0;
    defaultConfig.itemHeight = 22;
    
    defaultConfig.lineColor = defaultConfig.selectedColor;
    defaultConfig.lineWidth = 0;
    defaultConfig.lineHeight = 2;
    defaultConfig.lineMarginTop = 6;
    
    defaultConfig.contentScrollAnimation = NO;
    
    return defaultConfig;
}

@end
