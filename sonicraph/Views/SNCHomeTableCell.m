//
//  SNCHomeTableCell.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/14/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeTableCell.h"
#import "SonicData.h"
#import "SonicPlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "SNCAPIManager.h"

#import "TypeDefs.h"
#import "Configurations.h"
#import "NSDate+NVTimeAgo.h"
#import "AuthenticationManager.h"

#define DeleteConfirmAlertViewTag 10001
#define ResonicConfirmAlertViewTag 20020

#define SonicActionSheetTag 121212
#define DeleteResonicActionSheetTag 123123

#define ButtonsTop 405.0
#define LabelsTop 380.0


@interface SNCHomeTableCell () <UIActionSheetDelegate,UIAlertViewDelegate>

@property SonicPlayerView* sonicPlayerView;
@property UIImageView* cellSpacingView;

@end

@implementation SNCHomeTableCell

- (CGRect) userImageViewFrame
{
    return  CGRectMake(10.0, 6.0, 44.0, 44.0);
}
- (CGRect) cellSpacingViewFrame
{
    return CGRectMake(0.0, HeightForHomeCell - 1.0, 320.0, 1.0);
}
- (CGRect) userImageMaskViewFrame
{
    return [self userImageViewFrame];
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(64.0, 6.0, 160.0, 44.0);
}

- (CGRect) timestampLabelFrame
{
    return CGRectMake(200.0, 0.0, 110.0, 22.0);
}

- (CGRect) resonicedByUsernameLabelFrame
{
    return CGRectMake(200.0, 33.0, 110.0, 22.0);
}

- (CGRect) sonicPlayerViewFrame
{
    return CGRectMake(0.0, 56.0, 320.0, 320.0);
}

- (CGRect) likeButtonFrame
{
    return CGRectMake(10.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) commentButtonFrame
{
    return CGRectMake(90.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) resonicButtonFrame
{
    return CGRectMake(170.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) shareButtonFrame
{
    return CGRectMake(250.0, ButtonsTop, 66.0, 44.0);
}

- (CGRect) likesLabelFrame
{
    return CGRectMake(0.0, LabelsTop, 88.0, 22.0);
}

- (CGRect) commentsLabelFrame
{
    return CGRectMake(80.0, LabelsTop, 88.0, 22.0);
}

- (CGRect) resonicsLabelFrame
{
    return CGRectMake(160.0, LabelsTop, 88.0, 22.0);
}

- (Sonic*) actualSonic
{
    return self.sonic.isResonic ? self.sonic.originalSonic : self.sonic;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initViews];
        
    }
    return self;
}

- (void) initViews
{
    self.userImageView = [[UIImageView alloc] initWithFrame:[self userImageViewFrame]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.userImageView setImage:SonicPlaceholderImage];
    [self.userImageView setClipsToBounds:YES];
    [self.userImageView.layer setCornerRadius:10.0];
    [self addSubview:self.userImageView];
    
    self.userImageMaskView = [[UIImageView alloc] initWithFrame:[self userImageMaskViewFrame]];
    [self addSubview:self.userImageMaskView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setFont:[self.usernameLabel.font fontWithSize:14.0]];
    [self addSubview:self.usernameLabel];
    
    self.timestampLabel = [[UILabel alloc] initWithFrame:[self timestampLabelFrame]];
    [self.timestampLabel setFont:[self.timestampLabel.font fontWithSize:9.0]];
    [self.timestampLabel setTextColor:[UIColor darkGrayColor]];
    [self.timestampLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:self.timestampLabel];
    
    self.resonicedByUsernameLabel = [[UILabel alloc] initWithFrame:[self resonicedByUsernameLabelFrame]];
    [self.resonicedByUsernameLabel setTextAlignment:NSTextAlignmentRight];
    [self.resonicedByUsernameLabel setFont:[self.timestampLabel.font fontWithSize:12.0]];
    [self.resonicedByUsernameLabel setTextColor:[UIColor lightGrayColor]];
    [self addSubview:self.resonicedByUsernameLabel];
    
    self.sonicPlayerView = [[SonicPlayerView alloc] init];
    [self.sonicPlayerView setFrame:[self sonicPlayerViewFrame]];
    [self addSubview:self.sonicPlayerView];
    [self addSubview:self.usernameLabel];
    [self initLabels];
    [self initButtons];
    self.cellSpacingView = [[UIImageView alloc] initWithFrame:[self cellSpacingViewFrame]];
    [self.cellSpacingView setBackgroundColor:CellSpacingGrayColor];
    [self addSubview:self.cellSpacingView];
    
    [self.usernameLabel setUserInteractionEnabled:YES];
    [self.userImageView setUserInteractionEnabled:YES];
    
    UIGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.usernameLabel addGestureRecognizer:tapGesture];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture)];
    [self.userImageView addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(refreshSonicNotification:)
     name:NotificationUpdateViewForSonic
     object:nil];
}

