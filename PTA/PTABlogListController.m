//
//  PTABlogListController.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTABlogListController.h"
#import "PTAKit.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PTALoginController.h"
#import "PTABlogCell.h"
#import <OCGumbo/OCGumbo.h>
#import <OCGumbo/OCGumbo+Query.h>
#import <NSCollectionAddition/NSCollectionAddition.h>

static NSString *BlogCellIdentifier = @"BlogCellIdentifier";

@interface PTABlogListController ()
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSArray *searchResult;
@end

@implementation PTABlogListController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Blog", nil);
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController: nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    self.searchController.searchBar.clipsToBounds = YES;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    [self.tableView registerClass: [PTABlogCell class] forCellReuseIdentifier: BlogCellIdentifier];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewDidAppear: (BOOL)animated
{
    [self fetchPage: @1];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) fetchPage: (NSNumber *)number
{
    RACSignal *s = [[PTASite sharedSite] memberBlogArticlesWithPage: number];
    RACSignal *recovered = [[s catch: ^(NSError *error) {
        if (error.domain == kPTAErrorDomain && error.code == PTAAuthRequired) {
            return [[[PTASite sharedSite] login] flattenMap: ^(id x) {
                return [[PTASite sharedSite] memberBlogArticlesWithPage: number];
            }];
        } else {
            return [RACSubject error: error];
        }
    }] catch: ^(NSError *error) {
        if (error.domain == kPTAErrorDomain && error.code == PTANoStoredPassword) {
            return [[PTALoginController showLoginWithViewController: self] flattenMap: ^(id x) {
                return [[PTASite sharedSite] memberBlogArticlesWithPage: number];
            }];
        } else {
            return [RACSubject error: error];
        }
    }];
    
    [recovered subscribeNext:^(PTAPagination *page) {
        self.entries = [(self.entries ?: @[]) arrayByAddingObjectsFromArray: page.items];
        [self.tableView reloadData];
        
        if (page.nextPage) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self fetchPage: page.nextPage];
            });
        }
    } error: ^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    if (self.searchResult)
        return self.searchResult.count;
    return self.entries.count;
}


- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    PTABlogCell *cell = [tableView dequeueReusableCellWithIdentifier: BlogCellIdentifier forIndexPath:indexPath];
    PTAArticle *article = self.searchResult ? self.searchResult[indexPath.item] : self.entries[indexPath.item];
    cell.titleLabel.text = article.title;
    cell.dateLabel.text = article.date;
    cell.thumbnailView.image = nil;

    if (article.category == BlogAchan)
        cell.thumbnailView.image = [UIImage imageNamed: @"Acchan"];
    else if (article.category == BlogKashiyuka)
        cell.thumbnailView.image = [UIImage imageNamed: @"Kashiyuka"];
    else if (article.category == BlogNocchi)
        cell.thumbnailView.image = [UIImage imageNamed: @"Nocchi"];
    
    cell.summaryLabel.text = [[[article.bodyText componentsSeparatedByString: @"\n"] componentsJoinedByString: @" "] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [cell mosaic];
    return cell;
}

- (CGFloat) tableView: (UITableView *)tableView heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
    return 90;
}

#pragma mark - UISearchControllerDelegate
- (void) didPresentSearchController: (UISearchController *)searchController
{
    self.searchResult = self.entries;
}

- (void) didDismissSearchController: (UISearchController *)searchController
{
    self.searchResult = nil;
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating
- (void) updateSearchResultsForSearchController: (UISearchController *)searchController
{
    NSString *searchTerm = searchController.searchBar.text;
    self.searchResult = [self.entries filter: ^(PTAArticle *a) {
        return [a.innerHTML containsString: searchTerm];
    }];
    [self.tableView reloadData];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
