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

#import "TLFeed+Delete.h"
#import "TLAppDelegate.h"

@implementation TLFeed (Delete)
+(void)deleteObjectWithInfo:(NSDictionary *)info
{
    TLAppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *managedObjectContext = [delegate managedObjectContext];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"standardResolutionImageURL = %@",[info valueForKey:@"standardResolutionImageURL"]];
    
    NSError *saveError;
    NSError *fetchError;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:managedObjectContext];
    
    [fetchRequest setFetchLimit:1];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];

    
    [managedObjectContext deleteObject:[fetchedObjects objectAtIndex:0]];
    [managedObjectContext save:&saveError];
}
@end