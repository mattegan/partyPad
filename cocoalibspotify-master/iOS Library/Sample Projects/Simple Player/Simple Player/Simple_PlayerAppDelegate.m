//
//  Simple_PlayerAppDelegate.m
//  Simple Player
//
//  Created by Daniel Kennett on 10/3/11.
/*
 Copyright (c) 2011, Spotify AB
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "Simple_PlayerAppDelegate.h"

const uint8_t g_appkey[] = {
	0x01, 0xD2, 0x31, 0xD4, 0x70, 0x3F, 0x96, 0x23, 0x2E, 0xFA, 0x3B, 0x11, 0x00, 0x24, 0x90, 0x1D,
	0xB3, 0x23, 0x58, 0x90, 0xAE, 0xF8, 0x09, 0x18, 0x3B, 0xF3, 0xBF, 0xAD, 0xD5, 0x27, 0xF1, 0x69,
	0x84, 0xA2, 0x8C, 0x33, 0x4E, 0x16, 0x72, 0x71, 0x37, 0x26, 0x6C, 0x54, 0x4D, 0x45, 0x29, 0xBE,
	0xC3, 0xBB, 0x1B, 0x3D, 0xD6, 0x6A, 0x43, 0x69, 0x45, 0x6D, 0x7D, 0xE1, 0x97, 0x0A, 0x35, 0x00,
	0x1D, 0xA1, 0x5F, 0x85, 0x9B, 0x0D, 0xC4, 0x80, 0xEA, 0x46, 0x08, 0x1E, 0x50, 0x34, 0xD6, 0x0E,
	0xE5, 0xB5, 0x33, 0x37, 0xAD, 0xD1, 0x3B, 0xBF, 0xB4, 0x5B, 0x2F, 0x72, 0xED, 0xD5, 0xB7, 0xA5,
	0xBE, 0xBC, 0xAF, 0x4A, 0x30, 0x97, 0x2F, 0x60, 0xE6, 0x03, 0x75, 0x85, 0x08, 0x0B, 0x97, 0x38,
	0xE3, 0x72, 0xC6, 0xCF, 0xDF, 0x67, 0xFF, 0x9F, 0x86, 0x9F, 0xB0, 0x28, 0x8B, 0x56, 0xB1, 0x4E,
	0x0E, 0x41, 0xFB, 0x93, 0xA0, 0x85, 0x6F, 0xE3, 0x88, 0xDA, 0x3E, 0xAA, 0xBE, 0x62, 0x98, 0x5E,
	0x8D, 0xF7, 0xC5, 0xB9, 0xAF, 0x34, 0x02, 0x32, 0x6D, 0xD7, 0x95, 0x1B, 0x9A, 0xB0, 0x89, 0xB2,
	0xAF, 0x40, 0x3B, 0x0F, 0x8E, 0xBF, 0x79, 0xDD, 0xD7, 0x3F, 0xFC, 0x6D, 0xE3, 0x9F, 0x22, 0x62,
	0x86, 0x0A, 0xBD, 0xC0, 0xB8, 0xCF, 0xE4, 0xE9, 0x66, 0x2E, 0x97, 0xB9, 0x8B, 0xEE, 0x53, 0xCA,
	0xFB, 0x9A, 0xAE, 0x4A, 0x0E, 0xC9, 0xE0, 0x72, 0xA4, 0x5E, 0xC2, 0x88, 0xC9, 0xF1, 0x3E, 0x87,
	0x07, 0xDD, 0x6A, 0xAD, 0x7E, 0x9A, 0x3A, 0x8A, 0x20, 0x04, 0x06, 0x40, 0xCC, 0xDB, 0x7E, 0x71,
	0x38, 0x23, 0x4A, 0x67, 0x7C, 0xE2, 0x2E, 0x2D, 0x8F, 0xD1, 0xE1, 0xD5, 0xBC, 0x15, 0x8A, 0x73,
	0x64, 0x9A, 0xC5, 0xC5, 0x2F, 0x86, 0x95, 0xD9, 0x1B, 0x1A, 0xCE, 0x7F, 0xC9, 0x99, 0x4A, 0xBF,
	0x34, 0x36, 0x91, 0x68, 0xEF, 0x19, 0x02, 0xE1, 0x3A, 0x9D, 0xBB, 0x96, 0x44, 0x1E, 0x8F, 0xDD,
	0x78, 0x3B, 0xAD, 0x2B, 0xC7, 0x2A, 0x36, 0xF0, 0x49, 0x36, 0xD1, 0x60, 0xB1, 0xC8, 0x5D, 0x65,
	0x48, 0xC7, 0xE3, 0x44, 0xCB, 0x3E, 0x29, 0x71, 0x4C, 0xAB, 0xE0, 0xCC, 0xE9, 0xB9, 0x7B, 0xF6,
	0x72, 0x17, 0xEF, 0x2F, 0xA9, 0xB3, 0x62, 0xD5, 0xC6, 0x83, 0x89, 0x9B, 0xC9, 0x5C, 0x2D, 0xAF,
	0x6C,
};

const size_t g_appkey_size = sizeof(g_appkey);

@implementation Simple_PlayerAppDelegate

@synthesize window = _window;
@synthesize mainViewController = _mainViewController;
@synthesize trackURIField = _trackURIField;
@synthesize trackTitle = _trackTitle;
@synthesize trackArtist = _trackArtist;
@synthesize coverView = _coverView;
@synthesize positionSlider = _positionSlider;
@synthesize playbackManager = _playbackManager;
@synthesize currentTrack = _currentTrack;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Override point for customization after application launch.
	[self.window makeKeyAndVisible];

	NSError *error = nil;
	[SPSession initializeSharedSessionWithApplicationKey:[NSData dataWithBytes:&g_appkey length:g_appkey_size]
											   userAgent:@"com.spotify.SimplePlayer-iOS"
										   loadingPolicy:SPAsyncLoadingManual
												   error:&error];
	if (error != nil) {
		NSLog(@"CocoaLibSpotify init failed: %@", error);
		abort();
	}

	self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
	[[SPSession sharedSession] setDelegate:self];

	[self addObserver:self forKeyPath:@"currentTrack.name" options:0 context:nil];
	[self addObserver:self forKeyPath:@"currentTrack.artists" options:0 context:nil];
	[self addObserver:self forKeyPath:@"currentTrack.duration" options:0 context:nil];
	[self addObserver:self forKeyPath:@"currentTrack.album.cover.image" options:0 context:nil];
	[self addObserver:self forKeyPath:@"playbackManager.trackPosition" options:0 context:nil];
	
	[self performSelector:@selector(showLogin) withObject:nil afterDelay:0.0];
	
    return YES;
}

-(void)showLogin {

	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	controller.allowsCancel = NO;
	
	[self.mainViewController presentModalViewController:controller
											   animated:NO];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentTrack.name"]) {
        self.trackTitle.text = self.currentTrack.name;
	} else if ([keyPath isEqualToString:@"currentTrack.artists"]) {
		self.trackArtist.text = [[self.currentTrack.artists valueForKey:@"name"] componentsJoinedByString:@","];
	} else if ([keyPath isEqualToString:@"currentTrack.album.cover.image"]) {
		self.coverView.image = self.currentTrack.album.cover.image;
	} else if ([keyPath isEqualToString:@"currentTrack.duration"]) {
		self.positionSlider.maximumValue = self.currentTrack.duration;
	} else if ([keyPath isEqualToString:@"playbackManager.trackPosition"]) {
		// Only update the slider if the user isn't currently dragging it.
		if (!self.positionSlider.highlighted)
			self.positionSlider.value = self.playbackManager.trackPosition;

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
	
	[[SPSession sharedSession] logout:^{}];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    NSLog(@"GOt event thing");
    
}

#pragma mark -

- (IBAction)playTrack:(id)sender {
	
	// Invoked by clicking the "Play" button in the UI.
	
	if (self.trackURIField.text.length > 0) {
		
		NSURL *trackURL = [NSURL URLWithString:self.trackURIField.text];
		[[SPSession sharedSession] trackForURL:trackURL callback:^(SPTrack *track) {
			
			if (track != nil) {
				
				[SPAsyncLoading waitUntilLoaded:track timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *tracks, NSArray *notLoadedTracks) {
					[self.playbackManager playTrack:track callback:^(NSError *error) {
						
						if (error) {
							UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
																			message:[error localizedDescription]
																		   delegate:nil
																  cancelButtonTitle:@"OK"
																  otherButtonTitles:nil];
							[alert show];
						} else {
							self.currentTrack = track;

						}
						
					}];
				}];
			}
		}];
		
		return;
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Track"
													message:@"Please enter a track URL"
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (IBAction)testThing:(id)sender {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo: @{MPMediaItemPropertyTitle: @"FUCK"}];
    NSLog(@"%@", self.isFirstResponder ? @"YUP" : @"NOPE");
}

- (IBAction)setTrackPosition:(id)sender {
	[self.playbackManager seekToTrackPosition:self.positionSlider.value];
}

- (IBAction)setVolume:(id)sender {
	self.playbackManager.volume = [(UISlider *)sender value];
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(UIViewController *)viewControllerToPresentLoginViewForSession:(SPSession *)aSession {
	return self.mainViewController;
}

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession; {
	// Invoked by SPSession after a successful login.
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error; {
	// Invoked by SPSession after a failed login.
}

-(void)sessionDidLogOut:(SPSession *)aSession {
	
	SPLoginViewController *controller = [SPLoginViewController loginControllerForSession:[SPSession sharedSession]];
	
	if (self.mainViewController.presentedViewController != nil) return;
	
	controller.allowsCancel = NO;
	
	[self.mainViewController presentModalViewController:controller
											   animated:YES];
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {}
-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {}
-(void)sessionDidChangeMetadata:(SPSession *)aSession; {}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	return;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
													message:aMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
}


- (void)dealloc {
	
	[self removeObserver:self forKeyPath:@"currentTrack.name"];
	[self removeObserver:self forKeyPath:@"currentTrack.artists"];
	[self removeObserver:self forKeyPath:@"currentTrack.album.cover.image"];
	[self removeObserver:self forKeyPath:@"playbackManager.trackPosition"];
	
}

@end
