//
//  BlockForeach.m
//  fscript
//
//  Created by Andrew Weinrich on 1/12/07.
//  Copyright 2007 Andrew Weinrich. All rights reserved.
//

#import "BlockForeach.h"


@implementation FSBlock(BlockForeach)

- (void) foreach:(FSBlock*)iterator { id anObject;
	while (anObject == self.value) [iterator value:anObject];
}
@end
