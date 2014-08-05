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

#import "TLFeedCellViewController.h"
#import "TLFeedViewController.h"
#import "TLAppDelegate.h"
#import "TLUserSession+Create.h"
#import "TLLoginViewController.h"
#import "InstagramEngine.h"
#import "TLAddPhotosViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TLHelpViewController.h"

@interface TLFeedCellViewController ()
@property (nonatomic) BOOL isMenuOpen;
@property (nonatomic) BOOL isMapOpen;
@property (nonatomic, strong) NSEntityDescription *photoObject;
@property (nonatomic, strong) NSArray *menuContext;
@property (nonatomic, strong) UIView *topMenuBar;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKPlacemark *placemark;
@end

@implementation TLFeedCellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithEmptyCell
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.photoObject = nil;
    }
    return self;
}
- (id)initWithPhotoObject: (NSEntityDescription *)obj
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.photoObject = obj;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.topMenuBar = [[UIView alloc] init];
    self.geocoder = [[CLGeocoder alloc] init];
    if (nil != self.photoObject)
    {
        [self.view addSubview:_normalView];
        [_photoAuthorUsernameLabel setFont:[UIFont fontWithName:@"DINBek" size:15]];
        [_photoDescriptionLabel setFont:[UIFont fontWithName:@"DINBek" size:16]];
        [_photoDateLabel setFont:[UIFont fontWithName:@"DINBek" size:12]];
        [_photoLikeCountLabel setFont:[UIFont fontWithName:@"DINBek" size:12]];
        [_photoLocationLabel setFont:[UIFont fontWithName:@"DINBek" size:12]];
        _topMenuBar = _normalTopBar;
        [_mapViewContainerView.layer setBorderColor:[UIColor colorWithRed:68.0/255.0 green:53.0/255.0 blue:53.0/255.0 alpha:1].CGColor];
        [_mapViewContainerView.layer setBorderWidth:.5];
        
        _photoAuthorUsernameLabel.text = [_photoObject valueForKey:@"username"];
        NSString *caption = [_photoObject valueForKey:@"caption"];
        NSString *finalCaption = @"";
        if ([caption length] >= 75)
        {
            finalCaption = [finalCaption stringByAppendingFormat:@"%@...",[caption substringToIndex:75]];
        }
        else
        {
            finalCaption = caption;
        }
        _photoDescriptionLabel.text = finalCaption;
        _photoLikeCountLabel.text = [_photoObject valueForKey:@"likesCount"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM yyyy"];
        NSString *formattedDate = [dateFormatter stringFromDate:[_photoObject valueForKey:@"createdDate"]];
        
        _photoDateLabel.text = formattedDate;
        _sru = [_photoObject valueForKey:@"standardResolutionImageURL"];
        [_photoImageView sd_setImageWithURL:[NSURL URLWithString:[_photoObject valueForKey:@"standardResolutionImageURL"]]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                                      [_activityIndicator stopAnimating];
        }];
        
        [_photoAuthorAvatarImageView sd_setImageWithURL:[NSURL URLWithString:[_photoObject valueForKey:@"profilePictureURL"]]
                                              completed:nil];
        
        CLLocation *locationOfPhoto = [[CLLocation alloc] initWithLatitude:[[_photoObject valueForKey:@"latitude"] doubleValue] longitude:[[_photoObject valueForKey:@"longitude"] doubleValue]];
        [self getAdressWithLocation:locationOfPhoto];
    }
    else
    {
        [self.view addSubview:_noPhotoView];
        [_noPhotoMessageLabel setFont:[UIFont fontWithName:@"DINBek" size:18]];
        [_addSomePhotosButton.titleLabel setFont:[UIFont fontWithName:@"DINBek" size:18]];
        [_addSomePhotosButton.layer setCornerRadius:20];
        [_addSomePhotosButton.layer setMasksToBounds:YES];
        [_noPhotoUserAvatarImageView.layer setCornerRadius:_noPhotoUserAvatarImageView.frame.size.height/2];
        [_noPhotoUserAvatarImageView.layer setMasksToBounds:YES];
        _topMenuBar = _topBar;
        
    }

    [_photoAuthorAvatarImageView.layer setCornerRadius:_photoAuthorAvatarImageView.frame.size.width/2];
    [_photoAuthorAvatarImageView.layer setMasksToBounds:YES];
    
    [_menuButton bringSubviewToFront:_topBar];
    
    [self.view.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.view.layer setBorderWidth:0.3];
    
    
    self.isMenuOpen = NO;
    self.isMapOpen = NO;

    for(UIButton *menuItem in [_topMenuBar subviews])
    {
        if ([menuItem isKindOfClass:[UIButton class]])
        {

            [menuItem.titleLabel setFont:[UIFont fontWithName:@"DINBek" size:23]];
            menuItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)toggleMenu:(id)sender
{
    [self toggleMenuWithCompletion:nil];
}
- (IBAction)menuItemClicked:(id)sender
{
    if (10 == [sender tag])
    {
        [self addSomePhotos:nil];
    }
    else if(11 == [sender tag])
    {
        [self toggleMenuWithCompletion:^(BOOL finished){
            NSDictionary *userInfo = @{@"standardResolutionImageURL": [_photoObject valueForKey:@"standardResolutionImageURL"]};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletePhoto" object:self userInfo:userInfo];            
        }];
    }
    else if(12 == [sender tag])
    {
        [self toggleMenuWithCompletion:^(BOOL finished){
            [self shareCurrentPhoto];
        }];
    }
    else if(13 == [sender tag])
    {
        [self toggleMenuWithCompletion:^(BOOL finished)
         {
             TLHelpViewController *helpViewController = [[TLHelpViewController alloc] init];
             [self presentViewController:helpViewController animated:YES completion:nil];
         }];
    }
    else if(14 == [sender tag])
    {
        [self toggleMenuWithCompletion:^(BOOL completion)
        {
            [self logout];
        }];
    }
}

- (void)addSomePhotos:(id)sender
{
    if(nil != sender)
    {
        _isMenuOpen = !_isMenuOpen;
    }

    TLAddPhotosViewController *addPhotosViewController = [[TLAddPhotosViewController alloc] init];
    [self toggleMenuWithCompletion:^(BOOL completion){
        [self presentViewController:addPhotosViewController animated:YES completion:nil];
    }];
    
}
#pragma mark - Helpers
- (void)logout
{
    [[InstagramEngine sharedEngine] logout];
    
    
    TLAppDelegate *delegate = (TLAppDelegate*)[UIApplication sharedApplication].delegate;

    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];

    NSFetchRequest * userSession = [[NSFetchRequest alloc] init];
    [userSession setEntity:[NSEntityDescription entityForName:@"UserSession" inManagedObjectContext:managedObjectContext]];
    [userSession setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * result = [managedObjectContext executeFetchRequest:userSession error:&error];

    [managedObjectContext deleteObject:[result objectAtIndex:0]];
    NSError *saveError = nil;
    [managedObjectContext save:&saveError];

    
    TLLoginViewController *loginViewController = [[TLLoginViewController alloc] init];
    [delegate.window setRootViewController:loginViewController];
}
- (void)toggleMenuWithCompletion:(void (^)(BOOL finished))completion
{
    if (!_isMenuOpen)
    {
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_topMenuBar setFrame:CGRectMake(0, 0, 320, 280)];
                             [_topMenuBar setAlpha:0.8];
                             for(UIButton *menuItem in [_topMenuBar subviews])
                             {
                                 if ([menuItem isKindOfClass:[UIButton class]])
                                 {
                                     [menuItem setUserInteractionEnabled:YES];
                                     [menuItem setAlpha:1.0];
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             if (completion)
                                 completion(finished);
                         }];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollingDisabled" object:self];
        
    }
    else
    {
        [UIView animateWithDuration:.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             [_topMenuBar setFrame:CGRectMake(0, 0, 320, 50)];
                             [_topMenuBar setAlpha:0.4];
                             for(UIButton *menuItem in [_topMenuBar subviews])
                             {
                                 if ([menuItem isKindOfClass:[UIButton class]])
                                 {
                                     [menuItem setUserInteractionEnabled:NO];
                                     [menuItem setAlpha:.0];
                                 }
                             }
                         }
                         completion:^(BOOL finished){
                             if (completion)
                                 completion(finished);
                         }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollingEnabled" object:self];
    }
    _isMenuOpen = !_isMenuOpen;

}
- (void)getAdressWithLocation: (CLLocation *)location
{
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
		if ((placemarks != nil) && (placemarks.count > 0)) {
			// If the placemark is not nil then we have at least one placemark. Typically there will only be one.
			_placemark = [placemarks objectAtIndex:0];
            NSString *locationString = @"";
            if ( nil != _placemark.subLocality )
            {
                locationString = [locationString stringByAppendingFormat:@"%@",_placemark.subLocality];
            }
            if ( nil != _placemark.administrativeArea)
            {
                if ([locationString length])
                {
                    locationString = [locationString stringByAppendingFormat:@" %@",_placemark.administrativeArea];
                }
                else
                {
                    locationString = [locationString stringByAppendingFormat:@"%@",_placemark.administrativeArea];
                }
            }
            if ([locationString length])
            {
                _photoLocationLabel.text = locationString;
            }
            else
            {
                _photoLocationLabel.text = @"N/A";
            }
		}
		else
        {
            _photoLocationLabel.text = @"N/A";
		}
    }];
}
- (void)shareCurrentPhoto
{
    NSString *textToShare = @"";
    textToShare = [textToShare stringByAppendingFormat:@"%@'s photo %@",[_photoObject valueForKey:@"username"],[_photoObject valueForKey:@"link"]];
    
    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    [activityVC setExcludedActivityTypes:excludeActivities];
    [self presentViewController:activityVC animated:YES completion:nil];
}
@end
