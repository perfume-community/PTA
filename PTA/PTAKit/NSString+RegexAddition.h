//
//  NSString+RegexAddition.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegexAddition)
/**
 * @return nil if no match, otherwise the matched substring.
 */
- (NSString *) firstSubstringMatchesPattern: (NSString *)pattern;
@end
