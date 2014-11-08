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

#pragma mark - Initializers

- (void)viewDidLoad
{
   [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"HH:MM:ss, d MMM YYYY"];
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastChecked"];
    if (date)
        self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    else
        self.lastCheckedLabel.text = @"Last checked: Never";
    
    self.activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.activityView.center=self.view.center;
    
    [self.view addSubview:self.activityView];
}

#pragma mark - Actions
- (IBAction)checkButtonPressed:(id)sender
{
    NSLog(@"I've been clicked nyukka.");
    NSDate *date = [NSDate date];
    self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastChecked"];
 
    [self setStatus];
    
}

- (void) setStatus
{
    [self.activityView startAnimating];
    // TODO: implement me
    [self performSelector:@selector(timeout) withObject:nil afterDelay:5];
}

- (void) timeout
{
    [self.activityView stopAnimating];
    self.statusLabel.text = @"Status: ERROR: Timeout.";
}

@end
