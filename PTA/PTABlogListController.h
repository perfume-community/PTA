//
//  PTABlogListController.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTABlogListController : UITableViewController <UISearchControllerDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) NSArray *entries;
@end
