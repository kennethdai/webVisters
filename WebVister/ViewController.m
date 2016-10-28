//
//  ViewController.m
//  WebVister
//
//  Created by KennethDai on 7/25/16.
//  Copyright © 2016 KennethDai. All rights reserved.
//

#import "ViewController.h"
#import "WVTableViewCell.h"

@interface ViewController ()
{
    
    UITableView *viewsTableView;
    id webVisterData;
    NSArray *urlList;
    WVMode displayMode;
    double cellHeight;
    UIScrollView *scrollView;
    double timeInterval;
    NSTimer *timer;
    UIViewController *webViewC;
    int currentIndex;
    BOOL isAdmin;
    int timesTapped;
    UIButton *switchBtn;
    NSString *customerStr;
    UIWebView *custromerWebView;
}

@end

#define LINK_WebVister @"https://webvister-23990.firebaseio.com/"
#define LINK_URLAddress @"https://webvister-23990.firebaseio.com/urls"
#define LINK_Duration @"https://webvister-23990.firebaseio.com/duration/"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    viewsTableView = [[UITableView alloc] init];
    viewsTableView.delegate = self;
    viewsTableView.dataSource = self;
    urlList = @[];
    displayMode = WVDisplayOverview;
    self.navigationItem.title = @"WebVister";
    viewsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    viewsTableView.backgroundColor = [UIColor clearColor];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"模式" style:UIBarButtonItemStylePlain target:self action:@selector(switchMode)];
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(loadAlertView)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem = rightButton;
    
    scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrollView.scrollsToTop = YES;
    scrollView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:scrollView];
    [scrollView addSubview:viewsTableView];
    viewsTableView.scrollEnabled = NO;
    
    timeInterval = 10 * 60;
    //Min is 10 seconds, shouldn't be lower than that.
    timer = [NSTimer scheduledTimerWithTimeInterval:(timeInterval < 600) ? 600 : timeInterval  target:self selector:@selector(reloadWVData) userInfo:nil repeats:YES];
    [timer fire];
    
    currentIndex = -1;

    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject:@"0" forKey:@"isAdmin"];
    if ([[userInfo valueForKey:@"isAdmin"] isEqualToString:@"1"])
    {
        isAdmin = YES;
        //不让手机休眠.
        [UIApplication sharedApplication].idleTimerDisabled =YES;
        [self.navigationController setNavigationBarHidden:NO];
        custromerWebView.hidden = YES;
        scrollView.hidden = NO;
        [self getNewData];
    } else {
        isAdmin = NO;
        
        scrollView.hidden = YES;
        [self.navigationController setNavigationBarHidden:YES];
        [self loadWebViewWithURL:customerStr ? customerStr : @"baidu.com"];
    }
    
    urlList = [userInfo valueForKey:@"urlList"];
    if (!urlList) {
        urlList = @[];
    }
    
    
    
    switchBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, [UIScreen mainScreen].bounds.size.height - 50, 100, 40)];
    switchBtn.backgroundColor = [UIColor clearColor];
    [switchBtn setTitle:nil forState:UIControlStateNormal];
    [self.view addSubview:switchBtn];
    [switchBtn addTarget:self action:@selector(onSwitchBtnTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadAdminData
{
    isAdmin = YES;
    //不让手机休眠.
    [UIApplication sharedApplication].idleTimerDisabled =YES;
    [self.navigationController setNavigationBarHidden:NO];
    [custromerWebView removeFromSuperview];
    scrollView.hidden = NO;
    [self getNewData];
}

- (void)loadCustomerData
{
    isAdmin = NO;
    scrollView.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    [self loadWebViewWithURL:customerStr ? customerStr : @"baidu.com"];
}

- (void)getNewData
{
    customerStr = urlList.firstObject;
    NSNumber *interval = webVisterData[@"duration"];
    timeInterval = interval.doubleValue;
    if (timeInterval) {
        timer = [NSTimer scheduledTimerWithTimeInterval:(timeInterval < 600) ? 600 : timeInterval  target:self selector:@selector(reloadWVData) userInfo:nil repeats:YES];
        //                timer.timeInterval = timeInterval;
        [timer fire];
    }
    [self reloadWVData];
    
}
                      

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateViewsFrame];
}

- (void)reloadWVData
{
    [viewsTableView reloadData];
    [self updateViewsFrame];
    NSLog(@"Data reloaded");
}
                      
- (void) updateViewsFrame
{
    double tableViewHeight = urlList.count * cellHeight + 10;
    CGRect frame = CGRectMake(5, 0, [UIScreen mainScreen].bounds.size.width - 10, tableViewHeight);
    viewsTableView.frame = frame;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, urlList.count * cellHeight);
}

