//
//  FITCardioAudioFeedback.m
//  Commit
//
//  Created by Richard Nguyen on 2/18/14.
//  Copyright (c) 2014 ahsieh. All rights reserved.
//

#import "AudioFeedback.h"

@interface AudioFeedback ()
@property (strong, nonatomic) AVAudioSession *session;
@property (strong, nonatomic) AVSpeechSynthesizer *voice;
@property (strong, nonatomic) AVSpeechUtterance *finalUtterance;
@end

@implementation AudioFeedback

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
    [self.session setActive:NO error:nil];
}

- (AVSpeechSynthesizer *)voice
{
    if (!_voice) {
        _voice = [[AVSpeechSynthesizer alloc] init];
    }
    return _voice;
}

- (AVSpeechUtterance *) utteranceWithString: (NSString *) string
{
    AVSpeechUtterance *utterance = [AVSpeechUtterance  speechUtteranceWithString:string];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"en-ES"];
    [utterance setRate:(AVSpeechUtteranceDefaultSpeechRate+AVSpeechUtteranceMinimumSpeechRate)/2.25];
    utterance.volume = 0.75;
    return utterance;
}

- (void) sayString: (NSString *) string cancelPrevious: (BOOL) cancelPrevious
{
    if (cancelPrevious) {
        NSError *error;
        if ([self.session setActive:YES error:&error]) {
            NSLog(@"Successfully started audio session");
        }
        else {
            NSLog(@"Failed to start audio session %@", error);
        }
        AVSpeechSynthesizer *oldSynthesizer = self.voice;
        self.voice = nil;
        [oldSynthesizer stopSpeakingAtBoundary:AVSpeechBoundaryWord];
        self.voice.delegate = self;
    }
    
    // Keep track of the final utterance, we'll use this to determine whether or not we should stop the audio session
    self.finalUtterance = [self utteranceWithString:string];
    [self.voice speakUtterance:self.finalUtterance];
    
    
}

- (void) stopSession
{
    NSError *error;
    if ([self.session setActive:NO error:&error]) {
        NSLog(@"Stopped the audio session");
    } else {
        NSLog(@"ERROR failed to stop the audio session: %@. ", error);
    }
}

#pragma mark - AVSpeechSynthesizerDelegate

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSError *error;
    // Only stop the audio session if this is the last created voice synthesizer and the last utterance for that voice synthesizer
    if (synthesizer == self.voice && utterance == self.finalUtterance) {
        
        if ([self.session setActive:NO error:&error]) {
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
        if ([self.session setActive:NO error:&error]) {
            NSLog(@"Stopped the audio session: Speech synthesizer still speaking %d", synthesizer.speaking);
        } else {
            NSLog(@"ERROR failed to stop the audio session: %@. Speech synthesizer still speaking %d", error, synthesizer.speaking);
        }
    }
}


@end
