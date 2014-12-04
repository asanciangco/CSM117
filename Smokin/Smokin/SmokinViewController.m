//
//  SmokinViewController.m
//  Smokin
//
//  Created by Alex Sanciangco on 11/7/14.
//  Copyright (c) 2014 CS117. All rights reserved.
//

#import "SmokinViewController.h"

@interface SmokinViewController ()

@property (strong, nonatomic) IBOutlet UIView *checkButton;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastCheckedLabel;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) UIActivityIndicatorView *activityView;


@end

@implementation SmokinViewController
{
    BOOL status;
}

#pragma mark - Initializers

- (void)viewDidLoad
{
   [super viewDidLoad];
    status = NO;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"HH:MM:ss, d MMM YYYY"];
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastChecked"];
    if (date)
        self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    else
        self.lastCheckedLabel.text = @"Last checked: Never";
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastStatus"])
    {
        BOOL lastStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"lastStatus"];
                           self.statusLabel.text = [NSString stringWithFormat:@"Status: %@", (lastStatus ? @"Triggered" : @"Not Triggered")];
    }
    
    self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.activityView.center=self.view.center;
    
    [self.view addSubview:self.activityView];
}

#pragma mark - Actions
- (IBAction)checkButtonPressed:(id)sender
{
    [self setStatus];
    
}

- (IBAction)leftTestButtonPressed:(id)sender
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    localNotification.alertBody = @"DETECTOR TRIGGERED!\nDectorID: TEST_LIVINGROOM_123";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    status = YES;
    [self testHelperMethod];
}

- (IBAction)rightTestButtonPressed:(id)sender
{
    status = !status;
}

- (void) setStatus
{
    [self.activityView startAnimating];
    // TODO: implement me
    [self performSelector:@selector(testHelperMethod) withObject:nil afterDelay:3];
}

- (void) timeout
{
    [self.activityView stopAnimating];
    self.statusLabel.text = @"Status: ERROR: Timeout.";
}

- (void) testHelperMethod
{
    [self.activityView stopAnimating];
    if (status)
        self.statusLabel.text = @"Status: Triggered";
    else
        self.statusLabel.text = @"Status: Not Triggered";

    NSDate *date = [NSDate date];
    self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastChecked"];
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"lastStatus"];
}

@end