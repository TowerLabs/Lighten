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

#import "TLAddPhotosViewController.h"
#import "InstagramEngine.h"
#import "TLAddPhotosCollectionViewCell.h"
#import "AsyncImageView.h"
#import "InstagramMedia.h"
#import "InstagramPaginationInfo.h"
#import "TLClickedCollectionViewCell.h"
#import "TLAppDelegate.h"
#import "InstagramComment.h"
#import "InstagramUser.h"
#import "TLFeed+Create.h"

@interface TLAddPhotosViewController ()
@property (nonatomic) InstagramPaginationInfo *pagination;
@property (nonatomic) NSMutableArray *clickedMedia;
@property (nonatomic) NSArray *likedMedia;
@property (nonatomic) double countOfMedia;
@property (nonatomic) CGPoint pointNow;
@property (nonatomic) BOOL isRequesting;
@end

@implementation TLAddPhotosViewController

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
    [AsyncImageLoader sharedLoader].cache = [AsyncImageLoader defaultCache];
    self.isRequesting = NO;
    
    [_titleLabel setFont:[UIFont fontWithName:@"DINBek" size:20]];
    [_doneButton.titleLabel setFont:[UIFont fontWithName:@"DINBek" size:18]];
    [_selectedItemInfoLabel setFont:[UIFont fontWithName:@"DINBek" size:16]];
    [_doneButton setEnabled:NO];
    [_doneButton setAlpha:0.5];

    [_segmentControl setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blueColor],NSForegroundColorAttributeName,[UIFont fontWithName:@"DINBek" size:14.0f], NSFontAttributeName,nil] forState:UIControlStateNormal];

    [self.collectionView registerNib:[UINib nibWithNibName:@"TLAddPhotosCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];

    _countOfMedia = 23;
    
    self.clickedMedia = [[NSMutableArray alloc] init];
    
    [_collectionView sendSubviewToBack:self.view];
    [_bottomBarView bringSubviewToFront:self.view];
    
    [[InstagramEngine sharedEngine] getMediaLikedBySelfWithCount:_countOfMedia maxId:nil success:^(NSArray *media, InstagramPaginationInfo *paginationInfo)
    {
        NSMutableArray *filteredMedia = [self filterMediaByPhotos:media];
        self.likedMedia = filteredMedia;
        self.pagination = paginationInfo;
        [_collectionView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_activityIndicator stopAnimating];
            [_collectionView setHidden:NO];
        });
    } failure:^(NSError *error)
    {
        [_activityIndicator stopAnimating];
        if (-1004 == error.code)
        {
            [_messageLabel setFont:[UIFont fontWithName:@"DINBek" size:16]];
            [_messageLabel setHidden:NO];
        }
        
    }];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_activityIndicator setFrame:CGRectMake(150, [UIScreen mainScreen].bounds.size.height/2-10, 20, 20)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)saveSelectedPhotos:(id)sender
{
    if ([_clickedMedia count])
    {
        NSMutableDictionary *temp;
        InstagramMedia *feedObject = [[InstagramMedia alloc] init];
        for (int i=0; i<[_clickedMedia count];i++)
        {
            NSIndexPath *indexPath = [_clickedMedia objectAtIndex:i];
            feedObject = [_likedMedia objectAtIndex:indexPath.row];
            temp = [[NSMutableDictionary alloc] init];
            [temp setValue:feedObject.user.username forKey:@"username"];
            [temp setValue:[feedObject.standardResolutionImageURL absoluteString] forKey:@"standardResolutionImageURL"];
            [temp setValue:[feedObject.user.profilePictureURL absoluteString] forKey:@"profilePictureURL"];
            [temp setValue:[NSString stringWithFormat:@"%f",feedObject.location.longitude] forKey:@"longitude"];
            [temp setValue:[NSString stringWithFormat:@"%f",feedObject.location.latitude] forKey:@"latitude"];
            [temp setValue:[NSString stringWithFormat:@"%d",(int)feedObject.likesCount] forKey:@"likesCount"];
            [temp setValue:feedObject.createdDate forKey:@"createdDate"];
            [temp setValue:feedObject.caption.text forKey:@"caption"];
            [temp setValue:[InstagramEngine sharedEngine].accessToken forKey:@"token"];
            [temp setValue:feedObject.link forKey:@"link"];
            [TLFeed createFeedWithInfo:temp];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadFeed" object:self];
}

- (IBAction)dismissAddPhotosViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - CollectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_likedMedia count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TLAddPhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    
    AsyncImageView *imageView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 106, 106)];
    imageView.image = [UIImage imageNamed:@"cellPlaceholderImage.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell addSubview:imageView];
    
    NSURL *url = [[_likedMedia objectAtIndex:indexPath.row] valueForKey:@"thumbnailURL"];
    imageView.imageURL = url;

    if ([_clickedMedia containsObject:indexPath])
    {
        [cell addSubview:[[TLClickedCollectionViewCell alloc] init]];
    }
    
    return cell;
}
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y>_pointNow.y)
    {
        [_activityIndicator setFrame:CGRectMake(150, [UIScreen mainScreen].bounds.size.height - 70, 20, 20)];
        [_activityIndicator setHidden:NO];
        [_activityIndicator startAnimating];
        [self updatePhotos];
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _pointNow = scrollView.contentOffset;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    if ([_clickedMedia containsObject:indexPath])
    {
        [_clickedMedia removeObject:indexPath];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    else
    {
        [_clickedMedia addObject:indexPath];
        [[collectionView cellForItemAtIndexPath:indexPath] addSubview:[[TLClickedCollectionViewCell alloc] init]];
    }
    
    [_selectedItemInfoLabel setText:[NSString stringWithFormat:@"%d Photo Selected",(int)[_clickedMedia count]]];

    if ([_clickedMedia count])
    {
        [_doneButton setAlpha:1];
        [_doneButton setEnabled:YES];
    }
    else
    {
        [_doneButton setAlpha:0.5];
        [_doneButton setEnabled:NO];
    }
}
#pragma mark - Helpers
- (void)updatePhotos
{
    if (!_pagination.nextMaxId)
    {
        [_activityIndicator stopAnimating];
        NSLog(@"Reached to the end");
    }
    else
    {
        if (!_isRequesting)
        {
            _isRequesting = YES;
            [[InstagramEngine sharedEngine] getMediaLikedBySelfWithCount:_countOfMedia maxId:_pagination.nextMaxId success:^(NSArray *media, InstagramPaginationInfo *paginationInfo)
             {
                 _isRequesting = NO;
                 NSMutableArray *filteredMedia = [self filterMediaByPhotos:media];
                 
                 filteredMedia = [[_likedMedia arrayByAddingObjectsFromArray:filteredMedia] mutableCopy];
                 
                 self.likedMedia = filteredMedia;
                 self.pagination = paginationInfo;
                 NSLog(@"Pagination maxid: %@-%@",_pagination.nextMaxId, [_pagination.nextMaxId class]);
                 [_collectionView reloadData];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [_activityIndicator stopAnimating];
                     [_collectionView setHidden:NO];
                 });
             } failure:^(NSError *error)
             {
                 _isRequesting = NO;
                 [_activityIndicator stopAnimating];
                 if (-1004 == error.code)
                 {
                     [_messageLabel setFont:[UIFont fontWithName:@"DINBek" size:16]];
                     [_messageLabel setHidden:NO];
                 }
                 
             }];
        }
    }
}
- (NSMutableArray *)filterMediaByPhotos: (NSArray *)media
{
    NSMutableArray *filteredMedia = [media mutableCopy];
    for (int i=0; i< [media count]; i++)
    {
        InstagramMedia *m = [media objectAtIndex:i];
        if (m.isVideo)
        {
            [filteredMedia removeObjectAtIndex:i];
        }
    }
    return filteredMedia;
}
@end
