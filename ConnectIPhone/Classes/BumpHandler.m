//
//  BumpHandler.m
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import "BumpHandler.h"

@implementation BumpHandler

-(id) init {
	if (self = [super init]) {
	}
	return self;
}

//initialize bump with the API key
-(void)configBump
{
	[bumpObject configAPIKey:APIKEY];
	NSLog(@"Print api key %@", APIKEY);
	[bumpObject configDelegate:self];
	[bumpObject configParentView:nil];
	[bumpObject configActionMessage:@"Starting BUMP"];
	
}

-(void)startBump {
	[self configBump];
	[bumpObject requestSession];
}

-(void)stopBump {
	[bumpObject endSession];	
	
}

-(void)bumpConnection
{
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *bumpUser = [defaults objectForKey:kUserID];
	NSLog(@"Bump User ID: %@", bumpUser);
	NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithCapacity:2];
	[userDict setObject:[[bumpObject me] bumpUser] forKey:@"USER_ID"];
	NSData *connectChunk = [NSKeyedArchiver archivedDataWithRootObject:userDict];
	[userDict release];
	[bumpObject sendData:connectChunk];
}

-(void)bumpDataReceived:(NSData *)chunk
{
	NSDictionary *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	NSArray *keys = [responseDictionary allKeys];
	for (id key in keys)
	{
		NSLog(@" key = %@   value = %@", key, [responseDictionary objectForKey:key]);
	}
	
	bumpedID = [responseDictionary objectForKey:@"USER_ID"];
	
	NSLog(@"User id was %@", bumpedID);
	
}

-(NSString*)bumpData {
	return bumpedID;	
}

-(void)bumpSessionStartedWith:(Bumper *)otherBumper
{
	//nothing right now
}

-(void)bumpSessionEnded:(BumpSessionEndReason)reason
{
	//nothing right now
}


-(void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason
{
	NSString *alertText;
	switch (reason) {
		case FAIL_NETWORK_UNAVAILABLE:
			alertText = @"Please check your network settings and try again";	
			break;
		case FAIL_INVALID_AUTHORIZATION:
			alertText = @"Failed to connect to bump due to authorization error";
			break;
		default:
			alertText = @"Failed to connect to bump service";
			break;
	}
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection failed" message:alertText 
												   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}



- (void)dealloc {
	[bumpObject release];
	[bumpedID release];
    [super dealloc];
}


@end
