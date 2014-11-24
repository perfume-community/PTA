//
//  PTABlogCell.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/25/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTABlogCell.h"

#define USE_MOSAIC 0

@interface PTABlogCell ()
@property (nonatomic, strong) UIImageView *titleMosaic;
@property (nonatomic, strong) UIImageView *summaryMosaic;
@end

@implementation PTABlogCell

- (id) initWithStyle: (UITableViewCellStyle)style reuseIdentifier: (NSString *)reuseIdentifier
{
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self configureView];
    }
    return self;
}

- (void) awakeFromNib
{
    [self configureView];
}

- (void) configureView
{
    CGFloat iconPaddingX = 5;
    CGFloat iconPaddingY = 20;
    CGFloat iconW = 55;
    CGFloat iconH = 45;
    CGFloat dateW = 90;
    CGFloat titleH = 20;
    CGFloat titlePaddingY = 6;
    if (!self.thumbnailView) {
        self.thumbnailView = [[UIImageView alloc] initWithFrame: CGRectMake(iconPaddingX, iconPaddingY, iconW, iconH)];
        self.thumbnailView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview: self.thumbnailView];
    }
    
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(iconW + 2 * iconPaddingX, titlePaddingY, self.contentView.frame.size.width - iconW - 2 * iconPaddingX - dateW, titleH)];
        self.titleLabel.font = [UIFont boldSystemFontOfSize: 17];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview: self.titleLabel];
    }
    
    if (!self.dateLabel) {
        self.dateLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.contentView.frame.size.width - dateW, titlePaddingY, dateW, titleH)];
        self.dateLabel.font = [UIFont systemFontOfSize: 15];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.contentView addSubview: self.dateLabel];
    }
    
    if (!self.summaryLabel) {
        self.summaryLabel = [[UILabel alloc] initWithFrame: CGRectMake(iconW + 2 * iconPaddingX, titlePaddingY + titleH, self.contentView.frame.size.width - iconW - 2 * iconPaddingX - 10, self.contentView.frame.size.height - titlePaddingY - titleH - 6)];
        self.summaryLabel.numberOfLines = 0;
        self.summaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.summaryLabel.textAlignment = NSTextAlignmentLeft;
        self.summaryLabel.font = [UIFont systemFontOfSize: 15];
        self.summaryLabel.textColor = [UIColor colorWithWhite: 0.6 alpha: 1.0];
#if USE_MOSAIC
        self.summaryLabel.textColor = [UIColor colorWithWhite: 0.2 alpha: 1.0];
#endif
        self.summaryLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview: self.summaryLabel];
    }
}

- (void) mosaic
{
#if USE_MOSAIC
    self.titleLabel.hidden = NO;
    self.summaryLabel.hidden = NO;

    void (^createMosaic)(UIView *, UIImageView **) = ^(UIView *view, UIImageView **mosaicView) {
        view.hidden = NO;
        UIGraphicsBeginImageContext(view.bounds.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        [view.layer renderInContext: ctx];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CIFilter *blur = [CIFilter filterWithName: @"CIGaussianBlur"];
        [blur setDefaults];
        [blur setValue: @3 forKey:@"inputRadius"];
        [blur setValue:  [CIImage imageWithCGImage: image.CGImage] forKey: @"inputImage"];
        
        CIFilter *pixellate = [CIFilter filterWithName: @"CIPixellate"];
        [pixellate setDefaults];
        [pixellate setValue: @8 forKey:@"inputScale"];
        [pixellate setValue:  blur.outputImage forKey: @"inputImage"];

        CIImage *outputImage = pixellate.outputImage;
        
        if (!*mosaicView) {
            *mosaicView = [[UIImageView alloc] initWithFrame: view.frame];
            (*mosaicView).autoresizingMask = view.autoresizingMask;
            [self.contentView addSubview: *mosaicView];
        }

        CIContext *context = [CIContext contextWithOptions: nil];
        CGImageRef cg = [context createCGImage: outputImage fromRect: [outputImage extent]];
        UIImage *newImage = [UIImage imageWithCGImage: cg];
        CGImageRelease(cg);
        
        (*mosaicView).image = newImage;
        view.hidden = YES;
    };
    
    UIImageView *mosaicView = self.titleMosaic;
    createMosaic(self.titleLabel, &mosaicView);
    self.titleMosaic = mosaicView;
    
    mosaicView = self.summaryMosaic;
    createMosaic(self.summaryLabel, &mosaicView);
    self.summaryMosaic = mosaicView;
#endif
}

- (void) setSelected: (BOOL)selected animated: (BOOL)animated
{
    [super setSelected: selected animated: animated];
}

@end
