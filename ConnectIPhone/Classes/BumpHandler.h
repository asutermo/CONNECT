//
//  BumpHandler.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//


/*
 
 This file will declare the Bump functionality
 Two users with bump can initiate a connection 
 by "bumping" their two handsets against one
 another. This should make use of existing
 response/request protocols
 
 */
#import <UIKit/UIKit.h>
#import "Bumper.h"
#import "BumpAPI.h"
#import "ConnectDefine.h"
#import "ConnectHandler.h"

@interface BumpHandler : NSObject <BumpAPIDelegate> {
	
	BumpAPI *bumpObject;
	NSString *bumpedID;
}

-(void)configBump;
-(void)startBump;
-(void)bumpConnection;
-(NSString*)bumpData;
-(void)stopBump;

@end
