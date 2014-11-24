//
//  PTATableInputCell.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTATableInputCell.h"

@implementation PTATableInputCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self prepareForReuse];
    }
    return self;
}

- (void) awakeFromNib
{
    [self prepareForReuse];
}

- (void) prepareForReuse
{
    [super prepareForReuse];
    const CGFloat labelWidth = 130;
    if (!self.label) {
        self.label = [[UILabel alloc] initWithFrame: CGRectMake(0, 7, labelWidth, 30)];
        self.label.textAlignment = NSTextAlignmentRight;
        self.label.font = [UIFont boldSystemFontOfSize: 17];
        [self.contentView addSubview: self.label];
    }
    if (!self.field) {
        self.field = [[UITextField alloc] initWithFrame: CGRectMake(labelWidth + 10, 7, self.contentView.bounds.size.width - labelWidth - 10, 30)];
        self.field.borderStyle = UITextBorderStyleNone;
        self.field.font = [UIFont systemFontOfSize: 17];
        self.field.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview: self.field];
    }
}

- (void) setSelected: (BOOL)selected animated: (BOOL)animated
{

}

@end
