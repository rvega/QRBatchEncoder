//
//  EncoderController.h
//  QREncoder
//
//  Created by Rafael Vega on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EncoderController : NSObject {
	IBOutlet NSButton *btnCSVFile;
	IBOutlet NSTextField *fieldCSVFile;
	IBOutlet NSButton *btnOutputDir;
	IBOutlet NSTextField *fieldOutputDir;
	IBOutlet NSButton *btnGenerateCodes;
	IBOutlet NSProgressIndicator *spinner;	
	IBOutlet NSImageView *tick;	
}

- (IBAction)encode:(id)sender;
- (IBAction)chooseCSVFile:(id)sender;
- (IBAction)chooseOutputDir:(id)sender;

@end