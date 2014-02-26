//
//  FITCardioAudioFeedback.h
//  Commit
//
//  Created by Richard Nguyen on 2/18/14.
//  Copyright (c) 2014 ahsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioFeedback : NSObject <AVSpeechSynthesizerDelegate>

- (void) sayString: (NSString *) string cancelPrevious: (BOOL) cancelPrevious;

- (void) stopSession;
@end
