//
//  ConfirmViewController.m
//  ConnectIPhone
//
//  Created by CONNECT on 5/26/11.
//  Copyright 2011  Team MACK. All rights reserved.
//

#import "ConfirmViewController.h"


@implementation ConfirmViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.editing = YES;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	//initiate the connection handler, get the json response
	cHandle = [ConnectHandler new];
	NSString *response = [cHandle viewConnections:userID :[cHandle hashPass:password]];
	confirmData = (NSMutableArray*)[cHandle parseView:response];
	
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [super viewDidLoad];
}

//when view appears, reload data
-(void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	//initiate the connection handler, get the json response
	cHandle = [ConnectHandler new];
	NSString *response = [cHandle viewConnections:userID :[cHandle hashPass:password]];
	confirmData = (NSMutableArray*)[cHandle parseView:response];
	[confirmTable reloadData];
	[response release];
	[super viewWillAppear:animated];
}

//release data upon closing
-(void)viewWillDisappear:(BOOL)animated
{
	[confirmData release];
	[super viewWillAppear:animated];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//when user clicks refresh, repopulate array, set to a button
-(IBAction) loadConfirmations:(id)sender{
	self.editing = YES;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	NSString *response = [cHandle viewConnections:userID :[cHandle hashPass:password]];
	confirmData = (NSMutableArray*)[cHandle parseView:response];
	[confirmTable reloadData];
	[response release];
}

//same as above, no button
-(void) loadConfirmations{
	self.editing = YES;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	NSString *response = [cHandle viewConnections:userID :[cHandle hashPass:password]];
	confirmData = (NSMutableArray*)[cHandle parseView:response];
	[confirmTable reloadData];
	[response release];
}

- (void)dealloc {
	[confirmData release];
    [super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
	return [confirmData count];
}


-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{	
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
	}
	row = [indexPath row];
	NSMutableString *cellText = [[NSMutableString alloc] initWithString:[[confirmData objectAtIndex:row] objectAtIndex:0]];
	[cellText appendString:@" "];
	[cellText appendString:[[confirmData objectAtIndex:row] objectAtIndex:1]];
	[cellText appendString:@", "];
	[cellText appendString:[[confirmData objectAtIndex:row] objectAtIndex:2]];
	cell.textLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.textColor = [UIColor whiteColor];
	cell.detailTextLabel.text = [[confirmData objectAtIndex:row] objectAtIndex:3];
	cell.textLabel.text = cellText;
	[cellText release];
	return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	row = [indexPath row];
	connID = [[confirmData objectAtIndex:row] objectAtIndex:4];
	NSMutableString *name = [[NSMutableString alloc] initWithString:@"Confirm connection with "];
	[name appendString:[[confirmData objectAtIndex:row]objectAtIndex:0]];
	[name appendString:@" "];
	[name appendString:[[confirmData objectAtIndex:row]objectAtIndex:1]];
	[name appendString:@"?"];
	UIAlertView *cAlert = [[UIAlertView alloc]initWithTitle:nil message:name delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Confirm", @"Ignore", nil];
	[cAlert show];
	[cAlert release];
	[name release];
}

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (self.editing && indexPath.row == ([confirmData count]))
		return UITableViewCellEditingStyleInsert;
	else {
		return UITableViewCellEditingStyleDelete;
	}
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	[confirmTable beginUpdates];
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		[confirmData removeObjectAtIndex:indexPath.row];
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[cell setUserInteractionEnabled:NO];
		cell.selected = NO;
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
	else {
	}
	[confirmTable endUpdates];
}

-(BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}

-(void)alertView:(UIAlertView*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//buttonIndex 1 is confirm, 2 is ignore, 3 is later (automatically closes, not needed here)
	if (buttonIndex == 1)
	{
		[cHandle confirmConnection:userID :connID :[cHandle hashPass:password] :@"confirm"];
	}
	if (buttonIndex == 2)
	{
		[cHandle confirmConnection:userID :connID :[cHandle hashPass:password] :@"ignore"];
	}
	[self loadConfirmations];
}


@end
