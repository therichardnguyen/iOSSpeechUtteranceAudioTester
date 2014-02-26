//
//  RLNViewController.m
//  AudioTester
//
//  Created by Richard Nguyen on 2/19/14.
//  Copyright (c) 2014 Richard Nguyen. All rights reserved.
//

#import "RLNViewController.h"
#import "AudioFeedback.h"
@interface RLNViewController ()
@property (strong, nonatomic) AudioFeedback *af;
@end

@implementation RLNViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.af = [[AudioFeedback alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sayOneThing:(id)sender {
    [self.af sayString:@"One thing" cancelPrevious:YES];
}

- (IBAction)sayAnotherThing:(id)sender {
    [self.af sayString:@"Another thing" cancelPrevious:YES];

}
- (IBAction)stopSession:(id)sender {
    [self.af stopSession];
}

@end
