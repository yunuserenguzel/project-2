//
//  SNCFollowerFollowingViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/5/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCFollowerFollowingViewController.h"
#import "SNCPersonTableCell.h"

@interface SNCFollowerFollowingViewController ()

@end

@implementation SNCFollowerFollowingViewController


- (CGRect) tableViewFrame
{
    CGRect frame = self.view.frame;
    frame.origin.y = [self segmentedControlFrame].origin.y + [self segmentedControlFrame].size.height + 5.0;
    frame.size.height -= frame.origin.y;
    return frame;
}

- (CGRect) segmentedControlFrame
{
    CGFloat y = self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height + 6;
    return CGRectMake(70.0, y, 180.0, 33.0);
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
    
    [self initializeTableView];
    [self initializeSegmentedControl];
}

- (void) initializeTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:[self tableViewFrame]];
    [self.view addSubview:self.tableView];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[SNCPersonTableCell class] forCellReuseIdentifier:@"Cell"];
}

- (void) initializeSegmentedControl
{
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Followers",@"Followings"]];
    [self.segmentedControl setFrame:[self segmentedControlFrame]];
    [self.view addSubview:self.segmentedControl];
    [self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventTouchUpInside];
    [self.segmentedControl setSelectedSegmentIndex:0];
}

- (void) segmentChanged:(UISegmentedControl*)segmentedControl
{
    if([segmentedControl selectedSegmentIndex] == 0){
        
    } else if([segmentedControl selectedSegmentIndex] == 1){
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCPersonTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [cell setUser:nil];
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
