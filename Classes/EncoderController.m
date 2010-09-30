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
#import "NSString+CSVUtils.h"

#include "writePNG.h"

@implementation EncoderController

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

-(void)createImagesWithStrings:(NSArray*)strings atDir:(NSString*)dir{
	for(NSArray* row in strings){
		NSString* path = [NSString stringWithFormat:@"%@/%@.png", dir, [row objectAtIndex:0]];
		NSString* string = [row objectAtIndex:1];
		
		QRcode *code;
		code = QRcode_encodeString([string cStringUsingEncoding:NSUTF8StringEncoding], 0, QR_ECLEVEL_L, QR_MODE_8, 1);
		writePNG(code, [path UTF8String]);	
		QRcode_free(code);
		code = nil;
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
	
	NSString* fileContent = [NSString stringWithContentsOfFile:file encoding:NSWindowsCP1252StringEncoding error:nil];
	NSArray* strings = [fileContent arrayByImportingCSV];
	[self createImagesWithStrings:strings atDir:dir];
	
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