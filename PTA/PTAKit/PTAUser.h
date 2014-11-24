//
//  PTAUser.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PTAUser : NSObject

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *expireDate;

+ (PTAUser *) userFromHTML: (NSString *)htmlString;

@end
