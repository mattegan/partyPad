//
//  TestApplication.m
//  Simple Player
//
//  Created by Matt Egan on 10/1/13.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "TestApplication.h"

@implementation TestApplication


- (void)sendEvent:(UIEvent *)event {
    NSLog(@"EVENT - %@", event);
    if (event.type == UIEventTypeRemoteControl) {
        NSLog(@"REMOTE EVENT");
    }
    else
        [super sendEvent:event];
}

@end
