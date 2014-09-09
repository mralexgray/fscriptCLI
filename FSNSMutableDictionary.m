//
//  FSNSMutableDictionary.m
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//

#import "FSNSMutableDictionary.h"
#import <FScript/FScript.h>


@implementation NSMutableDictionary (Pairs)


+ (NSMutableDictionary*) dictionaryWithPairs:(NSArray*)pairs {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    unsigned int count = [pairs count];
    for (int i=0; i < count; i++) {
        NSArray* pair = pairs[i];
        dict[pair[0]] = pair[1];
    }
    
    return [dict autorelease];
}

+ (NSMutableDictionary*) dictionaryWithFlatPairs:(NSArray*)flatPairs {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    unsigned int count = [flatPairs count];
    // throw an exception if there aren't an even number of items
    if (count % 2 != 0) {
        FSExecError(@"Odd number of items in flat array passed to +dictionaryWithFlatPairs");
    }
        
    for (int i=0; i < count; i+=2) {
        dict[flatPairs[i]] = flatPairs[i+1];
    }
    
    return [dict autorelease];
}


@end
