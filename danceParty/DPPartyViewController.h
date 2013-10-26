//
//  DPPartyViewController.h
//  danceParty
//
//  Created by Matt Egan on 10/19/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"
#import "GCDAsyncSocket.h"
#import "DPContinuousImageScrollView.h"
#import "DPAlbumArtView.h"
#import "CorePlot-CocoaTouch.h"

@interface DPPartyViewController : UIViewController <SPSessionDelegate, SPPlaybackManagerDelegate, GCDAsyncSocketDelegate, CPTPlotDataSource> {
    SPSession *session;
    GCDAsyncSocket *socket;
    
    IBOutlet DPContinuousImageScrollView *continuousImageScrollView;
    IBOutlet UIScrollView *queueView;
    IBOutlet CPTGraphHostingView *graphHostingView;
    
    IBOutlet UILabel *nothingIsPlayingLabel;
    IBOutlet UILabel *averageEnergyLabel;
    IBOutlet UILabel *averageBPMLabel;
    IBOutlet UILabel *averageDanceabilityLabel;
    
    IBOutlet UILabel *nowPlayingLabel;
    IBOutlet UILabel *upNextLabel;
    
    IBOutlet UILabel *averageEnergyTextLabel;
    IBOutlet UILabel *averageBPMTextLabel;
    IBOutlet UILabel *averageDanceabilityTextLabel;
    
    SPPlaybackManager *playbackManager;
    
    
    NSMutableArray *trackQueue;
    
    DPAlbumArtView *nowPlaying;
    
    float averageEnergy;
    float averageDancability;
    float averageTempo;
    
    float timeSum;
    
    float maxTempo;
    
    CPTGraph *graph;
    
    CPTScatterPlot *tempoPlot;
    CPTScatterPlot *energyPlot;
    CPTScatterPlot *danceabilityPlot;
    
    NSMutableArray *points;
    
    

}

- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot;
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx;

@end
