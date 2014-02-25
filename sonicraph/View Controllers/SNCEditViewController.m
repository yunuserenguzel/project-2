#import "SNCEditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "NMRangeSlider.h"
#import "SNCShareViewController.h"
#import "UIImage+scaleToSize.h"
#import "Configurations.h"
#import "SNCSoundSlider.h"

@interface SNCEditViewController ()

@property UIImageView* imageView;
@property UIButton* saveButton;
@property NMRangeSlider* soundSlider;
@property UIButton* resetButton;

@property UIButton* backButton;
@property UILabel* titleLabel;
@property UIButton* doneButton;

@property SNCSoundSlider* soundTimeSlider;
@property NSTimer* soundTimer;

@end

@implementation SNCEditViewController
{
    AVAudioPlayer *audioPlayer;
}

- (CGRect) soundSliderFrame
{
    return CGRectMake(22.0, [self imageViewFrame].origin.y + [self imageViewFrame].size.height, 276.0, 80.0);
}

- (CGRect) backButtonFrame
{
    return CGRectMake(0.0, 0.0, 106.0, 66.0);
}
- (CGRect) titleLabelFrame
{
    return CGRectMake(106.0, 0.0, 108.0, 66.0);
}

- (CGRect) doneButtonFrame
{
    return CGRectMake(106.0 + 108.0, 0.0, 106.0, 66.0);
}

- (CGRect) imageViewFrame
{
    return CGRectMake(0.0, 66.0, self.view.frame.size.width, self.view.frame.size.width);
}
- (CGRect) resetButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 66.0);
    frame.origin = CGPointMake(self.view.frame.size.width - frame.size.width, [self replayButtonFrame].origin.y);
    return frame;
}

- (CGRect) replayButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 66.0);
    frame.origin = CGPointMake(0.0, self.view.frame.size.height - frame.size.height);
    return frame;
}
-(CGRect) soundTimeSliderFrame
{
    return CGRectMake(0.0, 387.0, 320.0, 3.0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    [self.view setBackgroundColor:CameraViewControllersBackgroundColor];
    [self initializeImageView];
    [self initializeSoundSlider];
    [self initializeReplayButton];
    [self initializeResetButton];
    [self initializeTopViews];
    [self initializeSoundTimeSlider];
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)];
    [self.view addGestureRecognizer:tapGesture];

    if(self.sonic != nil){
        [self configureViews];
    }
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneEdit)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
//   [self.view.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
//       view.layer.borderColor = [UIColor redColor].CGColor;
//       view.layer.borderWidth = 2.0f;
//   }];
}

- (void) initializeSoundTimeSlider
{
    self.soundTimeSlider = [[SNCSoundSlider alloc] init];
    [self.soundTimeSlider setFrame:[self soundTimeSliderFrame]];
    [self.soundTimeSlider setMinimumValue:0.0];
    [self.soundTimeSlider setMaximumValue:SonicMaximumSoundInterval];
    [self.soundTimeSlider setFillColor:PinkColor];
    [self.soundTimeSlider setBaseColor:[UIColor whiteColor]];
    [self.view addSubview:self.soundTimeSlider];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void) doneEdit
{
    __block SNCEditViewController* this = self;
    [self.sonic setSoundCroppingFrom:self.soundSlider.lowerValue to:self.soundSlider.upperValue withCompletionHandler:^(SonicData *sonic, NSError *error) {
        if(sonic)
        {
            [this performSegueWithIdentifier:ShareSonicSegue sender:this];
        }
        else
        {
            NSLog(@"error: %@",error);
        }
    }];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:YES];
//    [self.navigationController.navigationBar setHidden:YES];
    [self.soundTimeSlider setMaximumValue:audioPlayer.duration];
    self.soundTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateSoundTimer:) userInfo:nil repeats:YES];
}

- (void) updateSoundTimer:(NSTimer*) timer
{
    if (audioPlayer.currentTime >= self.soundSlider.upperValue) {
        [audioPlayer pause];
    } else {
        self.soundTimeSlider.value = audioPlayer.currentTime;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [audioPlayer stop];
    [self.soundTimer invalidate];
    [self.tabBarController.tabBar setHidden:NO];
//    [self.navigationController.navigationBar setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self replay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
}

- (void) initializeTopViews
{
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setFrame:[self backButtonFrame]];
    [self.backButton setTitle:@"Camera" forState:UIControlStateNormal];
    [self.backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setImage:[UIImage imageNamed:@"BackArrow.png"] forState:UIControlStateNormal];
    [self.backButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 0.0)];
    [self.backButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0)];
    [self.view addSubview:self.backButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:[self titleLabelFrame]];
    [self.titleLabel setText:@"Trim Sound"];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setFont:self.backButton.titleLabel.font];
    [self.view addSubview:self.titleLabel];
    
    self.doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.doneButton setFrame:[self doneButtonFrame]];
    [self.doneButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.doneButton addTarget:self action:@selector(doneEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.doneButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 10.0)];
    [self.view addSubview:self.doneButton];
    
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) initializeImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
//    [self.imageView.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.imageView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
//    [self.imageView.layer setShadowOpacity:0.5];
//    [self.imageView.layer setShadowRadius:5.0];
    [self.view addSubview:self.imageView];
}

