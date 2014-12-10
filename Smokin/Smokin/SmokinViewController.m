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
@property (strong, nonatomic) NSDateFormatter *JSONdateFormatter;

@property (strong, nonatomic) UIActivityIndicatorView *activityView;

@end

NSInputStream *inputStream;
NSOutputStream *outputStream;

@implementation SmokinViewController
{
    BOOL status;
}

#pragma mark - Initializers

- (void)viewDidLoad
{
   [super viewDidLoad];
    
    [self initNetworkCommunication];
    
    status = NO;
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.JSONdateFormatter = [[NSDateFormatter alloc] init];
    
    [self.dateFormatter setDateFormat:@"HH:MM:ss, d MMM YYYY"];
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self.JSONdateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
    [self.JSONdateFormatter setLocale:[NSLocale currentLocale]];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastChecked"];
    if (date)
        self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    else
        self.lastCheckedLabel.text = @"Last checked: Never";
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastStatus"])
    {
        BOOL lastStatus = [[NSUserDefaults standardUserDefaults] boolForKey:@"lastStatus"];
                           self.statusLabel.text = [NSString stringWithFormat:@"Status: %@", (lastStatus ? @"True" : @"False")];
    }
    
    self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    self.activityView.center=self.view.center;
    
    [self.view addSubview:self.activityView];
}

//Connect to the server
- (void)initNetworkCommunication {
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"192.168.0.15", 10001, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

//listen for messages from the server
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	NSLog(@"stream event %i", streamEvent);
    
    switch (streamEvent) {
            
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
            
		case NSStreamEventHasBytesAvailable:
            if (theStream == inputStream) {
                
                uint8_t buffer[1024];
                int len;
                
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                            [self fetchedData:[[NSData alloc] initWithData:[output dataUsingEncoding:NSASCIIStringEncoding]]];
                        }
                    }
                }
            }
			break;
            
		case NSStreamEventErrorOccurred:
			NSLog(@"Can not connect to the host!");
			break;
            
		case NSStreamEventEndEncountered:
			break;
            
		default:
			NSLog(@"Unknown event");
	}
}

#pragma mark - Actions
//send the JSON request to the server
- (IBAction)checkButtonPressed:(id)sender
{
    [self.activityView startAnimating];
    
    NSString *response  = [NSString stringWithFormat:@"{\"request\" : \"status\"}"];
	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
	[outputStream write:[data bytes] maxLength:[data length]];
}

//parse the JSON data retrieved from the server
- (void)fetchedData:(NSData *)responseData {
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSString* statusReturned = [json objectForKey:@"status"];
    NSString* timesampReturned = [json objectForKey:@"time"];
    NSString* postNot = [json objectForKey:@"post_notification"];
    
    //post the notification when the smoke detector is going off
    if(postNot && [postNot isEqualToString:@"True"])
    {
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        localNotification.alertBody = @"DETECTOR TRIGGERED!\nDectorID: TEST_LIVINGROOM_123";
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    self.statusLabel.text = [NSString stringWithFormat:@"status: %@", statusReturned];
    self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:
                                                                                  [self.JSONdateFormatter dateFromString:
                                                                                   timesampReturned]]];
    [self.activityView stopAnimating];
}


//used for initial ui testing before smoke detector was set up
- (IBAction)leftTestButtonPressed:(id)sender
{
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
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
        self.statusLabel.text = @"Status: True";
    else
        self.statusLabel.text = @"Status: False";

    NSDate *date = [NSDate date];
    self.lastCheckedLabel.text = [NSString stringWithFormat:@"Last checked: %@", [self.dateFormatter stringFromDate:date]];
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:@"lastChecked"];
    [[NSUserDefaults standardUserDefaults] setBool:status forKey:@"lastStatus"];
}

@end