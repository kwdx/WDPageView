//
//  ViewController.m
//  Demo
//
//  Created by warden on 2018/12/27.
//  Copyright © 2018 warden. All rights reserved.
//

#import "ViewController.h"
#import "WDPageView.h"
#import "AViewController.h"
#import <Masonry.h>

@interface ViewController ()

@property (nonatomic, strong) WDPageView *pageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.pageView];
    [self.pageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset([UIApplication sharedApplication].statusBarFrame.size.height);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(@(0));
        }
        make.left.right.equalTo(@(0));
    }];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//
//    CGRect frame = self.view.bounds;
//    frame.origin.y = 88;
//    frame.size.height -= 88 + 88;
//    self.pageView.frame = frame;
//}

#pragma mark - Getter

- (WDPageView *)pageView {
    if (!_pageView) {
        _pageView = [[WDPageView alloc] init];
        
        NSMutableArray *titleArr = [[NSMutableArray alloc] initWithCapacity:10];
        NSMutableArray *vcArr = [[NSMutableArray alloc] initWithCapacity:10];
        for (int i = 0; i < 10; i++) {
            AViewController *vc = [[AViewController alloc] init];
            NSString *title = [NSString stringWithFormat:@"标题%@", @(i)];
            vc.title = title;
            [titleArr addObject:title];
            [vcArr addObject:vc];
        }
        [_pageView setTitles:titleArr.copy viewControllers:vcArr.copy];
    }
    return _pageView;
}

@end
