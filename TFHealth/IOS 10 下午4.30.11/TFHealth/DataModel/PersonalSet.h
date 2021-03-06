//
//  PersonalSet.h
//  TFHealth
//
//  Created by chenzq on 14-6-14.
//  Copyright (c) 2014年 studio37. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface PersonalSet : NSManagedObject
@property (nonatomic, retain) NSNumber * personId;
@property (nonatomic, retain) NSDate * completedDate;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * remindTime;
@property (nonatomic, retain) NSNumber * remindWay;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * targetWeight;
@property (nonatomic, retain) NSNumber * userId;


@property (nonatomic, retain) NSNumber * foodSubtract;
@property (nonatomic, retain) NSNumber * sleepTimeLength;
@property (nonatomic, retain) NSNumber * sportSubtract;
@property (nonatomic, retain) NSNumber * stepLength;
@property (nonatomic, retain) NSNumber * stepTargetCount;
@property (nonatomic, retain) NSNumber * weekTarget;


@property (nonatomic, retain) User *personal_user_ship;

@end
