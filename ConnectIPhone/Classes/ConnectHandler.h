//
//  ConnectHandler.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CommonCrypto/CommonDigest.h>
#import "SBJSON.h"
#import "ConnectDefine.h"


@interface ConnectHandler : UITableViewCell {
	
}


-(NSString*)doSearch:(NSString*)query: (NSString*)userID: (NSString*)myPass;
-(NSString*)makeConnection:(NSString*)userID: (NSString*)otherID: (NSString*)comment: (NSString*)myPass;
-(void)parseConnection:(NSString*)result;
-(NSArray*)parseView:(NSString*)result;
-(NSString*)viewConnections:(NSString*)userID: (NSString*)myPass;
-(NSString*)confirmConnection:(NSString*)userID: (NSString*)otherID: (NSString*)myPass: (NSString*)action;
-(NSString*)hashPass:(NSString*)myPass;
-(NSArray*)parseSearch:(NSString *)result;

@end
