//
//  QREncoderAppDelegate.h
//  QREncoder
//
//  Created by Rafael Vega on 9/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QREncoderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;	
}

@property (assign) IBOutlet NSWindow *window;

@end