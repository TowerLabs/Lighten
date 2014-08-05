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

#import "TLHelpViewController.h"

@interface TLHelpViewController ()

@end

@implementation TLHelpViewController

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
    [_titleLabel setFont:[UIFont fontWithName:@"DINBek" size:20]];
    [self printAboutText];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - IBActions
- (IBAction)dismissViewController:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Helpers
- (void)printAboutText
{
    // Create the attributed string
    NSMutableAttributedString *help = [[NSMutableAttributedString alloc]initWithString:
                                       @"Why?\n\nThis is a good question. The answer is, in Instagram application you can only see most recent liked 300 media. So if you do not want to lose beautiful moments and want to collect them, this application is just for you.\n\nHow can I add photos?\n\nWhen you open the application for the first time, you can add new photos by clicking the blue button titled \"Add Some Photos\". You can add photos by clicking the menu icon on the right top side of view and then clicking the \"Add Photos\" menu as well. \nYou can add photos to your collection from your Instagram liked-photos.\n\nHow can I delete a photo?\n\nYou can delete a photo by clicking the menu icon on the right top side of view and then clicking the \"Delete This Photo\" button.\n\nHow can I share a photo?\n\nYou can share a photo by clicking the menu icon on the right top side of view and then clicking the \"Share\" button.\n\nHow can I sign out of application?\n\nYou can sign out of application by clicking the menu icon on the right top side of view and then clicking the \"Sign Out\" button.\n\n\nYour question is not listed above?\nAsk us anything from: info@towerlabs.co"];
    
    // Declare the fonts
    UIFont *helpFont1 = [UIFont fontWithName:@"DINBek" size:18.0];
    
    // Declare the colors
    UIColor *helpColor1 = [UIColor colorWithRed:0.000000 green:0.000000 blue:0.000000 alpha:0.360784];
    
    // Declare the paragraph styles
    NSMutableParagraphStyle *helpParaStyle1 = [[NSMutableParagraphStyle alloc]init];
    
    
    // Create the attributes and add them to the string
    [help addAttribute:NSUnderlineColorAttributeName value:helpColor1 range:NSMakeRange(0,782)];
    [help addAttribute:NSParagraphStyleAttributeName value:helpParaStyle1 range:NSMakeRange(0,782)];
    [help addAttribute:NSFontAttributeName value:helpFont1 range:NSMakeRange(0,782)];
    [help addAttribute:NSParagraphStyleAttributeName value:helpParaStyle1 range:NSMakeRange(782,333)];
    [help addAttribute:NSFontAttributeName value:helpFont1 range:NSMakeRange(782,333)];
    _aboutTextView.attributedText = help;
}
@end
