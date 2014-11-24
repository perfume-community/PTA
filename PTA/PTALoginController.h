//
//  PTALoginController.h
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RACSignal;
@interface PTALoginController : UITableViewController <UITextFieldDelegate>

+ (RACSignal *) showLoginWithViewController: (UIViewController *)vc;
@end
