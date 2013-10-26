//
//  SPAlbumArtView.h
//  SpotifyPlay
//
//  Created by Matt Egan on 5/22/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CocoaLibSpotify.h"

@interface DPAlbumArtView : UIView {
    SPTrack *track;
    
    UIImageView *albumCoverView;

    UIView *trackDetailView;
    UILabel *trackNameLabel;
    UILabel *trackArtistAlbumLabel;
    
    UIView *queueNumberContainerView;
    UILabel *queueNumberLabel;

    NSString *URI;
    
}

@property (nonatomic, readonly) SPTrack *track;
@property (nonatomic, readonly) NSString *URI;

- (DPAlbumArtView *)initWithTrackURI:(NSString *)trackURI
                           inSession:(SPSession *)session
                           withFrame:(CGRect)frame
                        onCompletion:(void (^)(DPAlbumArtView *albumView, NSError *error))completionBlock;

- (void)setQueueNumber:(int)queueNumber;
- (void)hideTrackInformationView;

@end
