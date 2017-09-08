//
//  AroundSearchViewController.m
//  MapTracking
//
//  Created by hbj on 2017/9/1.
//  Copyright © 2017年 保健. All rights reserved.
//

#import "AroundSearchViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Lo_SystemRequest.h"

////屏幕宽度
#define kWidth    [UIScreen mainScreen].bounds.size.width
////屏幕高度
#define kHeight   [UIScreen mainScreen].bounds.size.height

@interface AroundSearchViewController () <UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate, UISearchBarDelegate>
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic,retain) UITableView    *mTableView;

@property (nonatomic,retain) AMapSearchAPI  *search;
@property (nonatomic,retain) NSMutableArray *addressArray;
@property (nonatomic, retain) NSIndexPath  *indexP;

@property (nonatomic,retain)   AMapPOI  *oldPoi;

@end

@implementation AroundSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.indexP = [NSIndexPath indexPathForRow:0 inSection:0];
    
    ((void (*)(id, SEL))objc_msgSend)(self, NSSelectorFromString(@"initContent"));
    
}

- (NSMutableArray *)addressArray{
    if (!_addressArray) {
        _addressArray = ({
            [[NSMutableArray alloc] init];
        });
    }
    return _addressArray;
}

- (AMapSearchAPI *)search{
    if (!_search) {
        _search = ({
            [AMapServices sharedServices].apiKey = APIKey;
            AMapSearchAPI *api = [[AMapSearchAPI alloc] init];
            api.delegate       = self;
            api;
        });
    }
    return _search;
}

#pragma mark - get set
- (UITableView *)mTableView{
    if (!_mTableView) {
        _mTableView = ({
            //            __weak __typeof(self) weakSelf = self;
            UITableView *mTableView = [[UITableView alloc] init];
            mTableView.frame = CGRectMake(0, 64 + 44, kWidth, kHeight - 64 - 44);
            mTableView.showsHorizontalScrollIndicator = NO;
            mTableView.showsVerticalScrollIndicator   = NO;
            mTableView.rowHeight                      = 44;
            mTableView.dataSource                     = self;
            mTableView.delegate                       = self;
            mTableView.tableFooterView                = [UIView new];
     
            mTableView;
        });
    }
    return _mTableView;
}

- (void)initContent {
  
    self.oldPoi = [[AMapPOI alloc] init];
    self.oldPoi.name = @"不显示位置";
    self.oldPoi.address = @"";
    
    [self obtainUI];
    [self sendRequestWithSearchPoiByKeyword:@""];
}

- (void)obtainUI {
    [self initSearchBar];
     [self.view addSubview:self.mTableView];
}

- (void)sendRequestWithSearchPoiByKeyword:(NSString *)keyword{
    
    [Lo_SystemRequest shareLo_SystemRequest].ampBlock = ^(CLLocation *userLocation, AMapLocationReGeocode *userRegeocode) {
        NSLog(@"我是高德定位%@--%f", userRegeocode.formattedAddress, userLocation.coordinate.latitude);
 
        if (keyword.length > 0) {
            AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
            /* 根据关键字来搜索POI. */
            request.keywords = [NSString stringWithFormat:@"%@%@",  userRegeocode.city,keyword];
            request.requireSubPOIs      = YES;
            [self.search AMapPOIKeywordsSearch:request];
        } else {
            /******周边搜索******/
        AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
        request.location                    = [AMapGeoPoint locationWithLatitude:userLocation.coordinate.latitude longitude:userLocation.coordinate.longitude];
        request.keywords                    = @"";
        request.sortrule                    = 0;
        request.requireExtension            = YES;
        request.radius                      = 1000;
        request.types                       = @"050000|060000|070000|080000|090000|100000|110000|120000|130000|140000|150000|160000|170000";
        [self.search AMapPOIAroundSearch:request];
        }
        
        
    };
    [[Lo_SystemRequest shareLo_SystemRequest] reGeocodeAction];
}


#pragma mark - AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    [self.addressArray removeAllObjects];
    [self.addressArray addObjectsFromArray:response.pois];

    if (self.addressArray.count > 0) {
        AMapPOI *apoi = (AMapPOI *)self.addressArray[0];
        self.oldPoi.name = apoi.name;
        self.oldPoi.address = apoi.address;
        self.oldPoi = apoi;
    }

    [self.mTableView reloadData];
  
}


#pragma mark TableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"SelectLocationCell";
    UITableViewCell *cell    = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    AMapPOI *info               = self.addressArray[indexPath.row];
    cell.textLabel.text         = info.name.length > 0 ? info.name : info.city;
    cell.detailTextLabel.text   = info.address;
    cell.accessoryType  = UITableViewCellAccessoryNone;
    
    if ([self.oldPoi.name isEqualToString:info.name] && [self.oldPoi.address isEqualToString:info.address]) {
        cell.accessoryType  = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType  = UITableViewCellAccessoryNone;
    }
  
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.addressArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AMapPOI *info = self.addressArray[indexPath.row];
    self.oldPoi = info;
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    [tableView reloadRowsAtIndexPaths:@[self.indexP] withRowAnimation:UITableViewRowAnimationNone];
    self.indexP = indexPath;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}


#pragma mark -
- (void)initSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 64, kWidth, 44)];
    //    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //    self.searchBar.barStyle     = UIBarStyleBlack;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"搜索地点";
    //    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    
    //    self.navigationItem.titleView = self.searchBar;
    [self.view addSubview:self.searchBar];
    //    [self.searchBar sizeToFit];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    
    [self sendRequestWithSearchPoiByKeyword:self.searchBar.text];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
