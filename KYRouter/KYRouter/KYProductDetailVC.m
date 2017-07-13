//
//  KYProductDetailVC.m
//  KYRouter
//
//  Created by kingly on 2017/7/13.
//  Copyright © 2017年 KYRouter Software https://github.com/kingly09/KYRouter by kingly inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE. . All rights reserved.
//

#import "KYProductDetailVC.h"
#import "ViewController.h"
#import "KYRouter.h"

@interface KYProductDetailVC ()
@property (nonatomic) UITextView *resultTextView;
@property (nonatomic) SEL selectedSelector;
@end

@implementation KYProductDetailVC

+ (void)load
{
    KYProductDetailVC *detailViewController = [[KYProductDetailVC alloc] init];
    [ViewController registerWithTitle:@"产品详情" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoProductDetailUsage);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"产品详情 搜索" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoProductUsage);
        return detailViewController;
    }];
    
     [ViewController registerWithTitle:@"产品详情 带有用户" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoProductUserInfoUsage);
        return detailViewController;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239.f/255 green:239.f/255 blue:244.f/255 alpha:1];
    [self.view addSubview:self.resultTextView];
    // Do any additional setup after loading the view.
    
    self.title = @"产品详情";
}

- (void)appendLog:(NSString *)log
{
    NSString *currentLog = self.resultTextView.text;
    if (currentLog.length) {
        currentLog = [currentLog stringByAppendingString:[NSString stringWithFormat:@"\n----------\n%@", log]];
    } else {
        currentLog = log;
    }
    self.resultTextView.text = currentLog;
    [self.resultTextView sizeThatFits:CGSizeMake(self.view.frame.size.width, CGFLOAT_MAX)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.resultTextView.subviews enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            // 这个是为了去除显示图片时，添加的 imageView
            [obj removeFromSuperview];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.resultTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self performSelector:self.selectedSelector withObject:nil afterDelay:0];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.resultTextView removeObserver:self forKeyPath:@"contentSize"];
    self.resultTextView.text = @"";
}

- (UITextView *)resultTextView
{
    if (!_resultTextView) {
        NSInteger padding = 20;
        NSInteger viewWith = self.view.frame.size.width;
        NSInteger viewHeight = self.view.frame.size.height - 64;
        _resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(padding, padding + 64, viewWith - padding * 2, viewHeight - padding * 2)];
        _resultTextView.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
        _resultTextView.layer.borderWidth = 1;
        _resultTextView.editable = NO;
        _resultTextView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
        _resultTextView.font = [UIFont systemFontOfSize:14];
        _resultTextView.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        _resultTextView.contentOffset = CGPointZero;
    }
    return _resultTextView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        NSInteger contentHeight = self.resultTextView.contentSize.height;
        NSInteger textViewHeight = self.resultTextView.frame.size.height;
        [self.resultTextView setContentOffset:CGPointMake(0, MAX(contentHeight - textViewHeight, 0)) animated:YES];
    }
}

-(void)demoProductDetailUsage{
  
  
  [KYRouter registerURLPattern:@"ky://productDetail" toHandler:^(NSDictionary *routerParameters) {
    [self appendLog:@"匹配到了 url，以下是相关信息"];
    [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
  }];
  
  [KYRouter openURL:@"ky://productDetail/?param1=111&param2=222"];
  
}

-(void)demoProductUsage{
#define TEMPLATE_URL @"ky://search/:keyword"
  
  [KYRouter registerURLPattern:TEMPLATE_URL  toHandler:^(NSDictionary *routerParameters) {
    [self appendLog:@"匹配到了 url，以下是相关信息"];
    
    [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    [self appendLog:[NSString stringWithFormat:@"routerParameters[keyword]:%@", routerParameters[@"keyword"]]];
  }];
  
  [KYRouter openURL:@"ky://search/12121/?param1=111&param2=222"];
  
}

-(void)demoProductUserInfoUsage{
#define TEMPLATE_URL @"ky://search/:keyword"

  [KYRouter registerURLPattern:TEMPLATE_URL toHandler:^(NSDictionary *routerParameters) {
    [self appendLog:@"匹配到了 url，以下是相关信息"];
    [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
  }];
  [KYRouter openURL:[KYRouter generateURLWithPattern:TEMPLATE_URL parameters:@[@"IOS DEV",@"sds"]]];
  [KYRouter openURL:@"ky://search/bicycle?color=red"];  
  [KYRouter openURL:@"ky://search/bicycle?color=red" withUserInfo:@{@"user_id": @1900} completion:nil];
  
}

@end
