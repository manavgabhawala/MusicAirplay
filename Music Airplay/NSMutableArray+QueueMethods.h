//
//  NSMutableArray+QueueMethods.h
//  Music Airplay
//
//  Created by Manav Gabhawala on 1/6/14.
//  Copyright (c) 2014 Manav Gabhawala. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueMethods)

- (void)pushObject:(id)object;
- (id)popObject;
- (id)topObject;

@end