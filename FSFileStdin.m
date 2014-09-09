
#import "FSFileStdin.h"


@implementation FSFileStdin {  NSString* buffer; } static FSFileStdin* FSstdin;	// singleton instance

// factory method that returns a singleton instance
+ (id) getStdin {	static dispatch_once_t onceT; dispatch_once(&onceT, ^{ FSstdin = FSFileStdin.new; }); 	return FSstdin; }
- (id) init {  return self = [self initWithFileHandle:NSFileHandle.fileHandleWithStandardInput atLocation:@""]
									? buffer = @"", self : nil;
}
- (NSString*)readlnWithSeparator:(NSString*)separator {

// Adapted from Apple's documentation, "Piping Data Between Tasks", 2006-04-04

/*	We have four cases to consider:
- We've read exactly up to the end of the separator (i.e. the separator is "\n" and "\n" is the last available character) In this case, set buffer to the empty string and return everything up to the beginning of the separator
- There's nothing left at all: the file is closed if there's anything left in the buffer, return it, otherwise return nil
- We've read all the available data, but haven't seen the separator	 Add the data to the buffer, and repeat
- We've read past the separator Put the excess data into the buffer, and return the portion that came before the separator
*/
	NSData *inData = nil;	NSString* returnString = nil;
	while (!returnString && (inData = fileHandle.availableData) && inData.length) {

		NSString* temp 			= [NSString.alloc initWithData:inData encoding:NSUTF8StringEncoding];
		NSString* dataString 	= buffer.length ? [buffer stringByAppendingString:temp] : temp;
		NSRange separatorRange 	= [dataString rangeOfString:separator];
		int endOfSeparator 		= separatorRange.location+separatorRange.length;
		int stringLength		 	= dataString.length;

		buffer 	= 	endOfSeparator==stringLength 			? @""
					:	endOfSeparator<=stringLength 			? [dataString substringFromIndex:endOfSeparator]
					:	separatorRange.location==NSNotFound ? [buffer stringByAppendingString:dataString] : 	buffer;
		returnString
					= 	endOfSeparator==stringLength
					|| endOfSeparator<=stringLength 			? [dataString substringToIndex:separatorRange.location]
					:	separatorRange.location==NSNotFound ? nil : 	buffer;
	}
	// if there's nothing to read and nothing in the buffer, return nil
	return  !returnString && buffer.length 			 ? buffer
			: ![returnString length] && !buffer.length ? nil : returnString;
}

@end
