//
//  ViewController.m
//  MapTracking
//
//  Created by hbj on 2017/9/1.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "ViewController.h"
/*重用标识符*/
#define kCell  @"UITableViewCell"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataMArr;
@property (nonatomic, strong) NSArray *claa_arr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self creatUIwithTableView];
}
/*UI创建*/
- (void)creatUIwithTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
}

- (NSMutableArray *)dataMArr {
    if (!_dataMArr) {
        _dataMArr = [NSMutableArray arrayWithObjects:@"定位",
                     @"绘制轨迹",
                     @"周边检索",
                     @"轨迹回放", nil];
    }
    return _dataMArr;
}
- (NSArray *)claa_arr {
    if (!_claa_arr) {
        _claa_arr = [NSArray arrayWithObjects:@"LocationViewController",
                     @"DrawTrackViewController",
                     @"AroundSearchViewController",
                     @"TrackingViewController", nil];
    }
    return _claa_arr;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataMArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *item = [tableView dequeueReusableCellWithIdentifier:kCell];
    if (item == nil) {
        item = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCell];
        item.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        /*****设置item选中时的背景颜色*****/
        item.selectedBackgroundView = [[UIView alloc] initWithFrame:item.frame];
        item.selectedBackgroundView.backgroundColor = [UIColor redColor];
    }
    
    item.textLabel.text = [self.dataMArr objectAtIndex:indexPath.row];
    return item;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *className = [self.claa_arr objectAtIndex:indexPath.row];
    UIViewController *classVC = [[NSClassFromString(className) alloc] init];
    /*ios更改导航栏返回按钮back为中文“返回”*/
    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:nil];
    [self.navigationItem setBackBarButtonItem:bar];
    [self.navigationController pushViewController:classVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
