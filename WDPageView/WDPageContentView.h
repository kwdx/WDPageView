//
//  WDPageContentView.h
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPageConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class WDPageContentView;

@protocol WDPageContentViewDelegate <NSObject>

@optional

- (void)pageContentView:(WDPageContentView *)pageContentView dragAtPageProgress:(CGFloat)pageProgress;

@end

@interface WDPageContentView : UIView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig;

@property (nonatomic, weak) id<WDPageContentViewDelegate> delegate;

@property (nonatomic, strong) NSArray<UIViewController *> *childVCs;

@property (nonatomic, assign) NSUInteger currentIndex;

@end

NS_ASSUME_NONNULL_END
