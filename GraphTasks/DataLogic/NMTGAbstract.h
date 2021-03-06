//
//  NMTGAbstract.h
//  GraphTasks
//
//  Created by Тимур Юсипов on 07.06.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NMTGAbstract : NSManagedObject

@property (nonatomic, retain) NSDate * alertDate_first;
@property (nonatomic, retain) NSDate * alertDate_second;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * context;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * deferred;
@property (nonatomic, retain) NSNumber * done;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSString * title;

@end
