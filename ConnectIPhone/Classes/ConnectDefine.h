//
//  ConnectDefine.h
//  ConnectIPhone
//
//  Created by CONNECT on 6/9/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>


//do not delete or change these unless absolutely critical
//prefix of k means it is loaded from iPhone settings dictionary. don't touch
#define kUserID @"user_id"
#define kPassword @"password"

//API key refers to bump api, don't change unless key has been updated by the CONNECT team
#define APIKEY @"606afb88058c4fc6959320cffb16c242"

//these are hard-coded urls. anything with dev in it refers to the development side of 
//connect and therefore uses the demo database.
#define BASEURLCONNECT @"http://toilers.mines.edu/connect/webapi/make_connection"
#define BASEDEVURLCONNECT @"http://toilers.mines.edu/connect-dev/webapi/make_connection"
#define BASEDEVURLVIEW @"http://toilers.mines.edu/connect-dev/webapi/view_connections"
#define BASEDEVURLSEARCH @"http://toilers.mines.edu/connect-dev/webapi/get_name_list"
#define BASEDEVURLCONFIRM @"http://toilers.mines.edu/connect-dev/webapi/confirm_connection"