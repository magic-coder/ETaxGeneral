/************************************************************
 Class    : MapViewController.mm
 Describe : 地图展示视图控制器
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-12-08
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "MapViewController.h"
#import "RouteAnnotation.h"
#import "UIImage+Rotate.h"
#import "YZLocationConverter.h"

#import "MapListModel.h"

#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>//引入检索功能所有的头文件
#import <BaiduMapAPI_Location/BMKLocationComponent.h>//引入定位功能所有的头文件
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>//引入计算工具所有的头文件
#import <MapKit/MapKit.h>

#define TITLE_FONT [UIFont systemFontOfSize:20.0f]
#define ADDRESS_FONT [UIFont systemFontOfSize:13.0f]

@interface MapViewController () <UIGestureRecognizerDelegate, YBPopupMenuDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRouteSearchDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) UIView *topLine;          // 底部视图顶线
@property (nonatomic, strong) UILabel *titleLabel;      // 底部标题
@property (nonatomic, strong) UILabel *addressLabel;    // 底部地址
@property (nonatomic, strong) UIButton *telbtn;         // 底部电话
@property (nonatomic, strong) UIButton *gpsBtn;         // 底部按钮

@property (nonatomic, assign) CLLocationCoordinate2D targetCoordinate;// 目标坐标
@property (nonatomic, assign) CLLocationCoordinate2D mineCoordinate;// 我的坐标

@property (nonatomic, assign) NSInteger ids;// 次数

@property (nonatomic, strong) BMKGeoCodeSearch *geocodesearch;
@property (nonatomic, strong) BMKLocationService *localService;
@property (nonatomic, strong) BMKRouteSearch *routesearch;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initMapView]; // 初始化Baidu地图
    [self initButton];// 构建视图上的按钮
    [self initBottomView];// 构建视图底部组件
    
    // 设置目标点的坐标
    _targetCoordinate = CLLocationCoordinate2DMake([_model.latitude doubleValue], [_model.longitude doubleValue]);
    
    // 定位服务（定位用户当前位置）
    _localService = [[BMKLocationService alloc] init];
    [_localService setDesiredAccuracy:kCLLocationAccuracyBest];//设置定位精度
    [_localService startUserLocationService];//用户开始定位
    
    _geocodesearch = [[BMKGeoCodeSearch alloc] init];// 反向地理编码（根据经纬度定位）
    _routesearch = [[BMKRouteSearch alloc]init];    // 路线规划
    
    // 标注目标位置
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = _targetCoordinate;
    BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag){
        _mapView.zoomLevel = 17;
        DLog(@"反geo检索发送成功");
    } else {
        DLog(@"反geo检索发送失败");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化BaiduMap方法
-(void)initMapView{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, HEIGHT_SCREEN-80)];
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(34.276053, 108.95378);// 初始化地图中心点为西安
    _mapView.zoomLevel = 12;    // 初始化地图显示级别
    _mapView.showsUserLocation = YES; // 设定是否显示定位图层
    _mapView.rotateEnabled = NO;    // 设定地图View能否支持旋转
    _mapView.overlookEnabled = NO;  // 设定地图View能否支持俯仰角
    [self.view addSubview:_mapView];
}

#pragma mark - 设置自定义按钮
-(void)initButton{
    // 自定义左侧(返回按钮)
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, HEIGHT_STATUS, 50, 50);
    [backBtn setImage:[UIImage imageNamed:@"map_btn_back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"map_btn_backHL"] forState:UIControlStateHighlighted];
    [_mapView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加右侧(更多按钮)
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(WIDTH_SCREEN-55, HEIGHT_STATUS, 50, 50);
    [moreBtn setImage:[UIImage imageNamed:@"map_btn_more"] forState:UIControlStateNormal];
    [moreBtn setImage:[UIImage imageNamed:@"map_btn_moreHL"] forState:UIControlStateHighlighted];
    [_mapView addSubview:moreBtn];
    [moreBtn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加底部(定位按钮)
    UIButton *locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(WIDTH_SCREEN-60, _mapView.frameHeight-60, 60, 60);
    [locationBtn setImage:[UIImage imageNamed:@"map_btn_location"] forState:UIControlStateNormal];
    [locationBtn setImage:[UIImage imageNamed:@"map_btn_locationHL"] forState:UIControlStateHighlighted];
    [_mapView addSubview:locationBtn];
    [locationBtn addTarget:self action:@selector(locationAction:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 设置底部视图
-(void)initBottomView{
    
    _topLine = [[UIView alloc] init];
    _topLine.frame = CGRectMake(0, _mapView.frameHeight, WIDTH_SCREEN, 0.5f);
    [_topLine setBackgroundColor:DEFAULT_LINE_GRAY_COLOR];
    [self.view addSubview:_topLine];
    NSInteger space;
    if(_model.tel.length > 0){
        space = 12;
    }else{
        space = 22;
    }
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.numberOfLines = 0;
    _titleLabel.font = TITLE_FONT;
    _titleLabel.textColor = [UIColor blackColor];
    if([_model.name isEqualToString:@"当前机构"]){
        _titleLabel.text = _model.deptName;
    }else{
        _titleLabel.text = _model.name;
    }
    _titleLabel.frame = CGRectMake(15, _mapView.frameHeight+space, WIDTH_SCREEN-80, 20);
    [self.view addSubview:_titleLabel];
    
    _addressLabel = [[UILabel alloc] init];
    _addressLabel.numberOfLines = 0;
    _addressLabel.font = ADDRESS_FONT;
    _addressLabel.textColor = [UIColor lightGrayColor];
    _addressLabel.text = _model.address;
    _addressLabel.frame = CGRectMake(15, _mapView.frameHeight+space+2+_titleLabel.frameHeight, WIDTH_SCREEN-80, 20);
    [self.view addSubview:_addressLabel];
    
    _telbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _telbtn.frame = CGRectMake(15, _mapView.frameHeight+space+2+_titleLabel.frameHeight+_addressLabel.frameHeight, WIDTH_SCREEN-80, 20);
    [_telbtn setTitleColor:DEFAULT_BLUE_COLOR forState:UIControlStateNormal];
    [_telbtn setTitleColor:DEFAULT_LIGHT_BLUE_COLOR forState:UIControlStateHighlighted];
    [_telbtn setTitle:_model.tel forState:UIControlStateNormal];
    [_telbtn.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
    _telbtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_telbtn addTarget:self action:@selector(onClickTel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_telbtn];
    
    _gpsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _gpsBtn.frame = CGRectMake(WIDTH_SCREEN-65, _mapView.frameHeight+12.5f, 55, 55);
    [_gpsBtn setImage:[UIImage imageNamed:@"map_btn_route"] forState:UIControlStateNormal];
    [_gpsBtn setImage:[UIImage imageNamed:@"map_btn_routeHL"] forState:UIControlStateHighlighted];
    [_gpsBtn addTarget:self action:@selector(gpsAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_gpsBtn];
    
}

#pragma mark - 视图即将展示方法
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _localService.delegate = self;
    _geocodesearch.delegate = self;
    _routesearch.delegate = self;
    
    // 设置顶部状态栏字体为黑色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

#pragma mark - 视图即将销毁方法
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_mapView viewWillDisappear];
    
    _mapView.delegate = nil; // 不用时，置nil
    _localService.delegate = nil;
    _geocodesearch.delegate = nil;
    _routesearch.delegate = nil;
    
    // 设置顶部状态栏字体为白色
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

#pragma mark - <BMKMapViewDelegate>代理方法
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[RouteAnnotation class]]) {
        return [(RouteAnnotation *)annotation getRouteAnnotationView:mapView];
    }
    return nil;
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay{
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.7];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
    return nil;
}

#pragma mark - <BMKLocationServiceDelegate>代理方法
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    // 设置我的坐标
    _mineCoordinate = userLocation.location.coordinate;
    
    //设置地图中心为用户经纬度
    [_mapView updateLocationData:userLocation];
}

#pragma mark - <BMKGeoCodeSearchDelegate>代理方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == 0) {
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc] init];
        item.coordinate = result.location;
        //item.title = result.address;  // 百度地图反向定位地址
        if([_model.name isEqualToString:@"当前机构"]){
            item.title = _model.deptName;
        }else{
            item.title = _model.name;
        }
        [_mapView addAnnotation:item];
        _mapView.centerCoordinate = result.location;
        NSString* showmeg;
        showmeg = [NSString stringWithFormat:@"%@",item.title];
        DLog(@"反向地理编码，%@", showmeg);
    }
}

#pragma mark - <BMKRouteSearchDelegate>代理方法
#pragma mark 驾车路线
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error{
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        array = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:array];
        
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            DLog(@"%@   %@    %@", transitStep.entraceInstruction, transitStep.exitInstruction, transitStep.instruction);
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode* tempNode in plan.wayPoints) {
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
            }
        }
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }else{
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"没有线路"
                     withSubtitle:@"没有对应\"驾乘\"线路，建议使用其他方式前往。"
                  withCustomImage:[UIImage imageNamed:@"alert_route"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
    }
}
#pragma mark 公交路线
- (void)onGetMassTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKMassTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error{
    
    if (error == BMK_SEARCH_NO_ERROR) {
        NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        array = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:array];
        
        BMKMassTransitRouteLine* routeLine = (BMKMassTransitRouteLine*)[result.routes objectAtIndex:0];
        
        BOOL startCoorIsNull = YES;
        CLLocationCoordinate2D startCoor;//起点经纬度
        CLLocationCoordinate2D endCoor;//终点经纬度
        
        NSInteger size = [routeLine.steps count];
        NSInteger planPointCounts = 0;
        for (NSInteger i = 0; i < size; i++) {
            BMKMassTransitStep* transitStep = [routeLine.steps objectAtIndex:i];
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                //添加annotation节点
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = subStep.entraceCoor;
                item.title = subStep.instructions;
                item.type = 2;
                [_mapView addAnnotation:item];
                
                if (startCoorIsNull) {
                    startCoor = subStep.entraceCoor;
                    startCoorIsNull = NO;
                }
                endCoor = subStep.exitCoor;
                
                //轨迹点总数累计
                planPointCounts += subStep.pointsCount;
                
                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        //添加起点标注
        RouteAnnotation* startAnnotation = [[RouteAnnotation alloc]init];
        startAnnotation.coordinate = startCoor;
        startAnnotation.title = @"起点";
        startAnnotation.type = 0;
        [_mapView addAnnotation:startAnnotation]; // 添加起点标注
        //添加终点标注
        RouteAnnotation* endAnnotation = [[RouteAnnotation alloc]init];
        endAnnotation.coordinate = endCoor;
        endAnnotation.title = @"终点";
        endAnnotation.type = 1;
        [_mapView addAnnotation:endAnnotation]; // 添加起点标注
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        NSInteger index = 0;
        for (BMKMassTransitStep* transitStep in routeLine.steps) {
            for (BMKMassTransitSubStep *subStep in transitStep.steps) {
                for (NSInteger i = 0; i < subStep.pointsCount; i++) {
                    temppoints[index].x = subStep.points[i].x;
                    temppoints[index].y = subStep.points[i].y;
                    index++;
                }
                
                //steps中是方案还是子路段，YES:steps是BMKMassTransitStep的子路段（A到B需要经过多个steps）;NO:steps是多个方案（A到B有多个方案选择）
                if (transitStep.isSubStep == NO) {//是子方案，只取第一条方案
                    break;
                }
                else {
                    //是子路段，需要完整遍历transitStep.steps
                }
            }
        }
        
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }else{
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"没有线路"
                     withSubtitle:@"没有对应\"公交\"线路，建议使用其他方式前往。"
                  withCustomImage:[UIImage imageNamed:@"alert_route"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
    }
}
#pragma mark 步行路线
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error{
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    array = [NSArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
            if(i==0){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i==size-1){
                RouteAnnotation* item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.terminal.location;
                item.title = @"终点";
                item.type = 1;
                [_mapView addAnnotation:item]; // 添加起点标注
            }
            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.entraceInstruction;
            item.degree = transitStep.direction * 30;
            item.type = 4;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:polyLine];
    }else{
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"没有线路"
                     withSubtitle:@"没有对应\"步行\"线路，建议使用其他方式前往。"
                  withCustomImage:[UIImage imageNamed:@"alert_route"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
    }
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    //CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    //ltX = pt.x, ltY = pt.y;
    //rbX = pt.x, rbY = pt.y;
    CGFloat ltX = pt.x;
    CGFloat ltY = pt.y;
    CGFloat rbX = pt.x;
    CGFloat rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [_mapView setVisibleMapRect:rect];
    _mapView.zoomLevel = _mapView.zoomLevel - 0.3;
}

#pragma mark - 各种定义btn的方法事件
#pragma mark 自定义左侧返回按钮方法（退出地图方法）
-(void)backAction:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 自定义右更多按钮方法（路线规划）
- (void)moreAction:(UIButton *)sender{
    
    if(![self isOpenLocation]){
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"无法使用定位"
                     withSubtitle:@"请在iPhone的\"设置-隐私-定位服务\"中开启定位。"
                  withCustomImage:[UIImage imageNamed:@"alert_location"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
        return;
    }
    
    [YBPopupMenu showPopupMenuWithTitles:@[@"驾乘路线", @"公交路线", @"步行路线"] icons:@[@"map_route_car", @"map_route_bus", @"map_route_walk"] delegate:self];
    
    /*
     BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
     reverseGeocodeSearchOption.reverseGeoPoint = _targetCoordinate;
     BOOL flag = [_geocodesearch reverseGeoCode:reverseGeocodeSearchOption];
     if(flag){
     _mapView.zoomLevel = 15;
     DLog(@"反geo检索发送成功");
     } else {
     DLog(@"反geo检索发送失败");
     }
     */
}

