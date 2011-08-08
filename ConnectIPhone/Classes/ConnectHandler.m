//
//  ConnectHandler.m
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import "ConnectHandler.h"

@implementation ConnectHandler


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state.
}


//hash the password to submit
-(NSString*)hashPass:(NSString*)myPass
{
	NSData *data = [myPass dataUsingEncoding:NSUTF8StringEncoding];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, data.length, digest);
	NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
	for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
		[output appendFormat:@"%02x", digest[i]];
	return output;
}

/*
 *makeConnection takes the userID, the other IDs that user entered, a comment and the passowrd
 *It then proceeds to build an http POST request. It sends the request, and upon receipt, we are
 *given a response. The JSON data is then extracted, put into a dictionary and returned
 *
 */
-(NSString*)makeConnection:(NSString *)userID :(NSString *)otherID :(NSString *)comment :(NSString *)myPass
{
	//build HTTP post request (API call)
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:BASEDEVURLCONNECT]]];
	[request setHTTPMethod:@"POST"];
	
	//add the payload to be sent with request
	NSMutableString *post = [[NSMutableString alloc] init];
	[post appendFormat:@"id=%@", [userID uppercaseString]];
	[post appendFormat:@"&hashpass=%@", myPass];
	[post appendFormat:@"&id_2=%@", [otherID uppercaseString]];
	[post appendFormat:@"&comment=%@", comment];
	//[post appendFormat:@"&conference=%@", conference];
	
	//build the request with the proper data
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	 
	//build the response to capture the information coming back
	NSData *response = [[[NSMutableData alloc] init] autorelease];
	NSString *jsonString;
	
	//try to send the request, if there's any issues, then log it
	@try {
		
		//If connection is established, we have a "true" value, otherwise 
		//connection failed
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		
		//if connection is established, pull all the information into an array to hold the
		//JSON values
		if (connection)
		{
			response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
			jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
			
		}
		else {
			NSLog(@"Failed connection!");
		}
		[connection release];

	}
	@catch (NSException * e) {
		NSLog(@"Request Exception: %@", e);
	}
	
	[post release];
	return jsonString;
}

/*
 *parseConnection is dedicated to searching/parsing the JSON data
 *for successful connections and for errors
 *
 */
-(void)parseConnection:(NSString*)result
{
	//set up variables to hold the information, this will server
	//for the alert system and checking for errors
	//NSLog(@"The result passed in: %@", result);
	NSMutableString *textResult = [[NSMutableString alloc] initWithCapacity:0];
	NSMutableString *errors = [[NSMutableString alloc] initWithCapacity:0];
	NSMutableString *title = [[NSMutableString alloc] initWithCapacity:0];
	BOOL hasErrors = FALSE;
	BOOL connectionSucc = FALSE;
	
	@try {
		SBJsonParser *parser = [[SBJsonParser alloc] init];
		NSDictionary *json = [parser objectWithString:result error:nil];	
		if ([json valueForKey:@"members"])
		{
			NSMutableArray *members = [json objectForKey:@"members"];
			
			if ([members count] > 0) {
				connectionSucc = TRUE;
				[textResult appendString:@"You submitted a CONNECTion with: \n "];
				for (int i = 0; i < [members count]; i++) {
					
					//and to separate
					if (i > 0){						
						[textResult appendString:@"\nand "];
					}
					
					NSString *connectInfo = [NSString stringWithFormat:@"%@",[members objectAtIndex:i]];
					NSString *connectInfoParsedFront = [connectInfo substringFromIndex:[connectInfo rangeOfString:@"\""].location +[connectInfo rangeOfString:@"\""].length];
					NSString *connectInfoParsedBack = [connectInfoParsedFront substringToIndex:[connectInfoParsedFront rangeOfString:@"\""].location];
					[textResult appendString:connectInfoParsedBack];	
				}
			}
		}
		
		if ([json valueForKey:@"error"] || !connectionSucc) {
			hasErrors = TRUE;
			[errors appendString:@"The CONNECT server was unreachable or didn't return a properly formatted response"];	
			
		}
		[parser release];
	}
	@catch (NSException * e) {
		connectionSucc = FALSE;
		hasErrors = TRUE;
		NSLog(@"Exception caused: %@", e);
		[errors appendString:@"The CONNECT server was unreachable or didn't return a properly formatted response"];
	}
	
	//if connection to other ids succeeded, set the string to say so
	if (connectionSucc)
		[title appendString:@"CONNECTion was successful"];
	else
		[title appendString:@"CONNECTion failed"];
	
	//if there are errors, display them to user
	if (hasErrors)
	{
		[textResult appendString:@"CONNECT had errors: "];
		[textResult appendString:errors];
	}
	
	UIAlertView *alert;
	
	//display alert with errors or without
	if (hasErrors){
		alert = [[UIAlertView alloc]
							  initWithTitle:title
							  message:textResult
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
	}else {
		alert = [[UIAlertView alloc]
							  initWithTitle:title
							  message:textResult
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
	}
	
	[alert show];
	[alert release];
	[textResult release];
	[errors release];
	[title release];
}

- (void)dealloc {
    [super dealloc];
}


/*
 *viewConnections takes your user id and your password, it returns a json string
 *containing all of the connections you have made or sent
 *
 */
-(NSString*)viewConnections:(NSString*)userID: (NSString*)myPass
{
	//build HTTP post request (API call)
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:BASEDEVURLVIEW]]];
	[request setHTTPMethod:@"POST"];
	
	//add the payload to be sent with request
	NSMutableString *post = [[NSMutableString alloc] init];
	[post appendFormat:@"id=%@", [userID uppercaseString]];
	[post appendFormat:@"&hashpass=%@", myPass];
	[post appendFormat:@"&statuses=0"];
	[post appendFormat:@"&get_people="];
	//[post appendFormat:@"&conference=%@", conference];
	
	//build the request with the proper data
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	//build the response to capture the information coming back
	NSData *response = [[[NSMutableData alloc] init] autorelease];
	NSString *jsonString;
	
	//try to send the request, if there's any issues, then log it
	@try {
		
		//If connection is established, we have a "true" value, otherwise 
		//connection failed
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		
		//if connection is established, pull all the information into an array to hold the
		//JSON values
		if (connection)
		{
			response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
			jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
		}
		else {
			NSLog(@"Failed connection!");
		}
		[connection release];
		
	}
	@catch (NSException * e) {
		NSLog(@"Request Exception: %@", e);
	}
	
	[post release];
	return jsonString;
}

