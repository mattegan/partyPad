//
//  DPPartyViewController.m
//  danceParty
//
//  Created by Matt Egan on 10/19/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import "DPPartyViewController.h"
#import "appkey.c"

@interface DPPartyViewController ()

@end

@implementation DPPartyViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    trackQueue = [[NSMutableArray alloc] init];
    nowPlaying = nil;
    timeSum = 0;
    maxTempo = 0;
    
    points = [[NSMutableArray alloc] init];
    
    NSData *applicationKey = [NSData dataWithBytes: &g_appkey length: g_appkey_size];
    NSError *SPSessionInitError = nil;
    session = [[SPSession alloc] initWithApplicationKey: applicationKey
                                              userAgent: @"signal24.spotifyTesting"
                                          loadingPolicy: SPAsyncLoadingManual
                                                  error: &SPSessionInitError];
    session.delegate = self;
    
    //handle the error initializing the session, if there was one
    if(SPSessionInitError != nil) {
        NSLog(@"Error Initializng SPSession : %@", SPSessionInitError.description);
    } else{
        [session attemptLoginWithUserName: @"mattegan" password: @"Rubberduckie1"];
    }
    
    //setup a socket to connect to the node relay server, this class deals with all of the results
    //  of it's reads
    dispatch_queue_t socketDelegateQueue = dispatch_queue_create("delegateQueue", NULL);
    socket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: socketDelegateQueue];
    socket.delegate = self;
    
    //attempt to connect to the relay server
    NSError *connectionError = nil;
    [socket connectToHost: @"74.207.229.56" onPort: 1338 error: &connectionError];
    if(connectionError != nil) {
        NSLog(@"Error Connecting To Relay Server : %@", connectionError.description);
    }
    
    //start listening for data (indefinately) from the relay server
    [socket readDataToData: [@"\n" dataUsingEncoding: NSUTF8StringEncoding] withTimeout: -1 tag: 0];
    
    graph = [[CPTXYGraph alloc] initWithFrame: graphHostingView.bounds];
    graphHostingView.hostedGraph = graph;
    graph.fill = [CPTFill fillWithColor: [CPTColor colorWithComponentRed: 0 green: 0 blue: 0 alpha: 1.0]];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation: CPTDecimalFromFloat(0) length: CPTDecimalFromFloat(1)]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation: CPTDecimalFromFloat(0) length: CPTDecimalFromFloat(0)]];
    
    tempoPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    tempoPlot.identifier = @"tempoPlot";
    tempoPlot.dataSource = self;
    
    CPTMutableLineStyle *tempoLineStyle = [CPTMutableLineStyle lineStyle];
    tempoLineStyle.lineWidth = 3;
    tempoLineStyle.lineColor = [CPTColor colorWithComponentRed: 63/255.0 green: 213/255.0 blue: 250/255.0 alpha: 0.9];
    
    tempoPlot.dataLineStyle = tempoLineStyle;
    
    energyPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    energyPlot.identifier = @"energyPlot";
    energyPlot.dataSource = self;
    
    CPTMutableLineStyle *energyLineStyle = [CPTMutableLineStyle lineStyle];
    energyLineStyle.lineWidth = 3;
    energyLineStyle.lineColor = [CPTColor colorWithComponentRed: 250/255.0 green: 107/255.0 blue: 63/255.0 alpha: 0.9];
    
    energyPlot.dataLineStyle = energyLineStyle;
    
    danceabilityPlot = [[CPTScatterPlot alloc] initWithFrame:CGRectZero];
    danceabilityPlot.identifier = @"dancebilityPlot";
    danceabilityPlot.dataSource = self;
    
    CPTMutableLineStyle *danceabilityLineStyle = [CPTMutableLineStyle lineStyle];
    danceabilityLineStyle.lineWidth = 3;
    danceabilityLineStyle.lineColor = [CPTColor colorWithComponentRed: 107/255.0 green: 250/255.0 blue: 63/255.0 alpha: 0.9];
    
    danceabilityPlot.dataLineStyle = danceabilityLineStyle;
    
    [graph addPlot: tempoPlot toPlotSpace: graph.defaultPlotSpace];
    [graph addPlot: energyPlot toPlotSpace: graph.defaultPlotSpace];
    [graph addPlot: danceabilityPlot toPlotSpace: graph.defaultPlotSpace];
    
    [continuousImageScrollView setText: @"Text 678-707-8466 to add songs to the queue!"];
    [continuousImageScrollView startScrollingWithScrollSpeed: 120];
    
    averageEnergyLabel.hidden = YES;
    averageBPMLabel.hidden = YES;
    averageDanceabilityLabel.hidden = YES;
    nowPlayingLabel.hidden = YES;
    upNextLabel.hidden = YES;
    averageEnergyTextLabel.hidden = YES;
    averageBPMTextLabel.hidden = YES;
    averageDanceabilityTextLabel.hidden = YES;
    
    averageDanceabilityLabel.textColor = [UIColor colorWithRed: 107/255.0 green: 250/255.0 blue: 63/255.0 alpha: 0.9];
    averageBPMLabel.textColor = [UIColor colorWithRed: 63/255.0 green: 213/255.0 blue: 250/255.0 alpha: 0.9];
    averageEnergyLabel.textColor = [UIColor colorWithRed: 250/255.0 green: 107/255.0 blue: 63/255.0 alpha: 0.9];
    
    playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession: session];
    
    NSLog(@"Setup");
}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return points.count;
}
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    NSNumber *x = points[idx][@"time"];
    NSNumber *y;
    if([plot.identifier isEqual: @"tempoPlot"]) {
        y = [NSNumber numberWithFloat: [points[idx][@"tempo"] floatValue] / maxTempo];
        NSLog([points[idx][@"tempo"] stringValue]);
        NSLog(@"%@", y);
    } else if([plot.identifier isEqual: @"energyPlot"]) {
        y = points[idx][@"energy"];
    } else if([plot.identifier isEqual: @"dancebilityPlot"]) {
        y = points[idx][@"danceability"];
    }
    if(fieldEnum == CPTScatterPlotFieldX) {
        return x;
    } else{
        return y;
    }
}