- (void) tapGesture
{
    [self.delegate openProfileForUser:[self actualSonic].owner];
}

- (void) refreshSonicNotification:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if(sonic == self.sonic || sonic == self.sonic.originalSonic){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configureViews];
        });
    }
}

- (void) initLabels
{   UITapGestureRecognizer* tapGesture;
    self.likesCountLabel = [[UILabel alloc] initWithFrame:[self likesLabelFrame]];
    [self.likesCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.likesCountLabel setFont:[self.likesCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.likesCountLabel];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLikes)];
    [self.likesCountLabel addGestureRecognizer:tapGesture];
    [self.likesCountLabel setUserInteractionEnabled:YES];

    self.commentsCountLabel = [[UILabel alloc] initWithFrame:[self commentsLabelFrame]];
    [self.commentsCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.commentsCountLabel setFont:[self.commentsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.commentsCountLabel];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openComments)];
    [self.commentsCountLabel addGestureRecognizer:tapGesture];
    [self.commentsCountLabel setUserInteractionEnabled:YES];
    
    self.resonicsCountLabel = [[UILabel alloc] initWithFrame:[self resonicsLabelFrame]];
    [self.resonicsCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.resonicsCountLabel setFont:[self.resonicsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.resonicsCountLabel];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openResonics)];
    [self.resonicsCountLabel addGestureRecognizer:tapGesture];
    [self.resonicsCountLabel setUserInteractionEnabled:YES];
    
}

- (void) initButtons
{
    self.likeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.likeButton setFrame:[self likeButtonFrame]];
    [self.likeButton setImage:[UIImage imageNamed:@"HeartPink.png"] forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(likeSonic) forControlEvents:UIControlEventTouchUpInside];

    self.commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.commentButton setFrame:[self commentButtonFrame]];
    [self.commentButton setImage:[UIImage imageNamed:@"CommentPink.png"] forState:UIControlStateNormal];
    [self.commentButton addTarget:self action:@selector(commentSonic) forControlEvents:UIControlEventTouchUpInside];
    
    self.resonicButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.resonicButton setFrame:[self resonicButtonFrame]];
    [self.resonicButton setImage:[UIImage imageNamed:@"ReSonicPink.png"] forState:UIControlStateNormal];
    [self.resonicButton addTarget:self action:@selector(resonic) forControlEvents:UIControlEventTouchUpInside];

    self.shareButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.shareButton setFrame:[self shareButtonFrame]];
    [self.shareButton setImage:[UIImage imageNamed:@"ShareWhite.png"] forState:UIControlStateNormal];
    [self.shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    [@[self.likeButton,self.commentButton,self.resonicButton,self.shareButton] enumerateObjectsUsingBlock:^(UIButton* button, NSUInteger idx, BOOL *stop) {
        [button setTintColor:PinkColor];
        [button addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionInitial context:nil];
        [self addSubview:button];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([object isKindOfClass:[UIButton class]]){
        UIButton* button = object;
        if([button state] == UIControlStateHighlighted){
            [button setTintColor:[PinkColor colorWithAlphaComponent:0.5]];
        } else {
            [button setTintColor:PinkColor];
        }
    }
}

- (void) share
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Share on Facebook",@"Share on Twitter",@"Copy URL",@"Open Details", nil];
    actionSheet.tag = SonicActionSheetTag;
    [actionSheet showInView:self];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == SonicActionSheetTag){
        if(buttonIndex == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Do you confirm to delete this sonic?" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:@"Cancel", nil];
            alert.tag = DeleteConfirmAlertViewTag;
            [alert show];
        }
    } else if(actionSheet.tag == DeleteResonicActionSheetTag){
        if(buttonIndex == 0) {
            if(self.sonic.isResonic){
                [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:^(BOOL successful) {
                    [SNCAPIManager deleteResonic:self.sonic.originalSonic withCompletionBlock:^(Sonic *sonic) {
                        [self.sonic.originalSonic updateWithSonic:sonic];
                    } andErrorBlock:nil];
                } andErrorBlock:^(NSError *error) {
                    
                }];
            } else {
                [SNCAPIManager deleteResonic:self.sonic withCompletionBlock:^(Sonic *sonic) {
                    [self.sonic updateWithSonic:sonic];
                } andErrorBlock:nil];
            }
        }
    }
    
}

