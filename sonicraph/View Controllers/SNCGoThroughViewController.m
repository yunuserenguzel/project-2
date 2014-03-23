//
//  SNCGoThroughViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 18/03/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCGoThroughViewController.h"
#import "SNCPageContentViewController.h"
#import "SNCLoginViewController.h"
#import "SNCRegisterViewController.h"
#import "SMPageControl.h"
#import "SNCGetStartedPageContentViewController.h"

#import "UIButton+StateProperties.h"
#import "Configurations.h"

UIView* textFieldWithBaseAndLabel(UITextField* textField)
{
    UIView* base = [[UIView alloc] initWithFrame:CGRectMake(textField.frame.origin.x, textField.frame.origin.y, textField.frame.size.width, textField.frame.size.height)];
    [base setUserInteractionEnabled:YES];
    [base setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3]];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 0.0, 90.0, textField.frame.size.height)];
    [label setFont:[UIFont boldSystemFontOfSize:18.0]];
    [label setTextColor:[UIColor whiteColor]];
    [label setText:textField.placeholder];
    textField.placeholder = @"";
    [textField setTintColor:[UIColor whiteColor]];
    [textField setTextAlignment:NSTextAlignmentLeft];
    [textField setFrame:CGRectMake(126.0, 0.0, textField.frame.size.width - 126.0, textField.frame.size.height)];
    [textField setTextColor:[UIColor whiteColor]];
    [textField setRightView:[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 10.0, 44.0)]];
    [textField setRightViewMode:UITextFieldViewModeAlways];
    [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    
    [base addSubview:label];
    [base addSubview:textField];

    return base;
}


@interface SNCGoThroughViewController () <UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property NSArray* contentViewControllers;

@property UIButton* loginButton;

@property SNCLoginViewController* loginViewController;
@property SNCRegisterViewController* registerViewController;
@property UIButton* registerButton;

@property SMPageControl* pageControl;

@end

@implementation SNCGoThroughViewController
{
    NSInteger currentIndex;
}

- (CGRect) registerButtonFrame
{
    return CGRectMake(10.0, self.view.frame.size.height-50.0, 300, 50.0);
}

- (CGRect) pageControlFrame
{
    return CGRectMake(0.0, self.view.frame.size.height-130.0, 320.0,22.0);
}

+ (SNCGoThroughViewController *)create
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:
                          [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMin]
                                                     forKey: UIPageViewControllerOptionSpineLocationKey];
    return [[SNCGoThroughViewController alloc]
            initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
            options:options];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIView* indicator = [self.view.subviews objectAtIndex:0];
    [indicator setFrame:CGRectMake(indicator.frame.origin.x, self.view.frame.size.height - 150.0, indicator.frame.size.width, indicator.frame.size.height)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gothroughbackground.png"]];
    [imageView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    [imageView setContentMode:UIViewContentModeCenter];
    [self.view insertSubview:imageView atIndex:0];
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height-100.0, 320.0, 44.0)];
    [self.loginButton setBackgroundImageWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Log in" forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
    [self.loginButton addTarget:self action:@selector(showLoginViewController) forControlEvents:UIControlEventTouchUpInside];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.registerButton.frame = [self registerButtonFrame];
    [self.registerButton setTitle:@"Not yet registered? Sign up" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(openRegister) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.registerButton];
    
    self.pageControl = [[SMPageControl alloc] initWithFrame:[self pageControlFrame]];
    [self.pageControl setNumberOfPages:4];
    [self.pageControl setCurrentPage:0];
    [self.pageControl setIndicatorDiameter:10.0];
    [self.view addSubview:self.pageControl];
    [self hidePageControl];
    
    self.dataSource = self;
    self.delegate = self;
    // Do any additional setup after loading the view.
    
    self.loginViewController = [[SNCLoginViewController alloc] init];
    self.contentViewControllers = @[
                                    [[SNCGetStartedPageContentViewController alloc] initWithUIImage:[UIImage imageNamed:@"gothroughstep_0.png"]],
                                    [[SNCPageContentViewController alloc] initWithUIImage:[UIImage imageNamed:@"gothroughstep_1.png"]],
                                    [[SNCPageContentViewController alloc] initWithUIImage:[UIImage imageNamed:@"gothroughstep_2.png"]],
                                    [[SNCPageContentViewController alloc] initWithUIImage:[UIImage imageNamed:@"gothroughstep_3.png"]],
                                    [[SNCPageContentViewController alloc] initWithUIImage:[UIImage imageNamed:@"gothroughstep_4.png"]]
                                 ];
    [self setViewControllers:[NSArray arrayWithObject:[self.contentViewControllers objectAtIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        
    }];
}

- (void)startGoThrough
{
    [self showViewController:[self.contentViewControllers objectAtIndex:1] direction:UIPageViewControllerNavigationDirectionForward];
    [self.pageControl setCurrentPage:0];
    [self showPageControl];
}

- (void) openRegister
{
    [self hideLoginButton];
    [self hideRegisterButton];
    [self hidePageControl];
    [self showRegisterViewController];
}
- (void) showRegisterViewController
{
    if(self.registerViewController == nil)
    {
        self.registerViewController = [[SNCRegisterViewController alloc] init];
    }
    [self showViewController:self.registerViewController direction:UIPageViewControllerNavigationDirectionReverse];
}

- (void) showLoginButton
{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }];
}

