//
//  PTASite.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTASite.h"
#import <STHTTPRequest/STHTTPRequest.h>
#import <OCGumbo/OCGumbo.h>
#import <OCGumbo/OCGumbo+Query.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <NSURL+QueryDictionary/NSURL+QueryDictionary.h>
#import <SSKeychain/SSKeychain.h>
#import "PTAUser.h"
#import "PTAArticle.h"

@implementation PTAPagination
+ (instancetype) pageWithNextPage: (NSNumber *)nextPage items: (NSArray *)items
{
    return [[PTAPagination alloc] initWithNextPage: nextPage items: items];
}

- (instancetype) initWithNextPage: (NSNumber *)nextPage items: (NSArray *)items
{
    self = [super init];
    if (self) {
        self.nextPage = nextPage;
        self.items = items;
    }
    return self;
}

@end


static NSString *kPTAServiceName = @"PTA";

@implementation PTASite

+ (PTASite *) sharedSite
{
    static PTASite *sharedSite = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSite = [PTASite new];
    });
    return sharedSite;
}

- (RACSignal *) login
{
    if (!self.loginUser) {
        RACSubject *s = [RACReplaySubject subject];
        [s sendError: [NSError errorWithDomain: kPTAErrorDomain code: PTANoStoredPassword userInfo: @{NSLocalizedDescriptionKey: NSLocalizedString(@"No password stored in keychain for given username.", nil)}]];
        return s;
    }
    return [self loginWithUsername: self.loginUser.userID];
}

- (RACSignal *) loginWithUsername:(NSString *)username
{
    NSString *password = [SSKeychain passwordForService: kPTAServiceName account: username];
    if (!password) {
        RACSubject *s = [RACReplaySubject subject];
        [s sendError: [NSError errorWithDomain: kPTAErrorDomain code: PTANoStoredPassword userInfo: @{NSLocalizedDescriptionKey: NSLocalizedString(@"No password stored in keychain for given username.", nil)}]];
        return s;
    }
    
    return [self loginWithUsername: username password: password];
}

- (RACSignal *) loginWithUsername: (NSString *)username password: (NSString *)password
{
    RACSubject *s = [RACSubject subject];
    
    STHTTPRequest *req = [STHTTPRequest requestWithURLString: @"http://www.perfume-web.jp/pta/login/"];
    req.POSTDictionary = @{@"id": username, @"pass": password, @"submit_login": @"LOGIN"};
    req.HTTPMethod = @"POST";
    req.completionBlock = ^(NSDictionary *header, NSString *body) {
        PTAUser *user = [PTAUser userFromHTML: body];
        if (user) {
            // save username / password to keychain
            [SSKeychain setPassword: password forService: kPTAServiceName account: username];
            self.loginUser = user;
            
            [s sendNext: user];
            [s sendCompleted];
        } else {
            [s sendError: [NSError errorWithDomain: kPTAErrorDomain code: PTALoginError userInfo: @{NSLocalizedDescriptionKey: NSLocalizedString(@"Account or password incorrect.", nil)}]];
        }
    };
    req.errorBlock = ^(NSError *error) {
        [s sendError: error];
    };
    [req startAsynchronous];
    return s;
}

- (RACSignal *) memberBlogArticlesWithPage: (NSNumber *)page
{
    RACSubject *s = [RACSubject subject];
    STHTTPRequest *req = [STHTTPRequest requestWithURLString: [NSString stringWithFormat: @"http://www.perfume-web.jp/pta/blog/?page=%@", page ?: @1]];
    req.preventRedirections = YES;
    
    __block STHTTPRequest *r = req;
    
    req.completionBlock = ^(NSDictionary *header, NSString *body) {
        if (r.responseStatus == 302) {
            [s sendError: [NSError errorWithDomain: kPTAErrorDomain code: PTAAuthRequired userInfo: @{NSLocalizedDescriptionKey: NSLocalizedString(@"Authentication required. Maybe the session is timeout.", nil)}]];
        } else {
            NSArray *blogs = [PTAArticle memberBlogArticlesFromHTML: body];
            
            OCGumboDocument *document = [[OCGumboDocument alloc] initWithHTMLString: body];
    #define GetAttr(e, a) (e ? e.attr(a) : nil)
            NSString *nextURL = GetAttr(document.Query(@"#pagination-next").find(@"a").first(), @"href");
            
            NSString *nextPageString = [[[NSURL URLWithString: nextURL] uq_queryDictionary] objectForKey: @"page"];
            NSNumber *nextPage = (nextPageString.length > 0) ? @(nextPageString.intValue) : nil;

            [s sendNext: [PTAPagination pageWithNextPage: nextPage items: blogs]];
            [s sendCompleted];
        }
    };
    req.errorBlock = ^(NSError *error) {
        [s sendError: error];
    };
    [req startAsynchronous];
    return s;
}

@end
