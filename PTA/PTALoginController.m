//
//  PTALoginController.m
//  PTA
//
//  Created by Yung-Luen Lan on 11/24/14.
//  Copyright (c) 2014 Perfume Community. All rights reserved.
//

#import "PTALoginController.h"
#import "PTAKit.h"
#import "PTATableInputCell.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MBProgressHUD/MBProgressHUD.h>

static NSString *InputReuseIdentifier = @"InputCell";
static const int kMaxAccountLength = 7;

enum {
    UsernameField = 0,
    PasswordField,
    FieldCount
};

@interface PTALoginController ()
@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) RACSubject *usernameSubject;
@property (nonatomic, strong) RACSubject *passwordSubject;
@property (nonatomic, strong) RACSubject *resultSubject;
@end

@implementation PTALoginController

+ (RACSignal *) showLoginWithViewController: (UIViewController *)vc
{
    PTALoginController *loginController = [[PTALoginController alloc] initWithStyle: UITableViewStyleGrouped];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController: loginController];
    loginController.resultSubject = [RACReplaySubject subject];
    [vc presentViewController: navController animated: YES completion: nil];
    return loginController.resultSubject;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.resultSubject) {
        self.resultSubject = [RACReplaySubject subject];
    }
    
    [self.tableView registerClass: [PTATableInputCell class] forCellReuseIdentifier: InputReuseIdentifier];
    
    self.usernameSubject = [RACSubject subject];
    self.passwordSubject = [RACSubject subject];
    
    self.navigationItem.title = NSLocalizedString(@"PTA Login", nil);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel target: self action: @selector(cancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Login", nil) style: UIBarButtonItemStyleDone target: self action: @selector(login:)];
    
    RAC(self.navigationItem.rightBarButtonItem, enabled) = [RACSignal combineLatest: @[self.usernameSubject, self.passwordSubject] reduce: ^(NSString *username, NSString *password) {
        return @([username hasPrefix: @"P"] &&
                    username.length == kMaxAccountLength &&
                    password.length > 0);
    }];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return FieldCount;
}


- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    PTATableInputCell *cell = [tableView dequeueReusableCellWithIdentifier: InputReuseIdentifier forIndexPath:indexPath];
    if (indexPath.item == UsernameField) {
        cell.label.text = NSLocalizedString(@"Member No.", nil);
        cell.field.placeholder = @"P123456";
        cell.field.secureTextEntry = NO;
        cell.field.keyboardType = UIKeyboardTypeNumberPad;
        cell.field.clearButtonMode = UITextFieldViewModeNever;
        cell.field.delegate = self;
        self.usernameField = cell.field;
        [cell.field.rac_textSignal subscribeNext: ^(NSString *username) {
            [self.usernameSubject sendNext: username];
        }];
    } else if (indexPath.item == PasswordField) {
        cell.label.text = NSLocalizedString(@"Password", nil);
        cell.field.placeholder = @"";
        cell.field.secureTextEntry = YES;
        cell.field.keyboardType = UIKeyboardTypeASCIICapable;
        cell.field.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.field.delegate = self;
        self.passwordField = cell.field;
        [cell.field.rac_textSignal subscribeNext: ^(NSString *password) {
            [self.passwordSubject sendNext: password];
        }];
    }
    return cell;
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing: (UITextField *)textField
{
    if (textField == self.usernameField) {
        if (![self.usernameField.text hasPrefix: @"P"]) {
            textField.text = [@"P" stringByAppendingString: self.usernameField.text ?: @""];
        }
    }
}

- (BOOL) textField: (UITextField *)textField shouldChangeCharactersInRange: (NSRange)range replacementString: (NSString *)string
{
    if (textField == self.usernameField) {
        NSString *oldString = textField.text;
        NSString *first = [oldString substringToIndex: range.location];
        NSString *middle = string;
        NSString *last = [oldString substringFromIndex: range.location + range.length];
        NSString *newString = [[first stringByAppendingString: middle] stringByAppendingString: last];
        return [newString hasPrefix: @"P"] && (newString.length <= kMaxAccountLength);
    }
    return YES;
}



#pragma mark - Action
- (IBAction) cancel: (id)sender
{
    [self.presentingViewController dismissViewControllerAnimated: YES completion: nil];
    [self.resultSubject sendError: [NSError errorWithDomain: kPTAErrorDomain code: PTAUserCanceledLogin userInfo: @{NSLocalizedDescriptionKey: NSLocalizedString(@"User has canceled the login.", nil)}]];
}

- (IBAction) login: (id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo: self.navigationController.view animated: YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"Login…", nil);
    hud.removeFromSuperViewOnHide = YES;

    RACSignal *s = [[PTASite sharedSite] loginWithUsername: self.usernameField.text password: self.passwordField.text];
    [s subscribeNext: ^(PTAUser *user) {
        [self.resultSubject sendNext: user];
        [self.resultSubject sendCompleted];
        [hud hide: YES];
        [self.presentingViewController dismissViewControllerAnimated: YES completion: nil];
    } error: ^(NSError *error) {
        [hud hide: YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Login Failed", nil) message: [error localizedDescription] preferredStyle: UIAlertControllerStyleAlert];

        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {}];
        [alert addAction: defaultAction];
        [self presentViewController: alert animated: YES completion: nil];
    }];
}

@end
