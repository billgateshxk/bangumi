//
//  SettingsViewController.h
//  bangumi
//
//  Created by bi119aTe5hXk on 2014/04/18.
//  Copyright (c) 2014年 bi119aTe5hXk. All rights reserved.
//

#import <UIKit/UIKit.h>
@import SafariServices;
//#import "WebViewController.h"
#import "LoginViewController.h"
@interface SettingsViewController : UITableViewController<BGMAPIDelegate,SFSafariViewControllerDelegate>{
    NSUserDefaults *userdefault;
    BGMAPI *bgmapi;
    NSString *auth;
}

@property (nonatomic, strong) IBOutlet UIButton *rakuenbtn;
@property (nonatomic, strong) IBOutlet UIButton *loginbtn;
@property (nonatomic, strong) LoginViewController *loginviewcontroller;
//@property (nonatomic ,strong)  WebViewController *webview;
//@property (nonatomic, strong) IBOutlet UILabel *creditText;

-(IBAction)openRakuen:(id)sender;
-(IBAction)loginbtnpressd:(id)sender;
@end
