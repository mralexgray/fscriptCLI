
#import "Functions.h"

static FSInterpreter* _globalInterpreter;   // function that creates/returns a singleton global interpreter
FSInterpreter* getGlobalInterpreter() { return _globalInterpreter = _globalInterpreter ?: FSInterpreter.new; }

// this dictionary caches the modification dates of loaded .fs files, so that we won't reload
NSMutableDictionary* loadedFiles;

FSInterpreterResult* loadFile(NSString* fileLocation, BOOL asLibrary, BOOL verboseExceptions) {
	int errorLine = 0;  // line on which an error occurs
	NSError* err = nil;		 // load the contents of the file into a string
	NSString* scriptContents = [NSString stringWithContentsOfFile:fileLocation
																		  encoding:NSUTF8StringEncoding error:&err];
	if (err && [err code]!=0) return
		[[NSException exceptionWithName:@"FileError" reason:
		  [NSString stringWithFormat:@"Couldn't read file '%@': %@",
			fileLocation,[err.userInfo[NSUnderlyingErrorKey] localizedDescription]] userInfo:nil]
		 raise], nil;

	// check to see if this file needs to be reloaded, return early if not
	if (!loadedFiles) loadedFiles = NSMutableDictionary.new;
	NSDate* modTime = loadedFiles[fileLocation];
	if (modTime && ([[NSFileManager.defaultManager  attributesOfItemAtPath:fileLocation error:&err]
							[NSFileModificationDate] compare:(id)modTime]) !=1) return nil;

	// if this file was launched from the command line, check for a shebang on the first line and chop it off if it was present
	if (!asLibrary && [scriptContents hasPrefix:@"#!"]) {
		NSRange range 						= [scriptContents rangeOfString:@"\n"];
		NSString* newScriptContents 	= [scriptContents substringFromIndex:range.location+1];
		scriptContents 					= newScriptContents;
		errorLine++;  // remember this extra line in case there was an error
	}
	FSInterpreterResult* result;			// run the script contents
	result = [getGlobalInterpreter() execute:scriptContents];

	if (![result isOK]) {			// if there was an error, figure out which line/char it was on
		NSRange errorRange = [result errorRange];
		int stringLen = [scriptContents length];
		int errorLocation = errorRange.location;
		int currentLoc = -1; 											   // will be incremented to 0 in first run of loop below
		int errorChar = 0;
		while (currentLoc<errorLocation) { errorRange =				// count up the lines until we find the location of the error
			[scriptContents rangeOfString:@"\n" options:0 range:NSMakeRange(currentLoc+1,stringLen-currentLoc-1)];
			errorChar = errorLocation - currentLoc;
			currentLoc = errorRange.location;
			errorLine++;
		}
		// throw an error - if not caught by exception handlers in a script, will be caught in main()
		[[NSException exceptionWithName:@"FSInterpreterException" reason:
			[NSString stringWithFormat:@"Error in file %@, line %d, character %d: %@",
		  	fileLocation, errorLine, errorChar, result.errorMessage.description] userInfo:nil] raise];
	}
	// if everything was fine, return the result
	return result;
}

