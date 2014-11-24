//
//  PTAArticle.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTAArticle.h"
#import <OCGumbo/OCGumbo.h>
#import <OCGumbo/OCGumbo+Query.h>
#import "NSString+RegexAddition.h"

static NSString *categoryName(PTAArticleCategory category)
{
    switch (category) {
        case FCNews:
            return @"News";
        case BlogAchan:
            return @"あ〜ちゃん";
        case BlogKashiyuka:
            return @"かしゆか";
        case BlogNocchi:
            return @"のっち";
        case BlogStaff:
            return @"Staff";
        default:
            return @"";
    }
}

@implementation PTAArticle

+ (NSArray *) memberBlogArticlesFromHTML: (NSString *)htmlString
{
    NSMutableArray *resultArray = [NSMutableArray new];
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString: htmlString];
    
    for (OCGumboElement *articleElement in document.Query(@"div.article")) {
        PTAArticle *article = [PTAArticle new];
        article.innerHTML = articleElement.html();
        
#define GetText(e) (e ? e.text() : nil)
#define GetHtml(e) (e ? e.html() : nil)
        
        article.title = GetText(articleElement.Query(@".article-title").first());
        article.date = GetText(articleElement.Query(@".article-time").first());
        
        NSDictionary *categoryMap = @{@"あ～ちゃん": @(BlogAchan), @"かしゆか": @(BlogKashiyuka), @"のっち": @(BlogNocchi)};
        NSString *rawCategory = GetText(articleElement.Query(@".article-category").first());
        
        article.category = [[categoryMap objectForKey: rawCategory] intValue];
        OCGumboNode *bodyDiv = articleElement.Query(@"div").first();
        article.bodyHTML = GetHtml(bodyDiv);
        article.bodyText = GetText(bodyDiv);
        if (article.title == nil && article.date == nil) continue;
        [resultArray addObject: article];
    }
    return resultArray;
}

+ (NSArray *) archivedMemberBlogArticlesFromHTML: (NSString *)htmlString
{
    NSMutableArray *resultArray = [NSMutableArray new];
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString: htmlString];

    for (OCGumboElement *articleElement in document.Query(@"div.day")) {
        PTAArticle *article = [PTAArticle new];
        article.innerHTML = articleElement.html();
        
        if ([articleElement.attr(@"class") rangeOfString: @"member-47"].location != NSNotFound) {
            article.category = BlogNocchi;
        } else if ([articleElement.attr(@"class") rangeOfString: @"member-46"].location != NSNotFound) {
            article.category = BlogKashiyuka;
        } else if ([articleElement.attr(@"class") rangeOfString: @"member-45"].location != NSNotFound) {
            article.category = BlogAchan;
        }
        
        article.title = GetText(articleElement.Query(@"h3").first());
        article.date = [GetText(articleElement.Query(@"h4").first()) firstSubstringMatchesPattern: @"\\d+\\.\\d+\\.\\d+"];
        article.bodyHTML = GetHtml(articleElement.Query(@"div.itembody").first());
        [resultArray addObject: article];
    }
    return resultArray;
}

+ (NSArray *) staffBlogArticlesFromHTML: (NSString *)htmlString
{
    NSArray *results = [PTAArticle memberBlogArticlesFromHTML: htmlString];
    for (PTAArticle *a in results) {
        a.category = BlogStaff;
    }
    return results;
}

+ (NSArray *) archivedStaffBlogArticlesFromHTML: (NSString *)htmlString
{
    NSArray *results = [PTAArticle archivedMemberBlogArticlesFromHTML: htmlString];
    for (PTAArticle *a in results) {
        a.category = BlogStaff;
    }
    return results;
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"PTAArticle(%@, %@, %@)", self.title, self.date, categoryName(self.category)];
}
@end