- (void) hideLoginButton
{
    [UIView animateWithDuration:0.3 animations:^{
        self.loginButton.transform = CGAffineTransformMakeTranslation(0.0, 200);
    }];
}
- (void) showRegisterButton
{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.registerButton.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }];
}

- (void) hideRegisterButton
{
    [UIView animateWithDuration:0.3 animations:^{
        self.registerButton.transform = CGAffineTransformMakeTranslation(0.0, 200);
    }];
}
-(void) showPageControl
{
    [UIView animateWithDuration:0.1 animations:^{
        self.pageControl.alpha = 1.0;
    }];
}

- (void) hidePageControl
{
    [UIView animateWithDuration:0.1 animations:^{
        self.pageControl.alpha = 0.0;
    }];
}

- (void) showLoginViewController
{
    [self hideLoginButton];
    [self showRegisterButton];
    [self hidePageControl];
    [self showViewController:self.loginViewController direction:UIPageViewControllerNavigationDirectionForward];
   
}

- (void) showViewController:(UIViewController*)viewController direction:(UIPageViewControllerNavigationDirection)direction
{
    __block SNCGoThroughViewController *blocksafeSelf = self;
    [self setViewControllers:@[viewController] direction:direction animated:YES completion:^(BOOL finished){
        if(finished)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [blocksafeSelf setViewControllers:@[viewController] direction:direction animated:NO completion:NULL];// bug fix for uipageview controller
            });
        }
    }];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    for(int i=0;i<self.contentViewControllers.count ;i++)
    {
        if(viewController == [self.contentViewControllers objectAtIndex:i])
        {
            if(i+1 < self.contentViewControllers.count)
            {
                return [self.contentViewControllers objectAtIndex:i+1];
            }
        }
    }
    return nil;
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    
    for(int i=0;i<self.contentViewControllers.count ;i++)
    {
        if(viewController == [self.contentViewControllers objectAtIndex:i])
        {
            if(i-1 >= 0)
            {
                return [self.contentViewControllers objectAtIndex:i-1];
            }
        }
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    UIViewController* viewController = [pendingViewControllers objectAtIndex:0];
    if(viewController == self.loginViewController || viewController == self.registerViewController)
    {
        [self hideLoginButton];
        [self hidePageControl];
    }
    else
    {
        [self showLoginButton];
    }
    NSInteger index = [self.contentViewControllers indexOfObject:viewController];
    index--;
    if(index < 0)
    {
        [self hidePageControl];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    UIViewController* viewController = [self.viewControllers objectAtIndex:0];
    if(viewController == self.loginViewController || viewController == self.registerViewController)
    {
        [self hideLoginButton];
        [self hidePageControl];
    }
    else
    {
        [self showLoginButton];
    }
    NSInteger index = [self.contentViewControllers indexOfObject:viewController];
    index--;
    if(index >= 0)
    {
        [self showPageControl];
        [self.pageControl setCurrentPage:index];
    }
    else
    {
        [self hidePageControl];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
