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

@interface WDPageView : UIView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig NS_DESIGNATED_INITIALIZER;

- (void)setTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<UIViewController *> *)viewControllers;

- (void)scrollToIndex:(NSUInteger)index;
- (NSUInteger)currentIndx;

@end

NS_ASSUME_NONNULL_END
