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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TLFeedCellViewController : UIViewController

@property (strong, nonatomic) NSString *sru;


@property (strong, nonatomic) IBOutlet UIView *topBar;
@property (strong, nonatomic) IBOutlet UIView *normalTopBar;
@property (strong, nonatomic) IBOutlet UIView *normalView;
@property (strong, nonatomic) IBOutlet UIView *noPhotoView;
@property (strong, nonatomic) IBOutlet UIView *mapViewContainerView;


@property (strong, nonatomic) IBOutlet UILabel *photoDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *photoLocationLabel;
@property (strong, nonatomic) IBOutlet UILabel *noPhotoMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *photoLikeCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *photoDescriptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *photoAuthorUsernameLabel;


@property (strong, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) IBOutlet UIButton *addSomePhotosButton;
@property (strong, nonatomic) IBOutlet UIButton *photoLocationButton;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UIImageView *photoLikeIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *photoClockIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *photoLocationIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *photoAuthorAvatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *noPhotoUserAvatarImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithEmptyCell;
- (id)initWithPhotoObject: (NSEntityDescription *)obj;

- (IBAction)toggleMenu:(id)sender;
- (IBAction)addSomePhotos:(id)sender;
- (IBAction)menuItemClicked:(id)sender;
@end
