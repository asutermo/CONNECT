//
//  ConnectIPhoneViewController.h
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team MACK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectHandler.h"
#import "BumpHandler.h"

@interface ConnectIPhoneViewController : UIViewController{
	
	//set up the variables needed to capture ID, and comments
	//also set up the necessary kb stuff
	IBOutlet UITextField *IDField;
	IBOutlet UITextField *commentField;
	IBOutlet UITextField *tField;
	BumpHandler *bumper;
	NSString *userID;
	NSString *password;
	BOOL moveViewUp;
	CGFloat scrollAmount;
}

@property (nonatomic, retain) UITextField *IDField;
@property (nonatomic, retain) UITextField *commentField;
@property (nonatomic, retain) UITextField *tField; 

-(IBAction) submitConnection:(id)sender;
-(IBAction) textFieldDoneEditing:(id)sender;
-(IBAction) backgroundTap:(id)sender;
-(IBAction) bumpConnection:(id)sender;
-(void)scrollTheView:(BOOL)movedUP;
@end

