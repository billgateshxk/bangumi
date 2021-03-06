//
//  BGMDetailViewController.m
//  bangumi
//
//  Created by bi119aTe5hXk on 2014/04/19.
//  Copyright (c) 2014年 bi119aTe5hXk. All rights reserved.
//

#import "BGMDetailViewController.h"

@interface BGMDetailViewController ()

@end

@implementation BGMDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        //[self configureView];
    }
}
-(void)startGetSubjectInfoWithID:(NSString *)bgmid{
    userdefaults = [[NSUserDefaults alloc] initWithSuiteName:groupName];
    bgmapi = [[BGMAPI alloc] initWithdelegate:self];
    auth = [userdefaults stringForKey:@"auth"];
    
    
    
    if ((unsigned long)bgmid.length > 0) {
        [bgmapi cancelConnection];
        self.bgmidstr = bgmid;
        [bgmapi getSubjectInfoWithSubID:bgmid];
        request_type = @"BGMDetail";
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.progressmanabtn setHidden:YES];
        [self.statusmanabtn setHidden:YES];
        bgmid1 = bgmid;
        [self setHandOff];
        
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"出错了！" message:@"BGMID长度为0。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错了！"
//                                                        message:@"BGMID长度为0。"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil, nil];
//        [alert show];
    }
    
}
-(void)setHandOff{
    NSUserActivity *activity;
    activity = [[NSUserActivity alloc] initWithActivityType:appIdentifier];
    activity.title = @"Bangumi+";
    activity.userInfo = @{@"bgmid" : bgmid1};
    self.userActivity = activity;
    [activity addUserInfoEntriesFromDictionary:@{@"bgmid" : bgmid1}];
    [activity setEligibleForHandoff:YES];
    [activity becomeCurrent];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"番组详细";
    
    //[self startGetSubjectInfoWithID:self.bgmidstr];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [bgmapi cancelConnection];
    bgmapi = nil;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    self.titlelabel.text = @"";
//    self.titlelabel_cn.text = @"";
//    self.bgmsummary.text = @"";
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)api:(BGMAPI *)api readyWithList:(NSArray *)list{
    dispatch_async(dispatch_get_main_queue(),^{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    if ([request_type isEqualToString:@"updateStatus"]) {
        dispatch_async(dispatch_get_main_queue(),^{//get main thread
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"已成功记录" message:[[list valueForKey:@"status"] valueForKey:@"type"] preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"了解" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已成功记录"
//                                                        message:[[list valueForKey:@"status"] valueForKey:@"type"]
//                                                       delegate:nil
//                                              cancelButtonTitle:@"了解"
//                                              otherButtonTitles:nil, nil];
//
//        [alert show];
            });
    }
    
    
    
    if ([request_type isEqualToString:@"BGMDetail"]) {
        NSString *titlestr = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"name"]];
        NSString *titlecnstr = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"name_cn"]];
        NSString *bgmsummarystr = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"summary"]];
        
        dispatch_async(dispatch_get_main_queue(),^{//get main thread
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [self.progressmanabtn setHidden:NO];
            [self.statusmanabtn setHidden:NO];
            [self.titlelabel setText:titlestr];
            [self.titlelabel_cn setText:titlecnstr];
            [self.bgmsummary setText:bgmsummarystr];
            [self.ratscore setText:[NSString stringWithFormat:@"%@/10",[[[list valueForKey:@"rating"] valueForKey:@"score"] stringValue]] ];
            [self.rankscore setText:[[list valueForKey:@"rank"] stringValue] ];
            [self.ratscore setHidden:NO];
            [self.ratscoretitle setHidden:NO];
            [self.bgmdetailbtn setHidden:NO];
            [self.actionbtn setEnabled:YES];
            [self.rankscore setHidden:NO];
            [self.ranktitle setHidden:NO];
            [self setHandOff];
        });
        
        
        
        //[self.cover setImageWithURL:[NSURL URLWithString:[[list valueForKey:@"images"] valueForKey:@"common"]]];
        if ([list valueForKey:@"images"] != [NSNull null]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[list valueForKey:@"images"] valueForKey:@"large"]]];
                if (imgData) {
                    UIImage *image = [UIImage imageWithData:imgData];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.cover setImage:image];
                        });
                    }
                }
            });
        }else{
            [self.cover setImage:[UIImage imageNamed:@"bgm38a1024.png"]];
        }
        

        
