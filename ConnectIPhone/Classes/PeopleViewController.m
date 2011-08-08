//
//  PeopleViewController.m
//  ConnectIPhone
//
//  Created by CONNECT on 5/26/11.
//  Copyright 2011  Team MACK. All rights reserved.
//

#import "PeopleViewController.h"


@implementation PeopleViewController
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void)loadView
{
	[super loadView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.editing = YES;
	cHandle = [ConnectHandler new];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	NSString *response = [cHandle doSearch:@"" :userID :[cHandle hashPass:password]];
	listData = (NSMutableArray*)[cHandle parseSearch:response];
	self.view.autoresizesSubviews = YES;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	//initiate the connection handler, get the json response
	cHandle = [ConnectHandler new];
	NSString *response = [cHandle doSearch:@"": userID :[cHandle hashPass:password]];
	listData = (NSMutableArray*)[cHandle parseSearch:response];
	[listTable reloadData];
	[response release];
	[super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
	[listData release];
	[listTable release];
	
	[super viewWillDisappear:animated];
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


#pragma mark -
#pragma mark Search View
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	listData = nil;
	[listTable reloadData];
	query = searchBar.text;
	[searchBar resignFirstResponder];
	[self loadSearch:query];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	searchBar.text = @"";
	[listTable reloadData];
	[searchBar resignFirstResponder];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[listTable reloadData];
}

-(void)loadSearch:(NSString *)q{
	self.editing = YES;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	userID = [defaults objectForKey:kUserID];
	password = [defaults objectForKey:kPassword];
	
	NSString *response = [cHandle doSearch:q :userID :[cHandle hashPass:password]];
	listData = (NSMutableArray*)[cHandle parseSearch:response];
	[listTable reloadData];
	[response release];
}

- (void)dealloc {
	[listData release];
    [cHandle release];
	[super dealloc];
}

#pragma mark -
#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView 
{
	return 1;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section{
	return [listData count];
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	
	static NSString *cellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	row = [indexPath row];
	if (row >= [listData count]){
		cell.textLabel.text = @"";
	}else {
		NSMutableString *cellText = [[NSMutableString alloc] initWithString:[[listData objectAtIndex:row] objectAtIndex:0]];
		[cellText appendString:@", "];
		[cellText appendString:[[listData objectAtIndex:row] objectAtIndex:1]];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.textLabel.text = cellText;
		[cellText release];
	}
	return cell;
}


-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (self.editing && indexPath.row == ([listData count]))
		return UITableViewCellEditingStyleInsert;
	else {
		return UITableViewCellEditingStyleDelete;
	}
}


-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	row = [indexPath row];
	
	NSMutableString *name = [[NSMutableString alloc] initWithString:@"Send connection to "];
	[name appendString:[[listData objectAtIndex:row]objectAtIndex:0]];
	[name appendString:@"?"];
	otherID = [[listData objectAtIndex:row]objectAtIndex:1];
	UIAlertView *cAlert = [[UIAlertView alloc]initWithTitle:nil message:name delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"CONNECT", nil];
	[cAlert show];
	[cAlert release];
	[name release];
}

-(void)alertView:(UIAlertView*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	//buttonIndex 1 is connect, 2 is later
	if (buttonIndex == 1)
	{
		[cHandle makeConnection:userID :otherID :@"" :[cHandle hashPass:password]];
	}
}


-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath {
	[listTable beginUpdates];
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		[cell setUserInteractionEnabled:NO];
		cell.selected = NO;
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	} else {
		
	}
	[listTable endUpdates];
}

-(BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	return YES;
}


@end
