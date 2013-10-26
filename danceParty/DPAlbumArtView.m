//
//  SPAlbumArtView.m
//  SpotifyPlay
//
//  Created by Matt Egan on 5/22/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import "DPAlbumArtView.h"

@implementation DPAlbumArtView

@synthesize track;
@synthesize URI;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (DPAlbumArtView *)initWithTrackURI:(NSString *)trackURI
                           inSession:(SPSession *)session
                           withFrame:(CGRect)frame
                        onCompletion:(void (^)(DPAlbumArtView *albumView, NSError *error))completionBlock {

    self = [super initWithFrame: frame];
    if(self) {
        URI = [trackURI retain];
        
        albumCoverView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        trackDetailView = [[UIView alloc] initWithFrame: CGRectMake(0, 320, 320, 70)];
        trackDetailView.backgroundColor = [UIColor colorWithWhite: 0 alpha: 0.92];
        
        UIFont *trackNameFont = [UIFont fontWithName: @"HelveticaNeue-Light" size: 18];
        UIFont *trackArtistAlbumFont = [UIFont fontWithName: @"HelveticaNeue-Light" size: 13];
        
        trackNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 10, 280, 31)];
        trackArtistAlbumLabel = [[UILabel alloc] initWithFrame: CGRectMake(20, 30, 280, 31)];
        
        trackNameLabel.font = trackNameFont;
        trackArtistAlbumLabel.font = trackArtistAlbumFont;
        
        trackNameLabel.backgroundColor = trackArtistAlbumLabel.backgroundColor = [UIColor clearColor];
        trackNameLabel.textColor = trackArtistAlbumLabel.textColor = [UIColor whiteColor];
        
        [trackDetailView addSubview: trackNameLabel];
        [trackDetailView addSubview: trackArtistAlbumLabel];
        [self addSubview: albumCoverView];
        [self addSubview: trackDetailView];
        
        [SPTrack trackForTrackURL: [NSURL URLWithString: trackURI] inSession: session callback: ^(SPTrack *populatedTrack) {
            track = [populatedTrack retain];
            [SPAsyncLoading waitUntilLoaded: track timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                if(loadedItems.count != 1) {
                    completionBlock(self, [NSError errorWithDomain: @"SPAsyncLoading Fail" code: 1 userInfo: nil]);
                } else{
                    [SPAsyncLoading waitUntilLoaded: track.album timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                        if(loadedItems.count != 1) {
                            completionBlock(self, [NSError errorWithDomain: @"SPAsyncLoading Fail" code: 2 userInfo: nil]);
                        } else{
                            [SPAsyncLoading waitUntilLoaded: track.album.largestAvailableCover timeout: kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                                if(loadedItems.count != 1) {
                                    completionBlock(self, [NSError errorWithDomain: @"SPAsyncLoading Fail" code: 2 userInfo: nil]);
                                } else{
                                    trackNameLabel.text = track.name;
                                    trackArtistAlbumLabel.text = [NSString stringWithFormat: @"%@ - %@", track.album.artist.name, track.album.name];
                                    albumCoverView.image = track.album.largestAvailableCover.image;
                                    completionBlock(self, nil);
                                }
                            }];
                        }
                    }];
                }
            }];
        }];
    }
    return self;
}

- (void)setQueueNumber:(int)queueNumber {
    if(queueNumberContainerView == nil) {
        queueNumberContainerView = [[UIView alloc] init];
        queueNumberContainerView.backgroundColor = [UIColor colorWithWhite: 0 alpha: 0.5];
        [self addSubview: queueNumberContainerView];
    }
    if(queueNumberLabel == nil) {
        queueNumberLabel = [[UILabel alloc] init];
        queueNumberLabel.textColor = [UIColor whiteColor];
        queueNumberLabel.backgroundColor = [UIColor clearColor];
        [queueNumberContainerView addSubview: queueNumberLabel];
    }
    NSString *labelText = [NSString stringWithFormat: @"%i", queueNumber];
    UIFont *queueNumberFont = [UIFont fontWithName: @"HelveticaNeue-Bold" size: 20];
    CGSize labelSize = [labelText sizeWithFont: queueNumberFont];
    queueNumberLabel.frame = CGRectMake(10, 10, labelSize.width, labelSize.height);
    queueNumberLabel.text = labelText;
    queueNumberLabel.font = queueNumberFont;
    
    queueNumberContainerView.frame = CGRectMake(self.frame.size.width - labelSize.width - 20, 0, labelSize.width + 20, labelSize.height + 20);

}

- (void)hideTrackInformationView {
    trackDetailView.alpha = 0;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GotTouched" object:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.4e45
{
    // Drawing code
}
*/

@end