- (void) initializeSoundSlider
{
    self.soundSlider = [[NMRangeSlider alloc] initWithFrame:[self soundSliderFrame]];
    [self.soundSlider setTrackBackgroundImage:[UIImage imageNamed:@"TtimBar.png"]];
//    [self.soundSlider setTrackBackgroundImage:[UIImage imageWithColor:[PinkColor colorWithAlphaComponent:0.5] withSize:CGSizeMake(276.0, 3.0)]];
    [self.soundSlider setTrackImage:[UIImage imageWithColor:[PinkColor colorWithAlphaComponent:1.0] withSize:CGSizeMake(276.0, 3.0)]];
    [self.soundSlider setMinimumValue:0.0];
    [self.soundSlider setLowerValue:0.0];
    [self.soundSlider setUpperValue:1.0];
    [self.soundSlider setMaximumValue:1.0];
    [self.soundSlider setMinimumRange:1.0];
    [self.soundSlider setLowerHandleImageNormal:[UIImage imageNamed:@"TrimHandle.png"]];
    [self.soundSlider setUpperHandleImageNormal:[UIImage imageNamed:@"TrimHandle.png"]];
    [self.soundSlider setLowerHandleImageHighlighted:[UIImage imageNamed:@"TrimHandle.png"]];
    [self.soundSlider setUpperHandleImageHighlighted:[UIImage imageNamed:@"TrimHandle.png"]];
    [self.view addSubview:self.soundSlider];
}

- (void) initializeResetButton
{
    self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetButton setTitle:@"Original" forState:UIControlStateNormal];
    [self.resetButton setBackgroundColor:CameraViewControllersBackgroundColor];
//    [self.resetButton.layer setBorderColor:[UIColor blackColor].CGColor];
//    [self.resetButton.layer setBorderWidth:1.0f];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetButton setFrame:[self resetButtonFrame]];
    [self.resetButton addTarget:self action:@selector(resetEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
}

- (void) initializeReplayButton
{
    self.replayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.replayButton setTitle:@"Replay" forState:UIControlStateNormal];
    [self.replayButton setBackgroundColor:CameraViewControllersBackgroundColor];
//    [self.replayButton.layer setBorderColor:[UIColor blackColor].CGColor];
//    [self.replayButton.layer setBorderWidth:1.0f];
    [self.replayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.replayButton setFrame:[self replayButtonFrame]];
    [self.replayButton addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.replayButton];
}

- (void) resetEdit
{
    [self.soundSlider setUpperValue:audioPlayer.duration];
    [self.soundSlider setUpperValue:[self.soundSlider maximumValue]];
    [self.soundSlider setLowerValue:[self.soundSlider minimumValue]];
}

- (void) replay
{
    if(self.sonic){
        [audioPlayer stop];
        [audioPlayer setCurrentTime:[self.soundSlider lowerValue]];
        [audioPlayer play];
    }
}

- (void) play
{
    if(self.sonic != nil){
        if([audioPlayer isPlaying]){
            [audioPlayer stop];
        } else {
            [audioPlayer play];
        }
    }
}

- (void) configureViews
{
    [self.imageView setImage:self.sonic.image];    [self.soundSlider setMaximumValue:audioPlayer.duration];
    [self.soundSlider setUpperValue:audioPlayer.duration];
}

- (void)setSonic:(SonicData *)sonic
{
    _sonic = sonic;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
    NSData* sound = self.sonic.sound ? self.sonic.sound : self.sonic.rawSound;
    audioPlayer = [[AVAudioPlayer alloc] initWithData:sound error:nil];
    [audioPlayer setVolume:1.0];
    audioPlayer.delegate = self;
    if([self isViewLoaded]){
        [self configureViews];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:ShareSonicSegue]){
        SNCShareViewController* shareController = [segue destinationViewController];
        [shareController setSonic:self.sonic];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
