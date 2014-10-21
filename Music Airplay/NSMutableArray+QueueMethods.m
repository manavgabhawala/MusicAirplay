//
//  NSMutableArray+QueueMethods.m
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import "NSMutableArray+QueueMethods.h"

@implementation NSMutableArray (QueueMethods)

- (void)pushObject:(id)object
{
    [self addObject:object];
}

- (id)popObject
{
    if (self.count > 0) {
        id object = self[0];
        [self removeObjectAtIndex:0];
        return object;
    }
    
    return nil;
}

- (id)topObject
{
    if (self.count > 0) {
        return self[0];
    }
    
    return nil;
}

@end