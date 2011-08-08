//
//  PeopleViewController.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/26/11.
//  Copyright 2011  Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectDefine.h"
#import "ConnectHandler.h"

@interface PeopleViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate> {
	ConnectHandler *cHandle;
	NSString *userID;
	NSString *password;
	NSString *query;
	NSString *otherID;
	NSMutableArray *listData;
	IBOutlet UITableView *listTable;
	IBOutlet UISearchBar *mySearchBar;
	NSUInteger row;
}

-(void)loadSearch:(NSString *)q;

@end
