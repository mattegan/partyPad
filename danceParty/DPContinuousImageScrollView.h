//
//  HTGContinuousImageScrollView.h
//  hateTheGame
//
//  Created by Matt Egan on 9/28/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPContinuousImageScrollView : UIScrollView {
    NSArray *images;
    NSMutableArray *imageViews;
    NSMutableArray *textViews;
    
    UIImageView *leftmostImageView;
    UILabel *leftmostLabel;
    
    CGFloat totalWidth;
    float scrollSpeed;
    
    NSTimeInterval lastIncrementTime;
    
    CGPoint lastOffset;
    
    BOOL hasImages;
    BOOL hasLabels;
    
    NSTimer *scrollTimer;
}

@property (nonatomic) BOOL hasImages;

- (void)setImages:(NSArray *)imageArray;
- (void)setText:(NSString *)text;
- (void)pauseScrolling;
- (void)resumeScrolling;
- (void)startScrollingWithScrollSpeed:(float)speed;

@end
