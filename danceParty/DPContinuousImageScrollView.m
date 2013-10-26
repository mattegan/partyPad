//
//  HTGContinuousImageScrollView.m
//  hateTheGame
//
//  Created by Matt Egan on 9/28/13.
//  Copyright (c) 2013 Matt Egan. All rights reserved.
//

#import "DPContinuousImageScrollView.h"

@implementation DPContinuousImageScrollView

@synthesize hasImages;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        hasImages = NO;
        lastIncrementTime = 0;
    }
    return self;
}

- (void)setImages:(NSArray *)imageArray {
    images = [imageArray retain];
    imageViews = [[NSMutableArray alloc] init];
    
    CGFloat currentOffset = 0;
    totalWidth = 0;
    
    
    
    while(currentOffset < self.frame.size.width * 2) {
        for(UIImage *image in images) {
            UIImageView *imageView = [[[UIImageView alloc] initWithFrame: CGRectMake(currentOffset, 0, image.size.width / 2, image.size.height / 2)] autorelease];
            imageView.image = image;
            [self addSubview: imageView];
            [imageViews addObject: imageView];
            currentOffset += image.size.width / 2;
            totalWidth += image.size.width / 2;
        }
    }
    hasImages = YES;
    leftmostImageView = imageViews[0];
}

- (void)setText:(NSString *)text {
    [self pauseScrolling];
    for(UILabel *label in textViews) {
        [label removeFromSuperview];
    }
    textViews = [[NSMutableArray alloc] init];
    
    UIFont *font = [UIFont fontWithName: @"HelveticaNeue-Thin" size: 64.0];
    CGSize textSize = [text sizeWithAttributes: @{NSFontAttributeName: font}];
    
    CGFloat currentOffset = 0;
    totalWidth = 0;
    while(currentOffset < self.frame.size.width * 2) {
        UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(currentOffset, 0, textSize.width + 120, textSize.height)];
        label.font = font;
        label.text = text;
        label.textColor = [UIColor whiteColor];
        [self addSubview: label];
        [textViews addObject: label];
        currentOffset += label.frame.size.width;
        totalWidth += label.frame.size.width;
    }
    hasLabels = YES;
    leftmostLabel = textViews[0];
}

- (void)startScrollingWithScrollSpeed:(float)speed {
    scrollSpeed = speed;
    scrollTimer = [[NSTimer alloc] initWithFireDate: [NSDate date] interval: 1/60.0 target: self selector: @selector(incrementScroll:) userInfo: nil repeats: YES];
    [[NSRunLoop mainRunLoop] addTimer: scrollTimer forMode: NSRunLoopCommonModes];
}

- (void)pauseScrolling {
    [scrollTimer invalidate];
    scrollTimer = nil;
    lastIncrementTime = 0;
    lastOffset = self.contentOffset;
    NSLog(@"%@", NSStringFromCGPoint(lastOffset));
}

- (void)resumeScrolling {
    if(scrollTimer == nil) {
        self.contentOffset = lastOffset;
        [self startScrollingWithScrollSpeed: scrollSpeed];
    }
}

- (void)incrementScroll:(id)sender {
    if(lastIncrementTime == 0) {
        lastIncrementTime = [[NSDate date] timeIntervalSince1970];
    }
    NSTimeInterval timeDelta = [[NSDate date] timeIntervalSince1970] - lastIncrementTime;
    self.contentOffset = CGPointMake(self.contentOffset.x + (scrollSpeed * timeDelta), 0);
    if(leftmostLabel.frame.origin.x + leftmostLabel.frame.size.width <= self.contentOffset.x) {
        for(UILabel *textView in textViews) {
            textView.frame = CGRectOffset(textView.frame, -1 * leftmostLabel.frame.size.width, 0);
        }
        leftmostLabel.frame = CGRectMake(totalWidth - leftmostLabel.frame.size.width, 0, leftmostLabel.frame.size.width, leftmostLabel.frame.size.height);
        self.contentOffset = CGPointMake(0, 0);
        leftmostLabel = textViews[([textViews indexOfObject: leftmostLabel] + 1) % textViews.count];
    }
    lastIncrementTime = [[NSDate date] timeIntervalSince1970];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {

    // Drawing code
}
*/

- (void)dealloc {
    [scrollTimer invalidate];
    [scrollTimer release];
    
    [imageViews release];
    [images release];
    
    [super dealloc];
}

@end
