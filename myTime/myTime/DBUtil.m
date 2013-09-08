//
//  DBUtil.m
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.08..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import "DBUtil.h"
#import "AppDelegate.h"
#import "TimeSheetEntry.h"

@implementation DBUtil

+ (NSManagedObjectContext *)getContext {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    return [appDelegate managedObjectContext];
}


//a modelltol lehet megszerezni az elore definialt fetch request-eket (template nev alapjan torteno lekerdezeshez kell)
+ (NSManagedObjectModel *)getModel {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    return [appDelegate managedObjectModel];
}

//magat a kontext-et lehet save-elni!!! minden kontext objektum aktualis allapota mentesre kerul.
+ (BOOL)persistInContext:(NSManagedObjectContext *)context useError:(NSError **)error {
    
    BOOL success = [context save:error];
    return success;
}

+ (TimeSheetEntry *)timeSheetEntryForCreate {
    
    NSManagedObject *mo = [NSEntityDescription insertNewObjectForEntityForName:@"TimeSheetEntry" inManagedObjectContext:[DBUtil getContext]];
    
    return (TimeSheetEntry *)mo;
}

+ (NSArray *)retrieveAllEntries {
    NSError *error;
    
    // Test listing all FailedBankInfos from the store
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"TimeSheetEntry"
                                              inManagedObjectContext:[DBUtil getContext]];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [[DBUtil getContext] executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
    
}

@end
