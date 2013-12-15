#import "SNCEditViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "NMRangeSlider.h"
#import "SNCShareViewController.h"


@interface SNCEditViewController ()

@property UIImageView* imageView;
@property UIButton* saveButton;
@property NMRangeSlider* soundSlider;
@property UIButton* resetButton;

@end

@implementation SNCEditViewController
{
    AVAudioPlayer *audioPlayer;
}

- (CGRect) soundSliderFrame
{
    return CGRectMake(10.0, 350.0, 300.0, 80.0);
}

- (CGRect) imageViewFrame
{
    return CGRectMake(0.0, 66.0, self.view.frame.size.width, self.view.frame.size.width);
}
- (CGRect) resetButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 44.0);
    frame.origin = CGPointMake(self.view.frame.size.width - frame.size.width, self.view.frame.size.height - frame.size.height);
    return frame;
}

- (CGRect) replayButtonFrame
{
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(160.0, 44.0);
    frame.origin = CGPointMake(0.0, self.view.frame.size.height - frame.size.height);
    return frame;
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
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationItem setTitle:@"Trim Sound"];
    [self initializeImageView];
    [self initializeSoundSlider];
    [self initializeReplayButton];
    [self initializeResetButton];
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)];
    [self.view addGestureRecognizer:tapGesture];
    
    if(self.sonic != nil){
        [self configureViews];
    }
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone    target:self action:@selector(doneEdit)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
//   [self.view.subviews enumerateObjectsUsingBlock:^(UIView* view, NSUInteger idx, BOOL *stop) {
//       view.layer.borderColor = [UIColor redColor].CGColor;
//       view.layer.borderWidth = 2.0f;
//   }];
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void) doneEdit
{
    __block SNCEditViewController* this = self;
    [self.sonic setSoundCroppingFrom:self.soundSlider.lowerValue to:self.soundSlider.upperValue withCompletionHandler:^(SonicData *sonic, NSError *error) {
        if(sonic){
            [this performSegueWithIdentifier:ShareSonicSegue sender:this];
            
        } else {
            NSLog(@"error: %@",error);
        }
    }];
}
- (void) viewWillAppear:(BOOL)animated
{
    
//    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [audioPlayer stop];
//    [self.navigationController setNavigationBarHidden:NO  animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void) initializeImageView
{
    self.imageView = [[UIImageView alloc] initWithFrame:[self imageViewFrame]];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.imageView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [self.imageView.layer setShadowOpacity:0.5];
    [self.imageView.layer setShadowRadius:5.0];
    [self.view addSubview:self.imageView];
}

- (void) initializeSoundSlider
{
    self.soundSlider = [[NMRangeSlider alloc] initWithFrame:[self soundSliderFrame]];
    [self.soundSlider setMinimumValue:0.0];
    [self.soundSlider setLowerValue:0.0];
    [self.soundSlider setUpperValue:1.0];
    [self.soundSlider setMaximumValue:1.0];
    [self.soundSlider setMinimumRange:1.0];
    [self.soundSlider setLowerHandleImageNormal:[UIImage imageNamed:@"TrimHandleBlue.png"]];
    [self.soundSlider setUpperHandleImageNormal:[UIImage imageNamed:@"TrimHandleBlue.png"]];
    [self.soundSlider setLowerHandleImageHighlighted:[UIImage imageNamed:@"TrimHandleBlue.png"]];
    [self.soundSlider setUpperHandleImageHighlighted:[UIImage imageNamed:@"TrimHandleBlue.png"]];
    [self.view addSubview:self.soundSlider];
}

- (void) initializeResetButton
{
    self.resetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
    [self.resetButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.resetButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.resetButton.layer setBorderWidth:1.0f];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetButton setFrame:[self resetButtonFrame]];
    [self.resetButton addTarget:self action:@selector(resetEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
}

- (void) initializeReplayButton
{
    self.replayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.replayButton setTitle:@"Replay" forState:UIControlStateNormal];
    [self.replayButton setBackgroundColor:[UIColor darkGrayColor]];
    [self.replayButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.replayButton.layer setBorderWidth:1.0f];
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

- (void)viewDidAppear:(BOOL)animated
{
    [self replay];
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