#pragma mark - 气泡菜单点击方法
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu {
    if(index == 0){
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.pt = _mineCoordinate;
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.pt = _targetCoordinate;
        
        BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
        drivingRouteSearchOption.from = start;
        drivingRouteSearchOption.to = end;
        drivingRouteSearchOption.drivingRequestTrafficType = BMK_DRIVING_REQUEST_TRAFFICE_TYPE_NONE;//不获取路况信息
        BOOL flag = [_routesearch drivingSearch:drivingRouteSearchOption];
        if(flag){
            DLog(@"car检索发送成功");
        }
        else{
            DLog(@"car检索发送失败");
        }
    }
    if(index == 1){
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.pt = _mineCoordinate;
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.pt = _targetCoordinate;
        
        BMKMassTransitRoutePlanOption *option = [[BMKMassTransitRoutePlanOption alloc]init];
        option.from = start;
        option.to = end;
        BOOL flag = [_routesearch massTransitSearch:option];
        
        if(flag) {
            DLog(@"公交交通检索（支持垮城）发送成功");
        } else {
            DLog(@"公交交通检索（支持垮城）发送失败");
        }
    }
    if(index == 2){
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.pt = _mineCoordinate;
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.pt = _targetCoordinate;
        
        BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
        walkingRouteSearchOption.from = start;
        walkingRouteSearchOption.to = end;
        BOOL flag = [_routesearch walkingSearch:walkingRouteSearchOption];
        if(flag){
            DLog(@"walk检索发送成功");
        }
        else{
            DLog(@"walk检索发送失败");
        }
    }
}

