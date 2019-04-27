//
//  WDPageTitleView.h
//  WDPageView
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPageConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class WDPageTitleView;

@protocol WDPageTitleViewDelegate <NSObject>

@optional

- (void)pageTitleView:(WDPageTitleView *)pageTitleView didSelectedIndex:(NSInteger)index;

@end

@interface WDPageTitleView : UIView

- (instancetype)initWithPageConfig:(WDPageConfig *)pageConfig;

@property (nonatomic, weak) id<WDPageTitleViewDelegate> delegate;

@property (nonatomic, strong, nullable) NSArray<NSString *> *titles;
@property (nonatomic, assign, readonly) NSInteger currentIndex;

- (void)scrollToIndex:(NSInteger)toIndex;
- (void)currentScrollAt:(CGFloat)pageFloat;

@end

NS_ASSUME_NONNULL_END
