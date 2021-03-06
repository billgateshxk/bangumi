//
//  DaliyListViewController.m
//  bangumi
//
//  Created by bi119aTe5hXk on 2014/04/30.
//  Copyright (c) 2014年 bi119aTe5hXk. All rights reserved.
//

#import "DaliyListViewController.h"

@interface DaliyListViewController ()

@end

@implementation DaliyListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIButton* todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [todayButton setTitle:@"今日" forState:UIControlStateNormal];
//    [todayButton addTarget:self action:@selector(jumpToToday) forControlEvents:UIControlEventTouchUpInside];
//    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:todayButton];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    bgmapi = [[BGMAPI alloc] initWithdelegate:self];
    if (daylist.count <= 0) {
        [self startGetDayBGMList];
    }
}
- (void)onRefresh:(id)sender{
    [self startGetDayBGMList];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [bgmapi cancelConnection];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self viewDidLoad];
    self.tabBarController.navigationItem.title = @"每日番组";
    
    [self registHomeScreenQuickActions];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kRestoreNoficationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getUserActivityState:) name:kRestoreNoficationName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"shortCutNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(shortCutReceived:)
                                                 name:@"shortCutNotification"
                                               object:nil];
    
}

-(void)startGetDayBGMList{
    
    [bgmapi getDayBGMList];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)api:(BGMAPI *)api readyWithList:(NSArray *)list{
    daylist = list;
    dispatch_async(dispatch_get_main_queue(),^{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];//
    [self.refreshControl endRefreshing];
    
        [UIView animateWithDuration:0 animations:^{
           [self.tableView reloadData];
        } completion:^(BOOL finished) {
            [self jumpToToday];
        }];
    
    });
    
    
}
-(void)jumpToToday{
    if([daylist count] >= 7){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexpath = [NSIndexPath indexPathForRow:0 inSection:[self todayNum]];
        [self.tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            });
    }
    
}
-(NSInteger)todayNum{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger weekday = [comps weekday];
    //NSLog(@"weekday:%ld",weekday);
    NSInteger day=0;
    if (weekday == 1) {
        //sun
        day=6;
    }else if(weekday ==2){
        //mon
        day = 0;
    }else if(weekday ==3){
        //tue
        day = 1;
    }else if(weekday ==4){
        //wen
        day = 2;
    }else if(weekday ==5){
        //tur
        day = 3;
    }else if(weekday ==6){
        //fri
        day = 4;
    }else if(weekday ==7){
        //sat
        day = 5;
    }
    return day;
}
-(void)api:(BGMAPI *)api requestFailedWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return [daylist count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [[[daylist objectAtIndex:section] objectForKey:@"items"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DailyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DailyCell" forIndexPath:indexPath];
    NSUInteger row = [indexPath row];
    NSArray *arr = daylist[indexPath.section][@"items"][row];
    
    cell.titlelabel.text = [HTMLEntityDecode htmlEntityDecode:[arr valueForKey:@"name"]];
    cell.sublabel.text = [HTMLEntityDecode htmlEntityDecode:[arr valueForKey:@"name_cn"]];
    
    //[cell.icon setImageWithURL:[[arr valueForKey:@"images"] valueForKey:@"grid"]];
    //[cell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    cell.ratscorelabel.text = [NSString stringWithFormat:@"%@分",[[[arr valueForKey:@"rating"] valueForKey:@"score"] stringValue]];
    
    if ([arr valueForKey:@"images"] != [NSNull null]) {
        NSString *imgurlstr =[[arr valueForKey:@"images"] valueForKey:@"small"];
        
        //NSLog(@"imageurlstr:%@",imgurlstr);
        if (imgurlstr.length > 0) {
            cell.icon.image = nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgurlstr]];
                if (imgData) {
                    UIImage *image = [UIImage imageWithData:imgData];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [cell.icon setImage:image];
                        });
                    }
                }
            });
        }

    }else{
        [cell.icon setImage:[UIImage imageNamed:@"bgm38a1024.png"]];
    }
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

-(UIView *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [[[daylist objectAtIndex:section] valueForKey:@"weekday"] valueForKey:@"cn"];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
//        BGMDetailViewController *detailview = [self.storyboard instantiateViewControllerWithIdentifier:@"BGMDetailViewController"];
//        detailview.bgmidstr = [daylist[indexPath.section][@"items"][indexPath.row] valueForKey:@"id"];
//        [self.navigationController pushViewController:detailview animated:YES];
//    }
//    
//}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    BGMDetailViewController *detailview = (BGMDetailViewController *)[[segue destinationViewController] topViewController] ;
    NSString *bgmid = [[daylist[indexPath.section][@"items"][indexPath.row] valueForKey:@"id"] stringValue];
    detailview.bgmidstr = bgmid;
    if (debugmode == YES) {
        NSLog(@"bgmid pass:%@",bgmid);
    }
    [detailview startGetSubjectInfoWithID:bgmid];
    detailview.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    detailview.navigationItem.leftItemsSupplementBackButton = YES;
    
}
-(void)getUserActivityState:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString *bgmid = userInfo[@"bgmid"];
    BGMDetailViewController *detailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"BGMDetailViewController"];
    detailVC.bgmidstr = bgmid;
    if (debugmode) {
        NSLog(@"restoreUserActivityState:%@ in SplitView",bgmid);
    }
    [detailVC startGetSubjectInfoWithID:bgmid];
    detailVC.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    detailVC.navigationItem.leftItemsSupplementBackButton = YES;
    //[self.navigationController pushViewController:detailVC animated:YES];
    [self.splitViewController showDetailViewController:detailVC sender:self];
    
    //[self.userActivity invalidate];
}
-(void)shortCutReceived:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    if([[userInfo valueForKey:@"key1"]  isEqual: @"rakuen"] ){
        SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:rakuenURL] entersReaderIfAvailable:NO];
        safariVC.delegate = self;
        [self presentViewController:safariVC animated:YES completion:nil];
    }
}
-(void)registHomeScreenQuickActions{
    UIApplicationShortcutItem *item1 = [[UIApplicationShortcutItem alloc]
                                       initWithType:@"com.HTandL.bgmclient.test"
                                       localizedTitle:@"打开超展开"
                                       localizedSubtitle:nil
                                        icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeFavorite]
                                        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"rakuen",@"key1", nil]];
    [[UIApplication sharedApplication] setShortcutItems:@[item1]] ;
}
@end
