//
//  EncoderController.m
//  QREncoder
//
//  Created by Rafael Vega on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EncoderController.h"
#import "QREncoderAppDelegate.h"
#import "qrencode.h"
#include "writePNG.h"

@implementation EncoderController

-(NSArray*)readCSV:(NSString*)path{
	NSString* file = [NSString stringWithContentsOfFile:path encoding:NSWindowsCP1252StringEncoding error:nil];

	NSArray* rows = [file componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	NSMutableArray* names = [NSMutableArray arrayWithCapacity:0];
	for(NSString* row in rows){
		NSCharacterSet *spaces = [NSCharacterSet whitespaceCharacterSet];
		NSCharacterSet *commas = [NSCharacterSet characterSetWithCharactersInString:@","];
		
		NSArray* nameArray = [row componentsSeparatedByCharactersInSet:commas];
		NSString* lastName = [nameArray objectAtIndex:0];
		NSString* firstName = [nameArray objectAtIndex:1];
		
		NSArray* lastNameArray = [lastName componentsSeparatedByCharactersInSet:spaces];
		lastName = [lastNameArray count]>1 ? [lastNameArray componentsJoinedByString:@""] : lastName;

		NSArray* firstNameArray = [firstName componentsSeparatedByCharactersInSet:spaces];
		firstName = [firstNameArray count]>1 ? [firstNameArray componentsJoinedByString:@""] : firstName;

		NSString* name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
		
		[names addObject:name];
	}
	return names;
}

-(void)createImagesWithNames:(NSArray*)names atDir:(NSString*)dir{
	for(NSString* name in names){
		NSString* path = [NSString stringWithFormat:@"%@/%@.png", dir, name];
		NSString* url = [NSString stringWithFormat:@"http://www.studiocom.com/qr/%@", name];
		
		QRcode *code;
		code = QRcode_encodeString([url cStringUsingEncoding:NSUTF8StringEncoding], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
		path = [NSString stringWithFormat:path, NSUserName()];
		writePNG(code, [path UTF8String]);	
		QRcode_free(code);
		code = nil;
	}
}

- (IBAction)chooseCSVFile:(id)sender{
	//Display an open dialog and populate text field with chosen path
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseFiles:YES];
	[openDlg setCanChooseDirectories:NO];
	[openDlg setAllowsMultipleSelection:NO];

	if([openDlg runModalForDirectory:nil file:nil] == NSOKButton){
		NSString* file = [[openDlg filenames] objectAtIndex:0];
		[fieldCSVFile setTitleWithMnemonic:file];
	}
}

- (IBAction)chooseOutputDir:(id)sender{
	//Display an open dialog and populate text field with chosen path
	NSOpenPanel* openDlg = [NSOpenPanel openPanel];
	[openDlg setCanChooseFiles:NO];
	[openDlg setCanChooseDirectories:YES];
	[openDlg setAllowsMultipleSelection:NO];
	
	if([openDlg runModalForDirectory:nil file:nil] == NSOKButton){
		NSString* file = [[openDlg filenames] objectAtIndex:0];
		[fieldOutputDir setTitleWithMnemonic:file];
	}
}

- (IBAction)encode:(id)sender{
	NSFileManager* fm = [NSFileManager defaultManager];	
	
	// Validate chosen paths
	NSString* file = [fieldCSVFile stringValue];
	NSString* ext = [file pathExtension];
	if(![fm isReadableFileAtPath:file] || ![ext isEqualToString:@"csv"]){
		//Alert
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Please choose a valid CSV file to read the names from."];
		[alert setAlertStyle:NSCriticalAlertStyle];
		QREncoderAppDelegate* appd = (QREncoderAppDelegate*)[[NSApplication sharedApplication] delegate];
		[alert beginSheetModalForWindow:[appd window] 
						  modalDelegate:nil 
						 didEndSelector:nil 
							contextInfo:nil];
		return;
	}
	
	NSString* dir = [fieldOutputDir stringValue];
	BOOL isDirectory;
	if(![fm fileExistsAtPath:dir isDirectory:&isDirectory]){
		if(!isDirectory){
			//Alert
			NSAlert *alert = [[[NSAlert alloc] init] autorelease];
			[alert addButtonWithTitle:@"OK"];
			[alert setMessageText:@"Please choose a directory to save the codes."];
			[alert setAlertStyle:NSCriticalAlertStyle];
			QREncoderAppDelegate* appd = (QREncoderAppDelegate*)[[NSApplication sharedApplication] delegate];
			[alert beginSheetModalForWindow:[appd window] 
							  modalDelegate:nil 
							 didEndSelector:nil 
								contextInfo:nil];
			return;			
		}
	}
	
	[btnGenerateCodes setHidden:YES];
	[spinner setHidden:NO];
	[tick setHidden:YES];
	[spinner startAnimation:nil]; 	
	
	NSArray* names = [self readCSV:file];
	[self createImagesWithNames:names atDir:dir];
	
	[tick setHidden:NO];
	[spinner stopAnimation:nil]; 
	[spinner setHidden:YES];
	[NSTimer scheduledTimerWithTimeInterval:3 
									 target:self 
								   selector:@selector(hideTick:) 
								   userInfo:nil 
									repeats:NO];
}

-(void)hideTick:(id)s{
	[tick setHidden:YES];
	[btnGenerateCodes setHidden:NO];
}

@end