#pragma mark 底部定位按钮定位方法
-(void)locationAction:(UIButton *)sender{
    if(![self isOpenLocation]){
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"无法使用定位"
                     withSubtitle:@"请在iPhone的\"设置-隐私-定位服务\"中开启定位。"
                  withCustomImage:[UIImage imageNamed:@"alert_location"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
        return;
    }
    _mapView.centerCoordinate = _mineCoordinate;
}
#pragma mark 打开电话
- (void)onClickTel:(UIButton *)sender{
    
    NSString *telStr = sender.titleLabel.text;
    NSArray *telArray = [telStr componentsSeparatedByString:@"、"];
    NSMutableArray *tels = [[NSMutableArray alloc] init];
    for(int i=0; i<telArray.count; i++){
        if(i>0){
            [tels addObject:[NSString stringWithFormat:@"029-%@", telArray[i]]];
        }else{
            [tels addObject:telArray[i]];
        }
        
    }
    if(tels.count > 1){
        [YZBottomSelectView showBottomSelectViewWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:tels handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
            if(index > 0){
                NSString *str = [NSString stringWithFormat:@"tel://%@", tels[index-1]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
            }
        }];
    }else{
        NSString *str = [NSString stringWithFormat:@"tel://%@", telStr];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str] options:@{} completionHandler:nil];
    }
}
#pragma mark 打开百度地图客户端导航
-(void)gpsAction:(UIButton *)sender{
    
    if(![self isOpenLocation]){
        FCAlertView *alert = [[FCAlertView alloc] init];
        [alert showAlertWithTitle:@"无法使用定位"
                     withSubtitle:@"请在iPhone的\"设置-隐私-定位服务\"中开启定位。"
                  withCustomImage:[UIImage imageNamed:@"alert_location"]
              withDoneButtonTitle:@"确定"
                       andButtons:nil];
        alert.colorScheme = alert.flatOrange;
        return;
    }
    
    [YZBottomSelectView showBottomSelectViewWithTitle:@"请选择导航方式" cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"苹果地图", @"高德地图", @"百度地图", @"腾讯地图"] handler:^(YZBottomSelectView *bootomSelectView, NSInteger index) {
        if(index == 0){
            return;
        }
        
        CLLocationCoordinate2D gcj02MineCoordinate = [YZLocationConverter bd09ToGcj02:_mineCoordinate];
        CLLocationCoordinate2D gcj02TargetCoordinate = [YZLocationConverter bd09ToGcj02:_targetCoordinate];
        
        if(index == 1){
            //当前的位置
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            //目的地的位置
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:gcj02TargetCoordinate addressDictionary:nil]];
            toLocation.name = _model.name;
            
            NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation, nil];
            NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
            //打开苹果自身地图应用，并呈现特定的item
            [MKMapItem openMapsWithItems:items launchOptions:options];
        }
        if(index == 2){
            // 是否安装高德地图
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
                //NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=&backScheme=&slat=&slon=&sname=我的位置&sid=B001&dlat=%f&dlon=%f&dname=%@&did=B002&dev=0&m=3&t=0",gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude, _model.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=&backScheme=&slat=&slon=&sname=我的位置&sid=B001&dlat=%f&dlon=%f&dname=%@&did=B002&dev=0&m=3&t=0",gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude, _model.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }else{
                //NSString *urlString =[[NSString stringWithFormat:@"http://uri.amap.com/navigation?from=%f,%f,我的位置&to=%f,%f,%@&mode=car&policy=0&src=TaxGeneralM&coordinate=gaode&callnative=0",gcj02MineCoordinate.longitude, gcj02MineCoordinate.latitude, gcj02TargetCoordinate.longitude, gcj02TargetCoordinate.latitude, _model.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlString =[[NSString stringWithFormat:@"http://uri.amap.com/navigation?from=%f,%f,我的位置&to=%f,%f,%@&mode=car&policy=0&src=TaxGeneralM&coordinate=gaode&callnative=0",gcj02MineCoordinate.longitude, gcj02MineCoordinate.latitude, gcj02TargetCoordinate.longitude, gcj02TargetCoordinate.latitude, _model.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }
        }
        if(index == 3){
            // 是否安装百度地图
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]){
                //NSString *urlString =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude, _model.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlString =[[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude, _model.name] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }else{
                //初始化调启导航时的参数管理类
                BMKNaviPara* para = [[BMKNaviPara alloc] init];
                
                //初始化起点节点
                BMKPlanNode* start = [[BMKPlanNode alloc] init];
                //指定起点经纬度
                start.pt = _mineCoordinate;
                //指定起点名称
                start.name = @"我的位置";
                //指定起点
                para.startPoint = start;
                
                //初始化终点节点
                BMKPlanNode* end = [[BMKPlanNode alloc] init];
                end.pt = _targetCoordinate;
                //指定终点名称
                end.name = _model.name;
                //指定终点
                para.endPoint = end;
                
                //指定返回自定义scheme
                para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
                //调启百度地图客户端导航
                [BMKNavigation openBaiduMapNavigation:para];
            }
        }
        if(index == 4){
            // 判断是否安装腾讯地图
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]){
                //NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%f,%f&coord_type=1&policy=0&referer=TaxGeneralM", _model.name, gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&to=%@&tocoord=%f,%f&coord_type=1&policy=0&referer=TaxGeneralM", _model.name, gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }else{
                //NSString *urlString = [[NSString stringWithFormat:@"http://apis.map.qq.com/uri/v1/routeplan?type=drive&from=我的位置&fromcoord=%f,%f&to=%@&tocoord=%f,%f&policy=1&referer=TaxGeneralM", gcj02MineCoordinate.latitude, gcj02MineCoordinate.longitude, _model.name, gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString *urlString = [[NSString stringWithFormat:@"http://apis.map.qq.com/uri/v1/routeplan?type=drive&from=我的位置&fromcoord=%f,%f&to=%@&tocoord=%f,%f&policy=1&referer=TaxGeneralM", gcj02MineCoordinate.latitude, gcj02MineCoordinate.longitude, _model.name, gcj02TargetCoordinate.latitude, gcj02TargetCoordinate.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
            }
        }
    }];
}

#pragma mark - 判断定位权限是否开启
- (BOOL)isOpenLocation{
    // 检查是否有定位权限
    BOOL isLocation = [CLLocationManager locationServicesEnabled];
    if (!isLocation) {
        return NO;
    }
    CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
    if(CLstatus == kCLAuthorizationStatusDenied || CLstatus == kCLAuthorizationStatusRestricted){
        return NO;
    }else{
        return YES;
    }
    return NO;
}

@end
