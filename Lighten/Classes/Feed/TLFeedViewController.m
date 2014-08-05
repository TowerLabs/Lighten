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

#import "TLFeedViewController.h"
#import "TLFeedCellViewController.h"
#import "TLAppDelegate.h"
#import "InstagramEngine.h"
#import "TLFeed+Delete.h"

@interface TLFeedViewController ()
@property (nonatomic) BOOL isFeedModeActive;
@property (nonatomic) UIView *noPhotosView;
@property (nonatomic) int currentFeedCellCount;
@property (nonatomic) NSMutableArray *currentFeed;
@property (nonatomic) int feedFetchOffset;
@end

@implementation TLFeedViewController

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
    self.currentFeedCellCount = 0;
    self.feedFetchOffset = 0;
    self.currentFeed = [[NSMutableArray alloc] init];
    
    [_feedScroll setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:nil
                                               object:nil];
    [self reloadFeed];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ((int)_feedScroll.contentOffset.x / 320 +2  == _currentFeedCellCount)
    {
        [self reloadFeed];
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self setGoToFirstPageButtonAlphaValues:2];
}
#pragma mark - Helpers
- (int)getFeedWithOffset: (int)offset
{
    TLAppDelegate *delegate = (TLAppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"token == %@",[InstagramEngine sharedEngine].accessToken];
    
    [request setFetchOffset:offset];
    [request setFetchLimit:10];
    [request setEntity:entityDescription];
    [request setPredicate:predicate];
    [request setReturnsObjectsAsFaults:NO];
    NSError *errorOfFetch;
    NSArray *response = [moc executeFetchRequest:request error:&errorOfFetch];
    
    if ( 0 == offset && ![response count])
    {
        return 0;
    }
    else if( 0 != offset && ![response count] )
    {
        return 1;
        //eskisiyle takil
    }
    else
    {
        NSLog(@"I may load new ones");
        _currentFeed = [response mutableCopy];
        return 2;
    }
}
- (void)isScrollEnabled:(BOOL)enabled
{
    
}
- (void)reloadFeed
{
    int fetchStatus = [self getFeedWithOffset:_currentFeedCellCount];

    if (1 == fetchStatus)
    {
        return;
    }
    else if(0 == fetchStatus)
    {
        self.isFeedModeActive = NO;
        TLFeedCellViewController *cell = [[TLFeedCellViewController alloc] initWithEmptyCell];
        [cell.view setFrame:CGRectMake(0, 0, 320, 568)];
        _noPhotosView = cell.view;
        [self addChildViewController:cell];
        [self.view addSubview:cell.view];
    }
    else if(2 == fetchStatus)
    {
        self.isFeedModeActive = YES;
        float xOrigin = _currentFeedCellCount * 320;
        for (int i=0; i<[_currentFeed count]; i++)
        {
            TLFeedCellViewController *cell = [[TLFeedCellViewController alloc] initWithPhotoObject:[_currentFeed objectAtIndex:i]];
            [cell.view setFrame:CGRectMake(xOrigin, 0, 320, 568)];
            [self addChildViewController:cell];
            [_feedScroll addSubview:cell.view];
            xOrigin += 320;
        }
        _currentFeedCellCount += [_currentFeed count];
        _feedFetchOffset += [_currentFeed count];
        [_feedScroll setContentSize:CGSizeMake(xOrigin, 568)];
    }
}
#pragma mark - NSNotification
- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ScrollingEnabled"])
    {
        [_feedScroll setScrollEnabled:YES];
    }
    else if ([[notification name] isEqualToString:@"ScrollingDisabled"])
    {
        [_feedScroll setScrollEnabled:NO];
    }
    else if([[notification name] isEqualToString:@"ReloadFeed"])
    {
        if ([_noPhotosView isDescendantOfView:[self view]])
        {
            [_noPhotosView removeFromSuperview];
        }
        [self reloadFeed];
    }
    else if([[notification name] isEqualToString:@"DeletePhoto"])
    {
        [TLFeed deleteObjectWithInfo:notification.userInfo];

        NSLog(@"Feed Cell Count: %d",_currentFeedCellCount);
        if ( 0 == _currentFeedCellCount-1)
        {
            _currentFeedCellCount--;
            UIViewController *cell = [[self childViewControllers] objectAtIndex:0];
            [cell willMoveToParentViewController:nil];
            [cell.view removeFromSuperview];
            [cell removeFromParentViewController];
            self.isFeedModeActive = NO;
            TLFeedCellViewController *noPhotosCell = [[TLFeedCellViewController alloc] initWithEmptyCell];
            [noPhotosCell.view setFrame:CGRectMake(0, 0, 320, 568)];
            _noPhotosView = noPhotosCell.view;
            [self addChildViewController:noPhotosCell];
            [self.view addSubview:noPhotosCell.view];
        }
        else
        {
            float xOffset;
            for (TLFeedCellViewController *cell in [self childViewControllers])
            {
                if ([[notification.userInfo valueForKey:@"standardResolutionImageURL"] isEqualToString:cell.sru])
                {
                    xOffset = cell.view.frame.origin.x;
                    [cell willMoveToParentViewController:nil];
                    [cell.view removeFromSuperview];
                    [cell removeFromParentViewController];
                }
            }
            NSLog(@"deleted cell's x pos: %f",xOffset);
            _currentFeedCellCount--;
            for (UIView *view in _feedScroll.subviews)
            {
                if (view.frame.origin.x > xOffset)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [view setFrame:CGRectMake(view.frame.origin.x-320, 0, 320, 568)];
                    });
                }
            }
            [_feedScroll setContentSize:CGSizeMake((float)_currentFeedCellCount * 320, 568)];
            NSLog(@"New content size:%f",(float)_currentFeedCellCount*320);
        }
    }
}
@end
