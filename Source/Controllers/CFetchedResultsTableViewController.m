//
//  CFetchedResultsTableViewController.m
//  TouchCode
//
//  Created by Jonathan Wight on 6/10/09.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import "CFetchedResultsTableViewController.h"

const double kPlaceholderHideShowAnimationDuration = 0.4;


#pragma mark -

@implementation CFetchedResultsTableViewController

@synthesize managedObjectContext;
@synthesize fetchRequest;
@synthesize fetchedResultsController;
@synthesize placeholderView;
@synthesize tableViewCellClass;

- (void)dealloc
	{
	[fetchRequest release];
	fetchRequest = NULL;
	fetchedResultsController.delegate = NULL;
	[fetchedResultsController release];
	fetchedResultsController = NULL;
	[placeholderView release];
	placeholderView = NULL;
	//
	[super dealloc];
	}

#pragma mark -

- (void)setFetchRequest:(NSFetchRequest *)inFetchRequest
	{
	if (fetchRequest != inFetchRequest)
		{
		if (fetchRequest != NULL)
			{
			[fetchRequest release];
			fetchRequest = NULL;
			
			self.fetchedResultsController = NULL;
			}
		//
		if (inFetchRequest != NULL)
			{
			fetchRequest = [inFetchRequest retain];
			[self.fetchedResultsController performFetch:NULL];
			}
			
		[self updatePlaceholder:YES];

		[self.tableView reloadData];
		}
	}

- (NSFetchedResultsController *)fetchedResultsController
	{
	if (fetchedResultsController == NULL)
		{
		if (self.fetchRequest)
			{
			fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:NULL cacheName:NULL];
			fetchedResultsController.delegate = self;
			}
		}
	return(fetchedResultsController);
	}

- (UIView *)placeholderView
	{
	if (placeholderView == NULL)
		{
		UILabel *theLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 44 * 3, self.view.bounds.size.width, 44)] autorelease];
		theLabel.textAlignment = UITextAlignmentCenter;
		theLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize] + 3];
		theLabel.textColor = [UIColor grayColor];
		theLabel.opaque = NO;
		theLabel.backgroundColor = [UIColor clearColor];
		theLabel.text = @"No Rows";
		self.placeholderView = theLabel;
		}
	return(placeholderView);
	}

- (void)setPlaceholderView:(UIView *)inPlaceholderView
	{
	if (placeholderView != inPlaceholderView)
		{
		[placeholderView release];
		placeholderView = [inPlaceholderView retain];
		}
	}

#pragma mark -

- (void)viewDidUnload
	{
	[super viewDidUnload];
	//
	fetchedResultsController.delegate = NULL;
	[fetchedResultsController release];
	fetchedResultsController = NULL;
	[placeholderView release];
	placeholderView = NULL;
	}

- (void)viewWillAppear:(BOOL)animated
	{
	[super viewWillAppear:animated];

	self.fetchedResultsController.delegate = self;

	NSError *theError = NULL;
	if (self.fetchedResultsController && [self.fetchedResultsController performFetch:&theError] == NO)
		{
		NSLog(@"Error: %@", theError);
		}
		
	[self.tableView reloadData];

	[self updatePlaceholder:NO];

	if ([self.fetchedResultsController.fetchedObjects count] == 0)
		{
		[self editButtonItem].enabled = NO;
		}
	else
		{
		[self editButtonItem].enabled = YES;
		}
	}

#pragma mark -

- (IBAction)add:(id)inSender
	{
	}

#pragma mark -

- (void)updatePlaceholder:(BOOL)inAnimated
	{
	if (inAnimated)
		{
		if ([self.fetchedResultsController.fetchedObjects count] == 0)
			{
			if (self.placeholderView.superview != self.tableView)
				{
				self.placeholderView.alpha = 0.0f;
				[self.tableView addSubview:self.placeholderView];
				
				[UIView beginAnimations:@"SHOW_PLACEHOLDER" context:NULL];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDuration:kPlaceholderHideShowAnimationDuration];
				self.placeholderView.alpha = 1.0f;
				[UIView commitAnimations];
				}
			}
		else
			{
			if (self.placeholderView.superview == self.tableView)
				{
				[UIView beginAnimations:@"HIDE_PLACEHOLDER" context:NULL];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDuration:kPlaceholderHideShowAnimationDuration];
				self.placeholderView.alpha = 0.0f;
				[UIView commitAnimations];
				}
			}
		}
	else
		{
		if ([self.fetchedResultsController.fetchedObjects count] == 0)
			{
			if (self.placeholderView.superview != self.tableView)
				{
				[self.tableView addSubview:self.placeholderView];
				self.placeholderView.alpha = 1.0f;
				}
			}
		else
			{
			if (self.placeholderView.superview == self.tableView)
				{
				[self.placeholderView removeFromSuperview];
				}
			}
		}
	}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
	{
	NSInteger theNumberOfSections = [self.fetchedResultsController.sections count];
	if (theNumberOfSections == 0)
		{
		theNumberOfSections = 1;
		}
	return(theNumberOfSections);
	}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
	{
	NSArray *theSections = self.fetchedResultsController.sections;
	NSInteger theNumberOfRows = 0;
	if ([theSections count] > 0)
		{
		id <NSFetchedResultsSectionInfo> theSection = [theSections objectAtIndex:section];
		theNumberOfRows = theSection.numberOfObjects;
		}
	return(theNumberOfRows);
	}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
	{
	UITableViewCell *theCell = [self.tableView dequeueReusableCellWithIdentifier:@"CELL"];
	if (theCell == NULL)
		{
		Class theClass = self.tableViewCellClass ?: [UITableViewCell class];
		theCell = [[[theClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CELL"] autorelease];
		}
	
	NSManagedObject *theObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if ([theCell conformsToProtocol:@protocol(CManagedObjectTableViewCellProtocol)]
		|| [theCell respondsToSelector:@selector(setManagedObject:)])
		{
		[(id <CManagedObjectTableViewCellProtocol>)theCell setManagedObject:theObject];
		}
	else
		{
		theCell.textLabel.text = [theObject description];
		}
	
	return(theCell);
	}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
	{
	if (editingStyle == UITableViewCellEditingStyleDelete)
		{
		NSManagedObject *theObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
		[self.managedObjectContext deleteObject:theObject];
	//	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		}   
	else if (editingStyle == UITableViewCellEditingStyleInsert)
		{
		}
		
	NSError *theError = NULL;
	if ([self.managedObjectContext save:&theError] == NO)
		{
		NSLog(@"Error: %@", theError);
		}


	if ([self.fetchedResultsController.fetchedObjects count] == 0)
		{
		[self setEditing:NO animated:YES];
		}
		
	[self updatePlaceholder:YES];
	}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath;
	{
	return(UITableViewCellEditingStyleNone);
	}

#pragma mark -

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
	{
	[self.tableView beginUpdates];
	}
  
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
	{
	switch (type)
		{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
		}
	}
 
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
	{
	switch (type)
		{
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
			withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		case NSFetchedResultsChangeUpdate:
	//		[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
		case NSFetchedResultsChangeMove:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
		}
		
	if ([self.fetchedResultsController.fetchedObjects count] == 0)
		{
		[self editButtonItem].enabled = NO;
		}
	else
		{
		[self editButtonItem].enabled = YES;
		}

	[self updatePlaceholder:YES];
	}
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
	{
	[self.tableView endUpdates];
	}

#pragma mark -

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
	{
	if ([animationID isEqualToString:@"HIDE_PLACEHOLDER"])
		{
		[self.placeholderView removeFromSuperview];
		}
	}

@end
