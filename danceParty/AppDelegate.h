//
//  AppDelegate.h
//  danceParty
//
//  Created by Matt Egan on 10/19/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "GCDAsyncSocket.h"
#import "DPPartyViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, SPSessionDelegate> {
    
}

@property (strong, nonatomic) UIWindow *window;

@end
