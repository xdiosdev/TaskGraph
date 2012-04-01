//
//  NMTGAbstract.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 30.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NMTeamProfile;

@interface NMTGAbstract : NSManagedObject

@property (nonatomic, retain) NSDate * alertDate_first;
@property (nonatomic, retain) NSDate * alertDate_second;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *employers;
@end

@interface NMTGAbstract (CoreDataGeneratedAccessors)

- (void)addEmployersObject:(NMTeamProfile *)value;
- (void)removeEmployersObject:(NMTeamProfile *)value;
- (void)addEmployers:(NSSet *)values;
- (void)removeEmployers:(NSSet *)values;

@end