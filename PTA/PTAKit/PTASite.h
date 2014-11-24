//
//  PTASite.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kPTAErrorDomain = @"PTAErrorDomain";
typedef NS_ENUM(NSInteger, PTAErrorCode) {
    PTALoginError,
    PTAAuthRequired,
    PTANoStoredPassword,
    PTAUserCanceledLogin
};

@interface PTAPagination : NSObject
@property (nonatomic, strong) NSNumber *nextPage;
@property (nonatomic, strong) NSArray *items;

+ (instancetype) pageWithNextPage: (NSNumber *)nextPage items: (NSArray *)items;
- (instancetype) initWithNextPage: (NSNumber *)nextPage items: (NSArray *)items;
@end

@class RACSignal;
@class UIViewController;
@class PTAUser;

@interface PTASite : NSObject

+ (PTASite *) sharedSite;

@property (nonatomic, strong) PTAUser *loginUser;

/**
 * Login with username/password.
 * @param username PTA login, should begin with capital 'P' followed by numbers
 * @param password
 * @return RACSignal of PTAUser
 */
- (RACSignal *) loginWithUsername: (NSString *)username password: (NSString *)password;
- (RACSignal *) loginWithUsername: (NSString *)username;
- (RACSignal *) login;

/**
 * Fetch the member blog article.
 * @param page Starts from 1.
 * @return RACSignal of PTAPagination of PTAArticle
 */
- (RACSignal *) memberBlogArticlesWithPage: (NSNumber *)page;
@end
