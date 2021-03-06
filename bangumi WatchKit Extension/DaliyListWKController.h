//
//  DaliyListWKController.h
//  bangumi
//
//  Created by bi119aTe5hXk on 2015/08/16.
//  Copyright (c) 2015年 bi119aTe5hXk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "BGMAPI.h"
#import "BGMWKCell.h"
#import "HTMLEntityDecode.h"
@interface DaliyListWKController : WKInterfaceController<BGMAPIDelegate>{
    NSArray *daylist;
    BGMAPI *api;
    
    NSDictionary   *_imageNameDict;
}
@property (nonatomic, strong) IBOutlet WKInterfaceTable *tableview;
-(IBAction)refreshbtn:(id)sender;
@end
