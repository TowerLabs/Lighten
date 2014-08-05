/*
 Copyright (C) 2014 TowerLabs
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the
 Free Software Foundation, Inc., 51 Franklin Street,
 Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "TLLoginViewController.h"
#import "TLWebViewController.h"
#import "TLUserSession.h"
#import "TLUserSession+Create.h"
#import "TLAppDelegate.h"
#import "TLFeedViewController.h"

@interface TLLoginViewController ()

@end

@implementation TLLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [_signInButton.layer setCornerRadius:20.0];
    [_signInButton.layer setMasksToBounds:YES];
    [_signInButton.titleLabel setFont:[UIFont fontWithName:@"DINBek" size:18]];
    [_headingLabel setFont:[UIFont fontWithName:@"DINBek" size:16]];
    [_titleLabel setFont:[UIFont fontWithName:@"DINBek" size:48]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:nil
                                               object:nil];
    [_activityIndicator setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)signIn:(id)sender
{
    TLWebViewController *webViewController = [[TLWebViewController alloc] init];
    [self presentViewController:webViewController animated:YES completion:nil];
}
#pragma mark - NSNotification
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"LoginWithSuccessNotification"])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        [_signInButton setEnabled:NO];
        [_signInButton setAlpha:0.6];
        [_activityIndicator setHidden:NO];
        [_activityIndicator startAnimating];

        [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {

            NSDictionary *userSession = @{
                                          @"username": userDetail.username,
                                          @"fullname": userDetail.fullName,
                                          @"profilePicture": [userDetail.profilePictureURL absoluteString],
                                          @"bio": userDetail.bio,
                                          @"web": [userDetail.website absoluteString],
                                          @"mediaCount": [NSString stringWithFormat:@"%d",(int)userDetail.mediaCount],
                                          @"followsCount": [NSString stringWithFormat:@"%d",(int)userDetail.mediaCount],
                                          @"followedByCount": [NSString stringWithFormat:@"%d",(int)userDetail.mediaCount],
                                          @"accessToken": [InstagramEngine sharedEngine].accessToken
                                          };
            
            [TLUserSession createUserSessionWithInfo:userSession];
            TLAppDelegate *delegate = (TLAppDelegate*)[UIApplication sharedApplication].delegate;
            
            TLFeedViewController *feedViewController = [[TLFeedViewController alloc] init];
            [delegate.window setRootViewController:feedViewController];
            
            [_activityIndicator stopAnimating];
        } failure:^(NSError *error) {
            [_activityIndicator stopAnimating];
        }];
    }
}
@end
