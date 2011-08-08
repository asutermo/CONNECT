//
//  ConfirmViewController.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/26/11.
//  Copyright 2011  Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectHandler.h"

@interface ConfirmViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate> {
	
	NSString *userID;
	NSString *password;
	NSString *connID;
	NSMutableArray *confirmData;
	NSUInteger row;
	ConnectHandler *cHandle;
	IBOutlet UITableView *confirmTable;
}


-(IBAction) loadConfirmations:(id)sender;
@end
