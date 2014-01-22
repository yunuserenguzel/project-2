//
//  SNCSearchViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 1/22/14.
//  Copyright (c) 2014 Yunus Eren Guzel. All rights reserved.
//

#import "SNCSearchViewController.h"
#import "SNCPersonTableCell.h"
#import "SNCAPIManager.h"

@interface SNCSearchViewController ()

@property NSArray* users;
@end

@implementation SNCSearchViewController
{
    UIActivityIndicatorView* activityView;
}
- (CGRect) searchFieldFrame
{
    return CGRectMake(0.0, 0.0, 240.0, 22.0);
}

- (CGRect) contentRect
{
    CGFloat h = self.view.frame.size.height  - self.tabBarController.tabBar.frame.size.height;
    return CGRectMake(0.0, 0.0, 320.0, h);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) search
{
    if(activityView == nil){
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView startAnimating];
    [SNCAPIManager getUsersWithSearchQuery:self.searchField.text withCompletionBlock:^(NSArray *users) {
        [activityView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.searchButton;
        self.users = users;
        [self.userTableView reloadData];
    } andErrorBlock:^(NSError *error) {
        [activityView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.searchButton;
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.users = @[];
    [self initUserTableView];
    [self initSearchInstruments];
}

- (void) initUserTableView
{
    self.userTableView = [[UITableView alloc] initWithFrame:[self contentRect] style:UITableViewStylePlain];
    [self.view addSubview:self.userTableView];
    [self.userTableView registerClass:[SNCPersonFollowableTableCell class] forCellReuseIdentifier:@"PersonCell"];
    self.userTableView.delegate = self;
    self.userTableView.dataSource = self;
}

- (void) initSearchInstruments
{
    self.searchField = [[UITextField alloc] initWithFrame:[self searchFieldFrame]];
    self.searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 22.0)];
    self.searchField.font = [self.searchField.font fontWithSize:14.0];
    self.searchField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchField.layer.borderColor = rgb(200, 200, 200).CGColor;
    self.searchField.layer.borderWidth = 1.0;
    self.searchField.layer.cornerRadius = 5.0;
    self.searchField.keyboardType = UIKeyboardTypeAlphabet;
    self.navigationItem.titleView = self.searchField;
    
    self.searchButton = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStyleBordered target:self action:@selector(search)];
    self.navigationItem.rightBarButtonItem = self.searchButton;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNCPersonFollowableTableCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PersonCell"];
    [cell setUser:[self.users objectAtIndex:indexPath.row]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.users ? self.users.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
