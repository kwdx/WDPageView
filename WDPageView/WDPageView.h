//
//  WDPageView.h
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPageConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol WDPageViewDelegate;

@interface WDPageView : UIView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig NS_DESIGNATED_INITIALIZER;

- (void)setTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<UIViewController *> *)viewControllers;

@property (nonatomic, weak) id<WDPageViewDelegate> delegate;

@property (nonatomic, assign, readonly) NSInteger currentIndex;
- (void)scrollToIndex:(NSUInteger)index;

@end

@protocol WDPageViewDelegate <NSObject>

@optional

- (void)pageView:(WDPageView *)pageView didSelectedIndex:(NSInteger)selectedIndex;
- (void)pageView:(WDPageView *)pageView scrollProgress:(CGFloat)progress fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

@end

NS_ASSUME_NONNULL_END