- (void)updateGraphView{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    [plotSpace setYRange: [CPTPlotRange plotRangeWithLocation: CPTDecimalFromFloat(0) length: CPTDecimalFromFloat(1.25)]];
    [plotSpace setXRange: [CPTPlotRange plotRangeWithLocation: CPTDecimalFromFloat(0) length: CPTDecimalFromFloat([[points lastObject][@"time"] floatValue])]];
    
    [tempoPlot reloadData];
    [energyPlot reloadData];
    [danceabilityPlot reloadData];
}

- (void)sessionDidLoginSuccessfully:(SPSession *)aSession {
    NSLog(@"Logged in!");
}

- (void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
    NSLog(@"LOGIN ERROR : %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
}

- (void)queueTrackWithInfo:(NSDictionary *)info {
    [session trackForURL: [NSURL URLWithString: info[@"url"]] callback:^(SPTrack *track) {
        if(track == nil) {
            NSLog(@"track nil");
        }
        [SPAsyncLoading waitUntilLoaded: track timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            [SPAsyncLoading waitUntilLoaded: track.album timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                [SPAsyncLoading waitUntilLoaded: track.album.artist timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                    [[DPAlbumArtView alloc] initWithTrackURI: info[@"url"]
                                                   inSession: session
                                                   withFrame: CGRectMake(trackQueue.count * 237, 0, 237, 237)
                                                onCompletion:^(DPAlbumArtView *albumView, NSError *error) {
                                                    [trackQueue addObject: albumView];
                                                    [queueView addSubview: albumView];
                                                    queueView.contentSize = CGSizeMake(237 * trackQueue.count, 237);
                                                    
                                                    NSDictionary *summary = info[@"summary"];
                                                    
                                                    [points addObject: @{@"time": [NSNumber numberWithFloat: timeSum], @"tempo": summary[@"tempo"], @"energy" : summary[@"energy"], @"danceability" : summary[@"danceability"]}];
                                                    timeSum += [summary[@"duration"] floatValue];
                                                    
                                                    if(maxTempo < [summary[@"tempo"] floatValue]) {
                                                        NSLog(@"setting max tempo to %f", [summary[@"tempo"] floatValue]);
                                                        maxTempo = [summary[@"tempo"] floatValue];
                                                    }
                                                    
                                                    [self updateGraphView];
                                                    
                                                    averageDancability = ((averageDancability * (points.count - 1)) + [summary[@"danceability"] floatValue]) / points.count;
                                                    averageTempo = ((averageTempo * (points.count -1)) + [summary[@"tempo"] floatValue]) / points.count;
                                                    averageEnergy = ((averageEnergy * (points.count - 1)) + [summary[@"energy"] floatValue]) / points.count;
                                                    
                                                    averageDanceabilityLabel.hidden = NO;
                                                    averageBPMLabel.hidden = NO;
                                                    averageEnergyLabel.hidden = NO;
                                                    
                                                    
                                                    averageDanceabilityTextLabel.hidden = NO;
                                                    averageBPMTextLabel.hidden = NO;
                                                    averageEnergyTextLabel.hidden = NO;
                                                    
                                                    averageDanceabilityLabel.text = [NSString stringWithFormat: @"%.0f%%", averageDancability * 100];
                                                    averageBPMLabel.text = [NSString stringWithFormat: @"%.0f", averageTempo];
                                                    averageEnergyLabel.text = [NSString stringWithFormat: @"%.0f%%", averageEnergy * 100];
                                                    
                                                    if(trackQueue.count == 1) {
                                                        nowPlayingLabel.hidden = NO;
                                                    } else if(trackQueue.count > 1) {
                                                        nowPlayingLabel.hidden = NO;
                                                        upNextLabel.hidden = NO;
                                                    }
                                                    
                                                    [self playFirstTrackIfNotPlaying];
                                                    
                                                }];
                    
                    

                }];
            }];
        }];
    }];
}

