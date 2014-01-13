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

#define DeleteConfirmAlertViewTag 10001
#define ResonicConfirmAlertViewTag 20020

#define SonicActionSheetTag 121212
#define DeleteResonicActionSheetTag 123123

#define ButtonsTop 397.0
#define LabelsTop 377.0


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
    return CGRectMake(0.0, 450.0, 320.0, 1.0);
}
- (CGRect) userImageMaskViewFrame
{
    return [self userImageViewFrame];
}

- (CGRect) usernameLabelFrame
{
    return CGRectMake(64.0, 6.0, 320.0, 44.0);
}

- (CGRect) timestampLabelFrame
{
    return CGRectMake(200.0, 0.0, 110.0, 22.0);
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



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self initViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationLikedSonic:) name:NotificationLikeSonic object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotificationDislikedSonic:) name:NotificationDislikeSonic object:nil];
        
    }
    return self;
}

- (void) initViews
{
//    [self.layer setBorderColor:[UIColor redColor].CGColor];
//    [self.layer setBorderWidth:1.0f];
    NSLog(@"%@",self);
    self.userImageView = [[UIImageView alloc] initWithFrame:[self userImageViewFrame]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.userImageView setImage:SonicPlaceholderImage];
    [self.userImageView setClipsToBounds:YES];
    [self.userImageView.layer setCornerRadius:self.userImageView.frame.size.height * 0.5];
    [self.userImageView.layer setShouldRasterize:YES];
    [self.userImageView.layer setRasterizationScale:2.0];
    [self addSubview:self.userImageView];
    
    self.userImageMaskView = [[UIImageView alloc] initWithFrame:[self userImageMaskViewFrame]];
    [self addSubview:self.userImageMaskView];
    
    self.usernameLabel = [[UILabel alloc] initWithFrame:[self usernameLabelFrame]];
    [self.usernameLabel setText:@"yeguzel"];
    [self.usernameLabel setFont:[self.usernameLabel.font fontWithSize:14.0]];
    [self addSubview:self.usernameLabel];
    
    self.timestampLabel = [[UILabel alloc] initWithFrame:[self timestampLabelFrame]];
    [self.timestampLabel setFont:[self.timestampLabel.font fontWithSize:9.0]];
    [self.timestampLabel setTextColor:[UIColor darkGrayColor]];
    [self.timestampLabel setTextAlignment:NSTextAlignmentRight];
    [self addSubview:self.timestampLabel];
    
    self.sonicPlayerView = [[SonicPlayerView alloc] init];
    [self.sonicPlayerView setFrame:[self sonicPlayerViewFrame]];
    [self addSubview:self.sonicPlayerView];
    [self addSubview:self.usernameLabel];
    [self initLabels];
    [self initButtons];
    self.cellSpacingView = [[UIImageView alloc] initWithFrame:[self cellSpacingViewFrame]];
//    [self.cellSpacingView setImage:[UIImage imageNamed:@"44PXLabelWithShadow@
    [self.cellSpacingView setBackgroundColor:CellSpacingGrayColor];
    [self addSubview:self.cellSpacingView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSonicNotification:) name:NotificationSonicSaved object:nil];
    
}

- (void) refreshSonicNotification:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonic.sonicId isEqualToString:sonic.sonicId]){
        self.sonic = sonic;
    }
}

- (void) initLabels
{
    self.likesCountLabel = [[UILabel alloc] initWithFrame:[self likesLabelFrame]];
//    [self.likesCountLabel.layer setBorderColor:[UIColor redColor].CGColor];
//    [self.likesCountLabel.layer setBorderWidth:1.0f];
    [self.likesCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.likesCountLabel setFont:[self.likesCountLabel.font fontWithSize:11.0]];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openLikes)];
    [self.likesCountLabel addGestureRecognizer:tapGesture];
    [self.likesCountLabel setUserInteractionEnabled:YES];
    [self addSubview:self.likesCountLabel];

    self.commentsCountLabel = [[UILabel alloc] initWithFrame:[self commentsLabelFrame]];
    [self.commentsCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.commentsCountLabel setFont:[self.commentsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.commentsCountLabel];
    
    self.resonicsCountLabel = [[UILabel alloc] initWithFrame:[self resonicsLabelFrame]];
    [self.resonicsCountLabel setTextAlignment:NSTextAlignmentCenter];
    [self.resonicsCountLabel setFont:[self.resonicsCountLabel.font fontWithSize:11.0]];
    [self addSubview:self.resonicsCountLabel];
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
            [SNCAPIManager deleteResonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }
    
}
- (void) resonic
{
    if(self.sonic.isResonicedByMe){
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete resonic" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
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
    NSLog(@"%d",buttonIndex);
    if(alertView.tag == DeleteConfirmAlertViewTag){
        if(buttonIndex == 0){
            [SNCAPIManager deleteSonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }
    else if(alertView.tag == ResonicConfirmAlertViewTag){
        if(buttonIndex == 1){
            [SNCAPIManager resonicSonic:self.sonic withCompletionBlock:nil andErrorBlock:nil];
        }
    }
}



- (void) openLikes
{
    [self.delegate sonic:self.sonic actionFired:SNCHomeTableCellActionTypeOpenLikes];
}

- (void) commentSonic
{
    [self.delegate sonic:self.sonic actionFired:SNCHomeTableCellActionTypeComment];
}

- (void)likeSonic
{
    [self.likeButton setHighlighted:YES];
    if ([self.likeButton isSelected]){
        [self.likeButton setSelected:NO];
        [SNCAPIManager dislikeSonic:self.sonic withCompletionBlock:nil andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:YES];
        }];
    }
    else {
        [self.likeButton setSelected:YES];
        [SNCAPIManager likeSonic:self.sonic withCompletionBlock:nil andErrorBlock:^(NSError *error) {
            [self.likeButton setSelected:NO];
        }];
    }
    
}

- (void)receivedNotificationLikedSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonic.sonicId isEqualToString:sonic.sonicId]){
        [self.likeButton setSelected:YES];
    }
}
- (void)receivedNotificationDislikedSonic:(NSNotification*)notification
{
    Sonic* sonic = notification.object;
    if([self.sonic.sonicId isEqualToString:sonic.sonicId]){
        [self.likeButton setSelected:NO];
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
    [self.sonicPlayerView setSonicUrl:[NSURL URLWithString:self.sonic.sonicUrl]];
    [self.usernameLabel setText:[self.sonic.owner username]];
    [self.userImageView setImage:SonicPlaceholderImage];
    [SNCAPIManager getImage:[NSURL URLWithString:self.sonic.owner.profileImageUrl] withCompletionBlock:^(id object) {
        if(object){
            [self.userImageView setImage:(UIImage *)object];
        }
    }];
    [self.timestampLabel setText:[[self.sonic creationDate] formattedAsTimeAgo]];
    [self.resonicButton setSelected:self.sonic.isResonicedByMe];
    [self.likeButton setSelected:self.sonic.isLikedByMe];
    self.likesCountLabel.text = [NSString stringWithFormat:@"%d %@",self.sonic.likeCount,LikesText];
    self.commentsCountLabel.text = [NSString stringWithFormat:@"%d %@",self.sonic.commentCount,CommentsText];
    self.resonicsCountLabel.text = [NSString stringWithFormat:@"%d %@",self.sonic.resonicCount,ResonicsText];
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



@end
