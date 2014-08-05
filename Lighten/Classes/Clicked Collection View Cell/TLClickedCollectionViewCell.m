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

#import "TLClickedCollectionViewCell.h"

@implementation TLClickedCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView *clickedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 106, 106)];
        [clickedView setBackgroundColor:[UIColor whiteColor]];
        [clickedView setAlpha:0.4];
        
        UIView *clickedIcon = [[UIView alloc] initWithFrame:CGRectMake(80, 80, 20,20)];
        [clickedIcon.layer setCornerRadius:clickedIcon.frame.size.height/2];
        [clickedIcon.layer setMasksToBounds:YES];
        [clickedIcon setBackgroundColor:[UIColor colorWithRed:77.0/255.0 green:116.0/255.0 blue:247.0/255.0 alpha:1]];
        [clickedIcon.layer setBorderColor:[UIColor whiteColor].CGColor];
        [clickedIcon.layer setBorderWidth:1];
        
        UIImageView *checkmarkIcon = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 10, 10)];
        checkmarkIcon.image = [UIImage imageNamed:@"checkmark.png"];
        [clickedIcon addSubview:checkmarkIcon];
        
        [self addSubview:clickedView];
        [self addSubview:clickedIcon];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