- (void)playFirstTrackIfNotPlaying {
    if(trackQueue.count >= 1) {
        if(nowPlaying != trackQueue[0]) {
            SPTrack *track = ((DPAlbumArtView *)trackQueue[0]).track;
            nowPlaying = trackQueue[0];
            [playbackManager playTrack: track callback:^(NSError *error) {
                [continuousImageScrollView setText: [NSString stringWithFormat: @"%@ // %@", track.name, track.album.artist.name]];
                [continuousImageScrollView startScrollingWithScrollSpeed: 120];
            }];
        }
    }
}

- (void)removeTrackFromFrontOfQueue {

        [UIView animateWithDuration: 0.2f  animations:^{
            for(DPAlbumArtView *albumArtView in trackQueue) {
                albumArtView.frame = CGRectOffset(albumArtView.frame, -albumArtView.frame.size.width, 0);
            }
        } completion:^(BOOL finished) {
            if(trackQueue.count >= 1) {
                [trackQueue[0] removeFromSuperview];
                [trackQueue removeObjectAtIndex: 0];
                
                queueView.contentSize = CGSizeMake(237 * trackQueue.count, 237);
                if(trackQueue.count == 1) {
                    nowPlayingLabel.hidden = NO;
                    upNextLabel.hidden = YES;
                } else if(trackQueue.count == 0) {
                    nowPlayingLabel.hidden = YES;
                    upNextLabel.hidden = YES;
                    [continuousImageScrollView setText: @"Text 678-707-8466 to add songs to the queue!"];
                    [continuousImageScrollView startScrollingWithScrollSpeed: 120];
                }
                [self playFirstTrackIfNotPlaying];
            }
        }];
}



- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData: data options: 0 error: nil];
        NSLog(@"%@", json);
        
        NSString *command = json[@"command"];
        
        NSLog(@"%@", command);
        
        if([command isEqualToString: @"queueTrack"]) {
            [self queueTrackWithInfo: json];
        } else if([command isEqualToString: @"pause"]) {
            NSLog(@"pausing");
            playbackManager.isPlaying = NO;
        } else if([command isEqualToString: @"play"]) {
            NSLog(@"playing");
            playbackManager.isPlaying = YES;
        } else if([command isEqualToString: @"skip"]) {
            NSLog(@"skipping");
            playbackManager.isPlaying = NO;
            [self removeTrackFromFrontOfQueue];
        }
    });
    
    //TODO : I think I leak trackURI, not sure how to solve that, like, what callback to release it in....
    /*
    NSString *command = [[message componentsSeparatedByString: @"}}}"] objectAtIndex: 0];
    NSString *commandData = [[message componentsSeparatedByString: @"}}}"] objectAtIndex: 1];
    
    if([command isEqualToString: @"queueTrack"]) {
        
    } else if([command isEqualToString: @"pause"]) {
        
    } else if([command isEqualToString: @"play"]) {
    
    } else if([command isEqualToString: @"skip"]) {
        
    }*/
    
    
    //continue awaiting track URLs from the relay server
    [socket readDataToData: [@"\n" dataUsingEncoding: NSUTF8StringEncoding] withTimeout: -1 tag: 0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
