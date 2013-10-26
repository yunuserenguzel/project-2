
#import "SNCPreviewViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
@interface SNCPreviewViewController ()

@property UIImageView* imageView;
@property UIButton* saveButton;

@end

@implementation SNCPreviewViewController
{
    
    AVAudioPlayer *audioPlayer;
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
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0 + self.navigationController.navigationBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.width)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.imageView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
    [self.imageView.layer setShadowOpacity:0.5];
    [self.imageView.layer setShadowRadius:5.0];
    [self.view addSubview:self.imageView];
    
    UIGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(play)];
    [self.view addGestureRecognizer:tapGesture];

    if(self.sonic != nil){
        [self configureViews];
    }
}



- (void) play
{
    if(self.sonic != nil){
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
        audioPlayer = [[AVAudioPlayer alloc] initWithData:self.sonic.sound error:nil];
        [audioPlayer setVolume:1.0];
        audioPlayer.delegate = self;
        [audioPlayer play];
    }
}

- (void) configureViews
{
    [self.imageView setImage:self.sonic.image];
    [self play];
    
}

- (void)setsonic:(Sonic *)sonic
{
    _sonic = sonic;
    if([self isViewLoaded]){
        [self configureViews];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
