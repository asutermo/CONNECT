//
//  ConnectIPhoneViewController.m
//  ConnectIPhone
//
//  Created by CONNECT on 5/24/11.
//  Copyright 2011 Team Mack. All rights reserved.
//

#import "ConnectIPhoneViewController.h"
@implementation ConnectIPhoneViewController

@synthesize IDField;
@synthesize commentField;
@synthesize tField;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;	
	if ([[defaults objectForKey:kUserID] length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc]
							 initWithTitle:@"Invalid"
							 message:[NSString stringWithFormat:@"Please go to iPhone settings and enter valid log-in id"]
							 delegate:nil
							 cancelButtonTitle:@"Okay"
							 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		
	}
	else if ([[defaults objectForKey:kPassword] length] == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Invalid"
							  message:[NSString stringWithFormat:@"Please go to iPhone settings and enter valid log-in password"]
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else {
		userID = [defaults objectForKey:kUserID];
		password = [defaults objectForKey:kPassword];
		
	}
	[super viewDidLoad];
}

/*
 *The following allows the keyboard to show and scroll 
 *when necessary
 *
 *Send a message to notification center, to receive the information needed
 *follow that by extracting the keyboard size and then compute our bottom 
 *point. Determine the scroll amount. Scroll only if we are in a certain
 *text field, otherwise no need to scroll
 *
 *This should also accomodate for landscape views. The scroll amount will change
 */
- (void)viewWillAppear:(BOOL)animated {
	

	void (^keyBoardWillShow) (NSNotification *)= ^(NSNotification * notif) {
		
		if(IDField.editing){tField = IDField;}
		else if(commentField.editing){tField = commentField;}
		
		
		NSDictionary* info = [notif userInfo];
		NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
		CGSize keyboardSize = [aValue CGRectValue].size;
		
		
		if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait){
			float bottomPoint = (tField.frame.origin.y + tField.frame.size.height - 50);
			scrollAmount = keyboardSize.height - (self.view.frame.size.height - bottomPoint);
		}
		else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft || [[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
			float bottomPoint = (tField.frame.origin.y + tField.frame.size.height - 48);
			scrollAmount = keyboardSize.width - self.view.frame.size.height + bottomPoint;
		}
		if (scrollAmount > 0 && tField.editing)  {
			moveViewUp =YES;
			[self scrollTheView:YES];
		}
		else
			moveViewUp = NO;
	};
	
	[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:self.view.window queue:nil 
												  usingBlock:keyBoardWillShow];
	
	void (^keyBoardWillHide) (NSNotification *)= ^(NSNotification * notif) { };
	[[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:self.view.window queue:nil 
												  usingBlock:keyBoardWillHide]; 
	
	[super viewWillAppear:animated];  
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil]; 
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil]; 
	[super viewWillDisappear:animated];
}

/*
 *When we scroll we want to animate it
 *We need the view's frame, and if the user clicks in a 
 *text box, we want to subtract the kb height from the frame
 *Afterwards, we want to be able to restore the kb to origin
 */
-(void) scrollTheView:(BOOL)movedUP {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	CGRect rect = self.view.frame;
	if(movedUP){
		rect.origin.y -= scrollAmount;
	}else {
		rect.origin.y += scrollAmount;
	}	
	
	self.view.frame = rect;
	[UIView commitAnimations];
	
}

 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
	 [tField resignFirstResponder];
 return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));
	
 }
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[bumper stopBump];
}

/*	
 * When user clicks return, kb should disappear
 * textFieldShouldReturn, textFieldDoneEdititng, and backgroundTap
 * all support multiple ways to make this disappear for usability
 */
-(BOOL)textFieldShouldReturn:(UITextField *)theTextField{
	[theTextField resignFirstResponder];
	if(moveViewUp){
		[self scrollTheView:NO];
		moveViewUp = NO;
	}
	return YES;
}


-(IBAction) textFieldDoneEditing:(id)sender {
	[sender resignFirstResponder];
	if(moveViewUp){
		[self scrollTheView:NO];
		moveViewUp = NO;
	}
}


-(IBAction) backgroundTap:(id)sender {
	[IDField resignFirstResponder];
	[commentField resignFirstResponder];
	if (commentField.editing || moveViewUp)
		[self scrollTheView:NO];
	if (moveViewUp)
		moveViewUp = NO;
}

-(IBAction) submitConnection:(id)sender{
	
	//grab information to submit
	NSString *theirID = IDField.text;
	NSString *aComment = commentField.text;
	
	//if user clicked submit, but didnt have anything to submit, tell them
	if ([theirID length] == 0 || [theirID isEqualToString:kUserID]){
		UIAlertView *alertInvalid = [[UIAlertView alloc]
							  initWithTitle:@"Invalid"
							  message:[NSString stringWithFormat:@"Please enter a valid id"]
							  delegate:nil
							  cancelButtonTitle:@"Okay"
							  otherButtonTitles:nil];
		[alertInvalid show];
		[alertInvalid release];
		return;
	}
	
	//initiate the connection handler, get the json response
	ConnectHandler *cHandle = [ConnectHandler new];
	NSString *response = [cHandle makeConnection:userID :theirID :aComment :[cHandle hashPass:password]];
	[cHandle parseConnection:response];
	
	//Clear all text fields, and release all objects
	[IDField setText:@""];
	[commentField setText:@""];
}

-(IBAction) bumpConnection:(id)sender
{
	@try {
		[bumper configBump];
		[bumper startBump];
		[bumper bumpConnection];
		IDField.text = [bumper bumpData];
	}
	@catch (NSException * e) {
		NSLog(@"\"Bump\" Exception caused: %@", e);
		UIAlertView *alertBump = [[UIAlertView alloc]
									 initWithTitle:@"Bump Failed"
									 message:[NSString stringWithFormat:@"Please try bumping again"]
									 delegate:nil
									 cancelButtonTitle:@"Okay"
									 otherButtonTitles:nil];
		[alertBump show];
		[alertBump release];
	}
}
/*
 deconstruct everything
 
 */
- (void)dealloc {
	[IDField release];
	[commentField release];
	[tField release];
	[super dealloc];
}

@end
