//
//  FITCardioAudioFeedback.h
//  Commit
//
//  Created by Richard Nguyen on 2/18/14.
//  Copyright (c) 2014 ahsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface FITCardioAudioFeedback : NSObject <AVSpeechSynthesizerDelegate>

- (void) sayActivityDidStart;

- (void) sayActivityDidStop;

- (void) sayActivityDidPause;

- (void) sayActivityDidResume;

- (void) sayCurrentDistance: (double) distance unit:(NSString *) unit;

- (void) sayCurrentTime: (NSUInteger) duration;

- (void) sayAveragePace: (double) pace unit: (NSString *) unit;

- (void) sayString: (NSString *) string cancelPrevious: (BOOL) cancelPrevious;

@end
