//
//  NSString+CSVUtils.m
//  Hit40UKMobile
//
//  Created by David Thorpe on 11/12/2005.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSString+CSVUtils.h"

@implementation NSString (CSVUtils)

-(NSArray* )arrayByImportingCSV_line:(NSString*)theLine removeWhitespace:(BOOL)isRemoveWhitespace {
  NSMutableArray* theArray = [NSMutableArray array];
  NSArray* theFields = [theLine componentsSeparatedByString:@","];
  NSCharacterSet* quotedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\""];
  BOOL inField = NO;
  NSMutableString* theConcatenatedField = [NSMutableString string];
  for(unsigned int i = 0; i < [theFields count]; i++) {
    NSString* theField = [theFields objectAtIndex:i];
    switch(inField) {
      case NO:
        if([theField hasPrefix:@"\""] == YES && [theField hasSuffix:@"\""] == NO) { 
          inField = YES;
          [theConcatenatedField appendString:theField];
          [theConcatenatedField appendString:@","];
        } else {
          if(isRemoveWhitespace) {
            [theArray addObject:[theField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
          } else {
            [theArray addObject:theField];            
          }          
        }
        break;
      case YES:
        [theConcatenatedField appendString:theField];
        if([theField hasSuffix:@"\""] == YES) {
          NSString* theField = [theConcatenatedField stringByTrimmingCharactersInSet:quotedCharacterSet];
          if(isRemoveWhitespace) {
            [theArray addObject:[theField stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
          } else {
            [theArray addObject:theField];            
          }          
          [theConcatenatedField setString:@""];
          inField = NO;
        } else {
          [theConcatenatedField appendString:@","];   
        }
        break;
    }
  }
  return theArray;
}

-(NSArray* )arrayByImportingCSV {
  NSMutableArray* theArray = [NSMutableArray array];
  // Character delimiter set
  NSCharacterSet* lineCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
  // Temporary line holder
  NSString* theLine;
  // Scanner for separating out lines
  NSScanner* theScanner = [NSScanner scannerWithString:self];
  // scan until done
  while([theScanner isAtEnd]==NO) {
		[theScanner scanUpToCharactersFromSet:lineCharacterSet intoString:&theLine];  
    [theArray addObject:[self arrayByImportingCSV_line:theLine removeWhitespace:YES]];
  }
  return theArray;
}
@end