/*
 *parseView is dedicated to searching/parsing the JSON data
 *for a successful connections to view
 *
 */
-(NSArray*)parseView:(NSString*)result
{
	//set up variables to hold the information, this will server
	//for the alert system and checking for errors
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	@try {
		SBJsonParser *parser = [[SBJsonParser alloc] init];
		NSDictionary *json = [parser objectWithString:result error:nil];
		
		NSString *connsString = [NSString stringWithFormat:@"%@",[json objectForKey:@"conns"]];
		NSArray *connsArray = [connsString componentsSeparatedByString:@","];
		NSString *peopleString = [NSString stringWithFormat:@"%@", [json objectForKey:@"people"]];
		NSArray *peopleArray = [peopleString componentsSeparatedByString:@","];

		for (int i = 0; i < [connsArray count]; i++){
			
			/*String parsing*/
			NSString *mainString = [connsArray objectAtIndex:i];
			NSString *pplString = [peopleArray objectAtIndex:i];
			NSString *comment;
			@try{
				NSString *commentFront = [mainString substringFromIndex:([mainString rangeOfString:@"comment = \""].location +[mainString rangeOfString:@"comment = \""].length)];
				comment = [commentFront substringToIndex:[commentFront rangeOfString:@"\""].location];
			}@catch (NSException *e) {
				comment = @"";
			}
			
			NSString *connIDFront = [mainString substringFromIndex:([mainString rangeOfString:@"id = "].location +[mainString rangeOfString:@"id = "].length)];
			NSString *connID = [connIDFront substringToIndex:[connIDFront rangeOfString:@";"].location];
			NSString *userIDFront = [mainString substringFromIndex:[mainString rangeOfString:@"member_list\" =         {\n            "].location +[mainString rangeOfString:@"member_list\" =         {\n            "].length];
			NSString *userID = [userIDFront substringToIndex:[userIDFront rangeOfString:@" ="].location];
			NSString *fNameFront = [pplString substringFromIndex:([pplString rangeOfString:@"fn = "].location + [pplString rangeOfString:@"id = "].length)];
			NSString *fName = [fNameFront substringToIndex:[fNameFront rangeOfString:@";"].location];
			NSString *lNameFront = [pplString substringFromIndex:([pplString rangeOfString:@"ln = "].location + [pplString rangeOfString:@"id = "].length)];
			NSString *lName = [lNameFront substringToIndex:[lNameFront rangeOfString:@";"].location];
			NSMutableArray *info = [[NSMutableArray alloc] initWithCapacity:5]; 
			
			//add values to array
			[info addObject:lName];
			[info addObject:fName];
			[info addObject:userID];
			[info addObject:comment];
			[info addObject:connID];
			
			//add array to another array
			[returnArray addObject:info];
			[info release];
		}
		
		[parser release];
		
	}
	@catch (NSException * e) {
		NSLog(@"Viewing exception caused %@", e);
	}
	
	return returnArray;
}

