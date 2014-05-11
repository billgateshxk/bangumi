//
//  BGMDetailViewController.m
//  bangumi
//
//  Created by bi119aTe5hXk on 2014/04/19.
//  Copyright (c) 2014年 HT&L. All rights reserved.
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    userdefaults = [NSUserDefaults standardUserDefaults];
    bgmapi = [[BGMAPI alloc] initWithdelegate:self WithAuthString:[userdefaults stringForKey:@"auth_urlencoded"]];
    [bgmapi getSubjectInfoWithSubID:self.bgmid];
    request_type = @"BGMDetail";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.progressmanabtn setHidden:YES];
    [self.statusmanabtn setHidden:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [bgmapi cancelConnection];
}
-(void)viewWillAppear:(BOOL)animated{
    
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
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.progressmanabtn setHidden:NO];
    [self.statusmanabtn setHidden:NO];
    if ([request_type isEqualToString:@"BGMDetail"]) {
        self.titlelabel.text = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"name"]];
        self.titlelabel_cn.text = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"name_cn"]];
        [self.cover setImageWithURL:[NSURL URLWithString:[[list valueForKey:@"images"] valueForKey:@"common"]]];
        
        self.bgmsummary.text = [HTMLEntityDecode htmlEntityDecode:[list valueForKey:@"summary"]];
        
        [self.bgmsummary setFont:[UIFont systemFontOfSize:12]];
        CGSize stringSize = [self.bgmsummary.text sizeWithFont:[UIFont systemFontOfSize:12]
                             constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        
        [self.bgmsummary setFrame:CGRectMake(20, 212, 280, stringSize.height+200)];
        [self.scrollview setContentSize:CGSizeMake(320, stringSize.height + 300)];
        [self.scrollview setScrollEnabled:YES];
        
        progresslist = [list valueForKey:@"eps"];
        
    }
    
    if ([request_type isEqualToString:@"updateStatus"]) {
        if ([[list valueForKey:@"error"] isEqualToString:@"OK"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已成功记录"
                                                            message:[list valueForKey:@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"了解"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"记录失败"
                                                            message:[list valueForKey:@"error"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"了解"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
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
    ProgressListViewController *progressview = [self.storyboard instantiateViewControllerWithIdentifier:@"ProgressListViewController"];
    progressview.subid = self.bgmid;
    progressview.progresslist = progresslist;
    [self.navigationController pushViewController:progressview animated:YES];
}
-(IBAction)BGMStatuesBTN:(id)sender{
    UIAlertView *stateAlert = [[UIAlertView alloc] initWithTitle:@"修改番组状态"
                                                         message:nil
                                                        delegate:self
                                               cancelButtonTitle:@"保持不变"
                                               otherButtonTitles:@"想看",@"在看",@"看过",@"搁置",@"抛弃", nil];
    [stateAlert setTag:998];
    [stateAlert show];
}
-(void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 998) {
        if (buttonIndex == 1) {
            //想看
            [bgmapi setCollectionWithColID:self.bgmid WithRating:0 WithStatus:@"wish"];
        }else if (buttonIndex == 2){
            //在看
            [bgmapi setCollectionWithColID:self.bgmid WithRating:0 WithStatus:@"do"];
        }else if (buttonIndex == 3){
            //看过
            [bgmapi setCollectionWithColID:self.bgmid WithRating:0 WithStatus:@"collect"];
        }else if (buttonIndex == 4){
            //搁置
            [bgmapi setCollectionWithColID:self.bgmid WithRating:0 WithStatus:@"on_hold"];
        }else if (buttonIndex == 5){
            //抛弃
            [bgmapi setCollectionWithColID:self.bgmid WithRating:0 WithStatus:@"dropped"];
        }
        request_type = @"updateStatus";
    }
}
@end
