//
//  SNCProfileViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/8/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCProfileViewController.h"
#import "SNCAPIManager.h"
#import "SNCEditViewController.h"
#import "SonicData.h"
#import "Sonic.h"


@interface SNCProfileViewController ()

@property NSArray* sonics;

@end

@implementation SNCProfileViewController
{
    Sonic* selectedSonic;
}

- (CGRect) sonicCollectionViewFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height - y;
    return CGRectMake(0.0, y, 320.0, h);
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
    [self initializeSonicCollectionView];
    // Do any additional setup after loading the view.
    
}

- (void) setUser:(UserManagedObject *)user
{
    _user = user;
    [SNCAPIManager getUserSonics:self.user withCompletionBlock:^(NSArray *sonics) {
        
    }];
}


- (void) initializeSonicCollectionView
{
    self.sonicCollectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [self.sonicCollectionViewFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.sonicCollectionViewFlowLayout setItemSize:CGSizeMake(160.0, 160.0)];
    [self.sonicCollectionViewFlowLayout setMinimumLineSpacing:1.0];
    [self.sonicCollectionViewFlowLayout setMinimumInteritemSpacing:0.0];
    self.sonicCollectionView = [[UICollectionView alloc] initWithFrame:[self sonicCollectionViewFrame] collectionViewLayout:self.sonicCollectionViewFlowLayout];
    [self.sonicCollectionView setDataSource:self];
    [self.sonicCollectionView setDelegate:self];
    [self.sonicCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
	[self.view addSubview:self.sonicCollectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NotificationSonicsAreLoaded
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:nil
                                                  object:nil];
}

- (void) refresh
{   
    self.sonics = [Sonic getFrom:0 to:20];
    [self.sonicCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
//    UIImageView* imageView = [[UIImageView alloc] initWithImage:[sonicManagedObject getImage]];
    UIImageView* imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(0.0, 0.0, cell.frame.size.width, cell.frame.size.height);
    [imageView setUserInteractionEnabled:NO];
    NSURL*  url = [NSURL URLWithString:[sonic sonicUrl]];
    [SNCAPIManager getSonic:url withSonicBlock:^(SonicData *sonic, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = sonic.image;
        });
    }];
    
    [cell addSubview:imageView];
    
    
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(self.sonics)
        return self.sonics.count;
    else
        return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath.row: %d",indexPath.row);
    selectedSonic = [self.sonics objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:ProfileToPreviewSegue sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:ProfileToPreviewSegue]){
//        SNCEditViewController* preview = segue.destinationViewController;
//        [preview setSonic:selectedSonic.sonicData];
    }
}

@end
