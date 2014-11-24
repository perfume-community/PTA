//
//  PTABlogCell.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/25/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PTABlogCell : UITableViewCell
@property (nonatomic, strong) UIImageView *thumbnailView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *dateLabel;

- (void) mosaic;
@end