- (void) resonic
{
    if([self.resonicButton isSelected]){
        UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Delete resonic"
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:@"Delete"
                                      otherButtonTitles: nil];
        actionSheet.tag = DeleteResonicActionSheetTag;
        [actionSheet showInView:self];
        
    } else {
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"Resonic"
                              message:@"Do you want to resonic this?"
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Resonic!", nil];
        alert.tag = ResonicConfirmAlertViewTag;
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == DeleteConfirmAlertViewTag){
        if(buttonIndex == 0){
            [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }
    else if(alertView.tag == ResonicConfirmAlertViewTag){
        if(buttonIndex == 1){
            Sonic* sonicToBeResoniced = [self actualSonic];
            [SNCAPIManager resonicSonic:sonicToBeResoniced withCompletionBlock:^(Sonic *sonic) {
                [sonicToBeResoniced updateWithSonic:sonic];
            } andErrorBlock:nil];
        }
    }
}


- (void) openLikes
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenLikes];
}

- (void) openComments
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenComments];
}

- (void) openResonics
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeOpenResonics];
}

- (void) commentSonic
{
    [self.delegate sonic:[self actualSonic] actionFired:SNCHomeTableCellActionTypeComment];
}

- (void)likeSonic
{
    Sonic* currentSonic = [self actualSonic];
    [self.likeButton setHighlighted:YES];
    if ([self.likeButton isSelected]){
        [self.likeButton setSelected:NO];
        [SNCAPIManager dislikeSonic:currentSonic withCompletionBlock:^(Sonic *sonic) {
            [currentSonic updateWithSonic:sonic];
        } andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
    else {
        [self.likeButton setSelected:YES];
        [SNCAPIManager likeSonic:currentSonic withCompletionBlock:^(Sonic *sonic) {
            [currentSonic updateWithSonic:sonic];
        } andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
}


- (void)setSonic:(Sonic *)sonic
{
    if(_sonic != sonic){
        _sonic = sonic;
        [self configureViews];
    }
}

- (void) configureViews
{
    if(self.sonic.isResonic){
        [self configureViewsForSonic:self.sonic.originalSonic];
        [self.resonicedByUsernameLabel setText:[NSString stringWithFormat:@"resoniced by %@",self.sonic.owner.username]];
    } else {
        [self configureViewsForSonic:self.sonic];
        [self.resonicedByUsernameLabel setText:[NSString stringWithFormat:@""]];
    }
}

- (void) configureViewsForSonic:(Sonic*)sonic
{
    [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:sonic.sonicUrl]];
    [self.usernameLabel setText:[sonic.owner username]];
    [self.userImageView setImage:SonicPlaceholderImage];
    [sonic.owner getThumbnailProfileImageWithCompletionBlock:^(id object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userImageView setImage:object];
        });
    }];
    [self.timestampLabel setText:[[sonic creationDate] formattedAsTimeAgo]];
    if([sonic.owner.userId isEqualToString:[[[AuthenticationManager sharedInstance] authenticatedUser] userId]]){
        [self.resonicButton setEnabled:NO];
    } else {
        [self.resonicButton setEnabled:YES];
        [self.resonicButton setSelected:sonic.isResonicedByMe];
    }
    [self.likeButton setSelected:sonic.isLikedByMe];
    self.likesCountLabel.text = [NSString stringWithFormat:@"%d %@",sonic.likeCount,LikesText];
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%d %@",sonic.commentCount,CommentsText];
    self.resonicsCountLabel.text = [NSString stringWithFormat:@"%d %@",sonic.resonicCount,ResonicsText];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellWonCenterOfTableView
{
    [self.sonicPlayerView play];
}

- (void) cellLostCenterOfTableView
{
    [self.sonicPlayerView pause];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//
//- (void)prepareForReuse
//{
//    self.sonic = nil;
//    [self.usernameLabel setText:@""];
//    [self.userImageView setImage:SonicPlaceholderImage];
//}


@end
