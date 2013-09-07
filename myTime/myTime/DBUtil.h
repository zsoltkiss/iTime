//
//  DBUtil.h
//  myTime
//
//  Created by Kiss Rudolf Zsolt on 2013.09.08..
//  Copyright (c) 2013 Kiss Rudolf Zsolt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TimeSheetEntry;

@interface DBUtil : NSObject

+ (NSManagedObjectContext *)getContext;


//a modelltol lehet megszerezni az elore definialt fetch request-eket (template nev alapjan torteno lekerdezeshez kell)
+ (NSManagedObjectModel *)getModel;

//magat a kontext-et lehet save-elni!!! minden kontext objektum aktualis allapota mentesre kerul.
+ (BOOL)persistInContext:(NSManagedObjectContext *)context useError:(NSError **)error;

+ (TimeSheetEntry *)timeSheetEntryForCreate;


@end
