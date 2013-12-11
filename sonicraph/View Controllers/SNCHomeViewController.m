//
//  SNCHomeViewController.m
//  sonicraph
//
//  Created by Yunus Eren Guzel on 11/12/13.
//  Copyright (c) 2013 Yunus Eren Guzel. All rights reserved.
//

#import "SNCHomeViewController.h"
#import "SNCHomeTableCell.h"
#import "TypeDefs.h"
#import "Sonic.h"

#define HeightForHomeCell 424.0

@interface SNCHomeViewController ()
@property NSArray* sonics;
@end

@implementation SNCHomeViewController
{
    SNCHomeTableCell* cellWiningTheCenter;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView registerClass:[SNCHomeTableCell class] forCellReuseIdentifier:HomeTableCellIdentifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:NotificationSonicsAreLoaded
                                               object:nil];
    
    self.sonics  = @[];
}

- (void) refresh
{
    self.sonics = [Sonic getFrom:10 to:20];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.sonics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = HomeTableCellIdentifier;
    SNCHomeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Sonic* sonic = [self.sonics objectAtIndex:indexPath.row];
    if(sonic != cell.sonic){
        [cell setSonic:[self.sonics objectAtIndex:indexPath.row]];
    }
    
    // Configure the cell...

    return cell;
}

- (void) autoPlay:(UIScrollView*)scrollView
{
    CGFloat x = self.tableView.contentOffset.x;
    CGFloat y = self.tableView.contentOffset.y + self.tableView.frame.size.height * 0.5;
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = HeightForHomeCell * 0.4;
    y -= height * 0.5;
    CGRect rect = CGRectMake(x, y, width, height);
    
    NSArray* indexPaths = [self.tableView indexPathsForRowsInRect:rect];
    if([indexPaths count] == 1){
        cellWiningTheCenter = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:[indexPaths objectAtIndex:0]];
        [cellWiningTheCenter cellWonCenterOfTableView];
    }
    else {
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath* indexPath, NSUInteger idx, BOOL *stop) {
            SNCHomeTableCell* cell = (SNCHomeTableCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell cellLostCenterOfTableView];
        }];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [cellWiningTheCenter cellLostCenterOfTableView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate){
        [self autoPlay:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self autoPlay:scrollView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HeightForHomeCell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