/*
 *confirmConnection is new to the mobile side, it takes a user id, another id, a password and 
 *an action (c for confirm, i for ignore). It allows users to finish the process of a 
 *connection on their phone
 */
-(NSString*)confirmConnection:(NSString*)userID: (NSString*)otherID: (NSString*)myPass: (NSString*) action
{
	//build HTTP post request (API call)
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:[NSString stringWithFormat:BASEDEVURLCONFIRM]]];
	[request setHTTPMethod:@"POST"];
	
	//add the payload to be sent with request
	NSMutableString *post = [[NSMutableString alloc] init];
	[post appendFormat:@"id=%@", [userID uppercaseString]];
	[post appendFormat:@"&hashpass=%@", myPass];
	[post appendFormat:@"&conn=%@", [otherID uppercaseString]];
	[post appendFormat:@"&action=%@", action];
	//[post appendFormat:@"&conference=%@", conference];
	
	//build the request with the proper data
	NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
	NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
	[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:postData];
	
	//build the response to capture the information coming back
	NSData *response = [[[NSMutableData alloc] init] autorelease];
	NSString *jsonString;
	
	//try to send the request, if there's any issues, then log it
	@try {
		
		//If connection is established, we have a "true" value, otherwise 
		//connection failed
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		
		//if connection is established, pull all the information into an array to hold the
		//JSON values
		if (connection)
		{
			response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
			jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];		}
		else {
			NSLog(@"Failed connection!");
		}
		[connection release];
		
	}
	@catch (NSException * e) {
		NSLog(@"Request Exception: %@", e);
	}
	
	[post release];
	return jsonString;
}


//this takes a query and sends it to the webapi to search for people
-(NSString*)doSearch:(NSString*)query :(NSString*)userID :(NSString*)myPass
{
	//build HTTP get request (API call)
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSMutableString *url = [NSMutableString stringWithFormat:BASEDEVURLSEARCH];
	[url appendString:@"?q="];
	if (query != @""){
		[url appendString:query];
	}else {
		[url appendString:@"+"];
	}
	[url appendString:@"&id="];
	[url appendString:[userID uppercaseString]];
	[url appendString:@"&hashpass="];
	[url appendString:myPass];
	[request setURL:[NSURL URLWithString:url]];
	[request setHTTPMethod:@"GET"];
	
	//build the response to capture the information coming back
	NSData *response = [[[NSMutableData alloc] init] autorelease];
	NSString *jsonString;
	
	//try to send the request, if there's any issues, then log it
	@try {
		
		//If connection is established, we have a "true" value, otherwise 
		//connection failed
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
		
		//if connection is established, pull all the information into an array to hold the
		//JSON values
		if (connection)
		{
			response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];	
			jsonString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
			//NSLog(@"Returned json string is: %@", jsonString);
		}
		else {
			NSLog(@"Failed connection!");
		}
		[connection release];
		
	}
	@catch (NSException * e) {
		NSLog(@"Request Exception: %@", e);
	}
	
	return jsonString;
}

//parse the search query so we can populate a table
-(NSArray*)parseSearch:(NSString*)result
{
	//set up variables to hold the information, this will server
	//for the alert system and checking for errors
	NSMutableArray *returnArray = [[NSMutableArray alloc] init];
	@try {
		SBJsonParser *parser = [[SBJsonParser alloc] init];
		NSDictionary *json = [parser objectWithString:result error:nil];

		NSString *contactsString = [NSString stringWithFormat:@"%@",[json objectForKey:@"contacts"]];
		NSArray *contactsArray = [contactsString componentsSeparatedByString:@","];
		
		for (int i = 0; i < [contactsArray count]; i++){
			
			/*String parsing*/
			NSString *mainString = [contactsArray objectAtIndex:i];
			
			NSString *IDFront = [mainString substringFromIndex:[mainString rangeOfString:@"id = "].location +[mainString rangeOfString:@"id = "].length];
			NSString *ID = [IDFront substringToIndex:[IDFront rangeOfString:@";"].location];
			NSString *NameFront = [mainString substringFromIndex:([mainString rangeOfString:@"name = \""].location + [mainString rangeOfString:@"name = \""].length)];
			NSString *Name = [NameFront substringToIndex:[NameFront rangeOfString:@"\""].location];
		
			NSMutableArray *info = [[NSMutableArray alloc] initWithCapacity:2]; 
			
			//add values to array
			[info addObject:Name];
			[info addObject:ID];
			
			//add array to another array
			[returnArray addObject:info];
			[info release];
			 
		}
		
		[parser release];
	}
	@catch (NSException * e) {
		NSLog(@"Viewing exception caused %@", e);
	}
	return returnArray;
}

@end
