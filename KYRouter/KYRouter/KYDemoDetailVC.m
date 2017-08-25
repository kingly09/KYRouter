//
//  KYDemoDetailVC.m
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

#import "KYDemoDetailVC.h"
#import "ViewController.h"
#import "KYRouter.h"

@interface KYDemoDetailVC ()
@property (nonatomic) UITextView *resultTextView;
@property (nonatomic) SEL selectedSelector;
@end

@implementation KYDemoDetailVC
+ (void)load
{
    KYDemoDetailVC *detailViewController = [[KYDemoDetailVC alloc] init];
    [ViewController registerWithTitle:@"基本使用" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoBasicUsage);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"中文匹配" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoChineseCharacter);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"自定义参数" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoParameters);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"传入字典信息" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoUserInfo);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"Fallback 到全局的 URL Pattern" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoFallback);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"Open 结束后执行 Completion Block" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoCompletion);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"基于 URL 模板生成 具体的 URL" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoGenerateURL);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"取消注册 URL Pattern" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoDeregisterURLPattern);
        return detailViewController;
    }];
    
    [ViewController registerWithTitle:@"同步获取 URL 对应的 Object" handler:^UIViewController *{
        detailViewController.selectedSelector = @selector(demoObjectForURL);
        return detailViewController;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:239.f/255 green:239.f/255 blue:244.f/255 alpha:1];
    [self.view addSubview:self.resultTextView];
    // Do any additional setup after loading the view.
    self.title = @"demoDetail";
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

#pragma mark - Demos

- (void)demoFallback
{
    [KYRouter registerURLPattern:@"ky://" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"匹配到了 url，以下是相关信息"];
        [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    }];
    
    [KYRouter registerURLPattern:@"ky://foo/bar/none/exists" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"it should be triggered"];
    }];
    
    [KYRouter openURL:@"ky://foo/bar"];
}

- (void)demoBasicUsage
{
    [KYRouter registerURLPattern:@"ky://foo/bar" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"匹配到了 url，以下是相关信息"];
        [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    }];
    
    [KYRouter openURL:@"ky://foo/bar"];
}

- (void)demoChineseCharacter
{
    [KYRouter registerURLPattern:@"ky://category/家居" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"匹配到了 url，以下是相关信息"];
        [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    }];
    
    [KYRouter openURL:@"ky://category/家居"];
}

- (void)demoUserInfo
{
    [KYRouter registerURLPattern:@"ky://category/travel" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"匹配到了 url，以下是相关信息"];
        [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    }];
    
    [KYRouter openURL:@"ky://category/travel" withUserInfo:@{@"user_id": @1900} completion:nil];
}

- (void)demoParameters
{
    [KYRouter registerURLPattern:@"ky://search/:query" toHandler:^(NSDictionary *routerParameters) {
        [self appendLog:@"匹配到了 url，以下是相关信息"];
        [self appendLog:[NSString stringWithFormat:@"routerParameters:%@", routerParameters]];
    }];
    
    [KYRouter openURL:@"ky://search/bicycle?color=red"];
}

- (void)demoCompletion
{
[KYRouter registerURLPattern:@"ky://detail" toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"匹配到了 url, 一会会执行 Completion Block ::%@",routerParameters);
    
    // 模拟 push 一个 VC
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        void (^completion)(id result) = routerParameters[KYRouterParameterCompletion];
        if (completion) {
            completion(nil);
        }
    });
}];

[KYRouter openURL:@"ky://detail/1241/1212/?aa=12&bb=12" withUserInfo:nil completion:^(id result){
    [self appendLog:[NSString stringWithFormat:@"Open 结束，我是 Completion Block ：：%@", result]];
}];
}

- (void)demoGenerateURL
{
#define TEMPLATE_URL @"ky://search/:keyword"
    
[KYRouter registerURLPattern:TEMPLATE_URL  toHandler:^(NSDictionary *routerParameters) {
    NSLog(@"routerParameters[keyword]:%@", routerParameters[@"keyword"]); // IOS DEV
}];

[KYRouter openURL:[KYRouter generateURLWithPattern:TEMPLATE_URL parameters:@[@"IOS DEV"]]];
}

- (void)demoDeregisterURLPattern
{
#define TEMPLATE_URL @"ky://search/:keyword"
    
    [KYRouter registerURLPattern:TEMPLATE_URL  toHandler:^(NSDictionary *routerParameters) {
        NSAssert(NO, @"这里不会被触发");
        NSLog(@"routerParameters[keyword]:%@", routerParameters[@"keyword"]); // Hangzhou
    }];
    
    [KYRouter deregisterURLPattern:TEMPLATE_URL];

    [KYRouter openURL:[KYRouter generateURLWithPattern:TEMPLATE_URL parameters:@[@"Hangzhou"]]];
    
    [self appendLog:@"如果没有运行到断点，就表示取消注册成功了"];
}

- (void)demoObjectForURL
{
    [KYRouter registerURLPattern:@"ky://search_top_bar" toObjectHandler:^id(NSDictionary *routerParameters) {
        UIView *searchTopBar = [[UIView alloc] init];
        return searchTopBar;
    }];
    
    UIView *searchTopBar = [KYRouter objectForURL:@"ky://search_top_bar"];
    
    if ([searchTopBar isKindOfClass:[UIView class]]) {
        [self appendLog:@"同步获取 Object 成功"];
    } else {
        [self appendLog:@"同步获取 Object 失败"];
    }
}


@end
