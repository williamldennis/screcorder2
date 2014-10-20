//
//  VRViewController.h
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"
#import "SCRecordSession.h"

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIView *recordView1;

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *previewView1;


@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;


@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoPlayback;
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoPlayback1;

- (IBAction)switchFlash:(id)sender;


@end