- (void)switchMode
{
    WVMode mode = (displayMode == WVDisplayOverview)?WVDisplayDetails : WVDisplayOverview;
    displayMode = mode;
    [viewsTableView reloadData];
    [self updateViewsFrame];
    [self viewDidAppear:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(displayMode == WVDisplayDetails)
    {
        NSString *webViewDetailCellID = @"webViewDetailCellID";
        WVTableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:webViewDetailCellID];
        if (!viewCell)
        {
            viewCell = [[NSBundle mainBundle] loadNibNamed:@"WVTableViewCell" owner:self options:nil].firstObject;
        }
        viewCell.backgroundColor = ((indexPath.row % 2) == 0) ? [UIColor whiteColor] : [UIColor grayColor];
        [viewCell loadViewWithUrl:urlList[indexPath.row]];
        return viewCell;
    } else if (displayMode == WVDisplayOverview){
        NSString  *webViewOverviewCellID = @"webViewOverviewCellID";
        WVTableViewCell *normalCell = [tableView dequeueReusableCellWithIdentifier:webViewOverviewCellID];
        if (!normalCell) {
            normalCell = [[NSBundle mainBundle] loadNibNamed:@"WVOverviewTableViewCell" owner:self options:nil].firstObject;
        }
        [normalCell loadViewWithUrl:urlList[indexPath.row]];
        normalCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return normalCell;
    } else {
        NSLog(@"Nil cell");
        return nil;
    }
    
}

//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete;
//}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return urlList.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (displayMode == WVDisplayOverview)
    {
        cellHeight = 80;
    } else {
        cellHeight = 150;
    }
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    currentIndex = (int)indexPath.row;
    webViewC = [[UIViewController alloc] init];
    webViewC.view.backgroundColor = [UIColor redColor];
    NSString *url = urlList[indexPath.row];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [webViewC.view addSubview:webView];
    webView.scalesPageToFit = YES;
    
    if (!([url rangeOfString:@"http://"].length && [url rangeOfString:@"https://"].length))
    {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    [webView loadRequest:urlRequest];
    
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStylePlain target:self action:@selector(conformToDeleteURL:)];
    webViewC.navigationItem.rightBarButtonItem = rightButton;
    [self.navigationController pushViewController:webViewC animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];

}

- (void)loadWebViewWithURL:(NSString *)urlStr
{
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    custromerWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, screenFrame.size.width, screenFrame.size.height - 20)];
    custromerWebView.scalesPageToFit = YES;
    
    if (!([urlStr rangeOfString:@"http://"].length && [urlStr rangeOfString:@"https://"].length))
    {
        urlStr = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    [custromerWebView loadRequest:urlRequest];
    [self.view addSubview:custromerWebView];
    self.view.backgroundColor = [UIColor whiteColor];
    

}

- (void)onSwitchBtnTapped
{
    timesTapped += 1;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    
    if (timesTapped == 10)
    {
        [self loadAdminData];
        [userDefault setObject:@"1" forKey:@"isAdmin"];
        switchBtn.backgroundColor = [UIColor redColor];
        [switchBtn setTitle:@"用户模式" forState:UIControlStateNormal];
        timesTapped = 100;
    } else if (timesTapped > 99){
        timesTapped = 0;
        [userDefault setObject:@"0" forKey:@"isAdmin"];
        switchBtn.backgroundColor = [UIColor clearColor];
        [switchBtn setTitle:@"" forState:UIControlStateNormal];
        [self loadCustomerData];
    }
        
}

- (void) conformToDeleteURL:(NSString *)url
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"确认删除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteAnURL:url];
    }];
    
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Canceled");
    }];
    [alertController addAction:act1];
    [alertController addAction:act2];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)deleteAnURL:(NSString *)url
{
    NSMutableArray *lists = [NSMutableArray arrayWithArray:urlList];
    if (currentIndex >= 0) {
        [lists removeObjectAtIndex:currentIndex];
    }
    if (lists) customerStr = lists.firstObject;
    urlList = lists;
    [self.navigationController popViewControllerAnimated:YES];
    currentIndex = -1;
    [viewsTableView reloadData];
    [self updateViewsFrame];
    [self saveUserData];
}



- (void)loadAlertView
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"输入URL" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"URL address.";
    }];
    UITextField *userInput = alertController.textFields.firstObject;
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        [userInput resignFirstResponder];
        if (userInput.text.length > 0) {
            NSMutableArray *newURLList = [NSMutableArray arrayWithArray:@[userInput.text]];
            [newURLList addObjectsFromArray:[NSArray arrayWithArray: urlList]];
            
            urlList = newURLList;
            [self saveUserData];
            [viewsTableView reloadData];
            [self updateViewsFrame];
        }
        
    }];
    
    UIAlertAction *act2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [userInput resignFirstResponder];
        NSLog(@"Canceled");
    }];
    [alertController addAction:act1];
    [alertController addAction:act2];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)saveUserData
{
    NSUserDefaults *userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject:urlList forKey:@"urlList"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Cell delegate



@end
