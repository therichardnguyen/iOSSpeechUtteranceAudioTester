//
//  FITCardioAudioFeedback.m
//  Commit
//
//  Created by Richard Nguyen on 2/18/14.
//  Copyright (c) 2014 ahsieh. All rights reserved.
//

#import "FITCardioAudioFeedback.h"
#import "FITConverter.h"

@interface FITCardioAudioFeedback ()
@property (strong, nonatomic) AVAudioSession *session;
@property (strong, nonatomic) AVSpeechSynthesizer *voice;
@property (strong, nonatomic) AVSpeechUtterance *finalUtterance;
@end

@implementation FITCardioAudioFeedback

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.session = [AVAudioSession sharedInstance];
        NSError *error;
        [self.session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error];
        self.voice = [[AVSpeechSynthesizer alloc] init];
        self.voice.delegate = self;
        srand48(time(NULL));
    }
    return self;
}

- (void)dealloc
{
    [self setAudioSession:NO error:nil];
}

- (BOOL) setAudioSession: (BOOL) enabled error: (NSError **)error
{
    return [self.session setActive:enabled error:error];
}

- (AVSpeechUtterance *) utteranceWithString: (NSString *) string
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance  speechUtteranceWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-ES"];
    [utterance setRate:(AVSpeechUtteranceDefaultSpeechRate+AVSpeechUtteranceMinimumSpeechRate)/2.25];
    utterance.volume = 0.75;
    return utterance;
}

- (void) sayActivityDidStart
{
    NSArray *startStrings = @[@"Move bitch!",
                              @"Hell, it's about time",
                              @"Run, Forest, run!",
                              @"Let's see what you can do"];
    [self sayString:[NSString stringWithFormat:@"Activity started. %@", startStrings[(rand() % startStrings.count)]] cancelPrevious:YES];
}

- (void) sayActivityDidStop
{
    NSArray *stopString = @[@"That was absolutely pathetic",
                            @"Was that it?",
                            @"I've had better...",
                            @"Was that a run or a warm up?",
                            @"Oh man, that was embarrassing"];
    [self sayString:[NSString stringWithFormat:@"Activity stopped. %@", stopString[rand() % stopString.count]] cancelPrevious:YES];
}

- (void) sayActivityDidPause
{
    NSArray *pauseStrings = @[@"Taking a break? You would.",
                              @"Tired? You pussy."];
    [self sayString:[NSString stringWithFormat:@"Activity paused. %@",pauseStrings[rand() % pauseStrings.count]] cancelPrevious:YES];
}

- (void) sayActivityDidResume
{
    NSArray *resumeString = @[@"Keep moving bitch!",
                              @"I thought we'd never start again",
                              @"Thank god, I thought you were dead"];
    [self sayString:[NSString stringWithFormat:@"Activity resumed. %@", resumeString[rand() % resumeString.count]] cancelPrevious:YES];
}

- (void) sayCurrentDistance: (double) distance unit:(NSString *) unit
{
    double decimalPart = fmod(distance, 1);
    if (decimalPart*100 < 1) { // If we have x.00
        [self sayString:[NSString stringWithFormat:@"Current distance %.0f %@", distance, unit] cancelPrevious:NO];
    } else {
        [self sayString:[NSString stringWithFormat:@"Current distance %.2f %@", distance, unit] cancelPrevious:NO];
    }
}

- (void) sayAveragePace: (double) pace unit: (NSString *) unit
{
    double paceMinutes = floor(pace);
    double paceSeconds = 60 * (pace - paceMinutes);
    [self sayString:[NSString stringWithFormat:@"Average pace %d minutes %d seconds %@", (int)paceMinutes, (int)paceSeconds, unit] cancelPrevious:NO];
}

- (void) sayCurrentTime: (NSUInteger) duration
{
    NSUInteger hours = duration / 3600;
    NSUInteger minutes = (duration - (hours * 3600))/ 60;
    NSUInteger seconds = duration % 60;
    
    NSMutableString *timeString = [NSMutableString stringWithString:@"Current time"];
    BOOL noTime = YES;
    if (hours != 0) {
        [timeString appendFormat:@"%lu %@", hours, hours == 1 ? @"hour" : @"hours"];
        noTime &= NO;
    }
    if (minutes != 0) {
        [timeString appendFormat:@"%lu %@", minutes, minutes == 1 ? @"minute" : @"minutes"];
        noTime &= NO;
    }
    if (seconds != 0) {
        [timeString appendFormat:@"%lu %@", seconds, seconds == 1 ? @"second" : @"seconds"];
        noTime &= NO;
    }
    if (noTime) {
        [timeString appendString:@"Nothing"];
    }
    [self sayString:timeString cancelPrevious:NO];
}

- (void) sayString: (NSString *) string cancelPrevious: (BOOL) cancelPrevious
{
    if (cancelPrevious) {
        if (!self.voice.speaking) {
            NSError *error;
            if ([self setAudioSession:YES error:&error]) {
                NSLog(@"Successfully started audio session");
            }
            else {
                NSLog(@"Failed to start audio session %@", error);
            }
        }
        AVSpeechSynthesizer *oldSynthesizer = self.voice;
        self.voice = nil;
        [oldSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
        self.voice = [[AVSpeechSynthesizer alloc] init];
        self.voice.delegate = self;
    }
    
    // Keep track of the final utterance, we'll use this to determine whether or not we should stop the audio session
    self.finalUtterance = [self utteranceWithString:string];
    [self.voice speakUtterance:self.finalUtterance];


}

#pragma mark - AVSpeechSynthesizerDelegate

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSError *error;
    // Only stop the audio session if this is the last created voice synthesizer and the last utterance for that voice synthesizer

    if (synthesizer == self.voice  && self.finalUtterance == utterance) {
        if ([self setAudioSession:NO error:&error]) {
            NSLog(@"Stopped the audio session: Speech synthesizer still speaking (%d), paused (%d)", synthesizer.speaking,synthesizer.paused);
        } else {
            NSLog(@"ERROR failed to stop the audio session: %@. Speech synthesizer still speaking (%d), paused (%d)", error, synthesizer.speaking, synthesizer.paused);
        }
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"Utterance (%@) did cancel", utterance.speechString);
    NSError *error;
    if (synthesizer == self.voice) {
        if ([self setAudioSession:NO error:&error]) {
            NSLog(@"Stopped the audio session: Speech synthesizer still speaking %d", synthesizer.speaking);
        } else {
            NSLog(@"ERROR failed to stop the audio session: %@. Speech synthesizer still speaking %d", error, synthesizer.speaking);
        }
    }
}


@end