//        [self.bgmsummary setFont:[UIFont systemFontOfSize:12]];
//        CGSize stringSize = [self.bgmsummary.text sizeWithFont:[UIFont systemFontOfSize:12]
//                             constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
//                                 lineBreakMode:NSLineBreakByWordWrapping];
//        [self.bgmsummary setFrame:CGRectMake(20, 212, 280, stringSize.height+200)];
//        [self.scrollview setContentSize:CGSizeMake(320, stringSize.height + 300)];
//        [self.scrollview setScrollEnabled:YES];

        //remove sp
        if ([list valueForKey:@"eps"] != [NSNull null]) {
            NSArray *arr = [list valueForKey:@"eps"];
            NSArray *newlist = [NSArray array];
            for (int i=0; i<[arr count]; i++) {
                
                if ([[[arr objectAtIndex:i] valueForKey:@"type"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    newlist = [newlist arrayByAddingObject:[arr objectAtIndex:i]];
                }else{
                    
                }
            }
            
        progresslist = newlist;
        }else{
            progresslist = [NSArray array];
        }
    }
    
    
    
    });
    
    
    
}
-(void)api:(BGMAPI *)api requestFailedWithError:(NSError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    if ([segue.identifier isEqualToString:@"ProgressListViewController"]) {
//        ProgressListViewController *progressview = [segue destinationViewController];
//        progressview.subid = self.bgmid;
//        NSLog(@"bgmid:%@",self.bgmid);
//    }else if ([segue.identifier isEqualToString:@"BGMStatSettingViewController"]){
//        
//    }
//}


-(IBAction)PorgressViewBTN:(id)sender{
    auth = [userdefaults stringForKey:@"auth"];
    if([auth length]>0){
        ProgressListViewController *progressview = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgressListViewController"];
        progressview.subid = self.bgmidstr;
        progressview.progresslist = progresslist;
        [self.navigationController pushViewController:progressview animated:YES];
    }else{
        self.loginviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController presentViewController:self.loginviewcontroller animated:YES completion:NULL];
    }
    
}
-(IBAction)BGMStatuesBTN:(id)sender{
    auth = [userdefaults stringForKey:@"auth"];
    if([auth length]>0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改番组状态" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"想看" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"wish"];
                                                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                              request_type = @"updateStatus";
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"在看" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"do"];
                                                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                              request_type = @"updateStatus";
                                                              
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"看过" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"collect"];
                                                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                              request_type = @"updateStatus";
                                                              
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"搁置" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"on_hold"];
                                                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                              request_type = @"updateStatus";
                                                              
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"抛弃" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"dropped"];
                                                              [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                              request_type = @"updateStatus";
                                                              
                                                          }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"保持不变" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              nil;
                                                          }]];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:^{
                             nil;
                             //NSLog(@"displayed");
                         }];
        
    }else{
        self.loginviewcontroller = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [self.navigationController presentViewController:self.loginviewcontroller animated:YES completion:NULL];
    }
    
    
    
//    UIAlertView *stateAlert = [[UIAlertView alloc] initWithTitle:@"修改番组状态"
//                                                         message:nil
//                                                        delegate:self
//                                               cancelButtonTitle:@"保持不变"
//                                               otherButtonTitles:@"想看",@"在看",@"看过",@"搁置",@"抛弃", nil];
//    [stateAlert setTag:998];
//    [stateAlert show];
//}
//-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 998) {
//        if (buttonIndex >0) {
//            if (buttonIndex == 1) {
//                //想看
//                [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"wish"];
//            }else if (buttonIndex == 2){
//                //在看
//                [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"do"];
//            }else if (buttonIndex == 3){
//                //看过
//                [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"collect"];
//            }else if (buttonIndex == 4){
//                //搁置
//                [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"on_hold"];
//            }else if (buttonIndex == 5){
//                //抛弃
//                [bgmapi setCollectionWithColID:self.bgmidstr WithRating:0 WithStatus:@"dropped"];
//            }
//            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            request_type = @"updateStatus";
//        }
//    }
}
-(IBAction)showDetailWebBTN:(id)sender{
    NSString *disscussurl = [NSString stringWithFormat:@"http://bgm.tv/subject/%@",bgmid1];
//    WebViewController *webview  = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
//    webview.urlstr = disscussurl;
//    webview.titlestr = @"作品详细";
//    [self.navigationController presentViewController:webview animated:YES completion:nil];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:disscussurl] entersReaderIfAvailable:NO];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}
-(IBAction)shareBTN:(id)sender{
    
    NSString *disscussurl = [NSString stringWithFormat:@"http://bgm.tv/subject/%@",bgmid1];
    UIActivityViewController *avc = [[UIActivityViewController alloc] initWithActivityItems:@[disscussurl] applicationActivities:@[]];
    
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:avc animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:avc];
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}
@end
