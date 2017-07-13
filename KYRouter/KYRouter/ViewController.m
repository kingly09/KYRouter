//
//  ViewController.m
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
// THE SOFTWARE. All rights reserved.
//

#import "ViewController.h"
#import "KYDemoDetailVC.h"

static NSMutableDictionary *titleWithHandlers;
static NSMutableArray *titles;


@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic) UITableView *tableView;
@end

@implementation ViewController

+ (void)registerWithTitle:(NSString *)title handler:(UIViewController *(^)())handler
{
    if (!titleWithHandlers) {
        titleWithHandlers = [[NSMutableDictionary alloc] init];
        titles = [NSMutableArray array];
    }
    [titles addObject:title];
    titleWithHandlers[title] = handler;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  self.title = @"KYRouterDemo";
  [self setupTableView];
  
}

-(void)setupTableView{

  self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleWithHandlers.allKeys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  
    UIViewController *viewController = ((ViewControllerHandler)titleWithHandlers[titles[indexPath.row]])();
    [self.navigationController pushViewController:viewController animated:YES];

}


@end
