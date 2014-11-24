//
//  PTAArticle.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FCNews = 1,
    BlogAchan,
    BlogKashiyuka,
    BlogNocchi,
    BlogStaff
} PTAArticleCategory;

@interface PTAArticle : NSObject
@property (nonatomic, retain) NSString *title;

/** Should be in yyyy.MM.dd format. */
@property (nonatomic, retain) NSString *date;
@property (nonatomic) PTAArticleCategory category;

/** Whole HTML of the article. Includes title, date, category. */
@property (nonatomic, strong) NSString *innerHTML;

/** Only the body part of the article. */
@property (nonatomic, strong) NSString *bodyHTML;
@property (nonatomic, strong) NSString *bodyText;
@property (nonatomic, strong) NSString *digest;

+ (NSArray *) memberBlogArticlesFromHTML: (NSString *)htmlString;
+ (NSArray *) archivedMemberBlogArticlesFromHTML: (NSString *)htmlString;
+ (NSArray *) staffBlogArticlesFromHTML: (NSString *)htmlString;
+ (NSArray *) archivedStaffBlogArticlesFromHTML: (NSString *)htmlString;

@end
