//
//  PTAUser.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTAUser.h"
#import <OCGumbo/OCGumbo.h>
#import <OCGumbo/OCGumbo+Query.h>
#import "NSString+RegexAddition.h"

@implementation PTAUser
+ (PTAUser *) userFromHTML: (NSString *)htmlString
{
    OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString: htmlString];

    OCGumboNode *userELement = document.Query(@"#user-id").first();
    OCGumboNode *dateElement = document.Query(@"#pta-days").first();
    if (!userELement || !dateElement) return nil;

    NSString *nameInnerText = userELement.text();
    NSString *dateInnerText = dateElement.text();

    // Extract the actual data from html string.
    NSString *name = [nameInnerText firstSubstringMatchesPattern: @"[A-Z]\\d+"];
    NSString *date = [dateInnerText firstSubstringMatchesPattern: @"\\d+\\.\\d+\\.\\d+"];
    
    if (!date || !name) return nil;
    
    PTAUser *user = [PTAUser new];
    user.userID = name;
    user.expireDate = date;
    return user;
}

- (NSString *) description
{
    return [NSString stringWithFormat: @"PTAUser(%@, %@)", self.userID, self.expireDate];
}
@end
