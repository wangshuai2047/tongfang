//
//  MemberSync.m
//  TFHealth
//
//  Created by nico on 14-12-2.
//  Copyright (c) 2014年 studio37. All rights reserved.
//

#import "MemberSync.h"
#import "Members.h"
#import "AppCloundService.h"
#import "User.h"
#import "NSData+Base64.h"

@implementation MemberSync

static int mbdownloadExists=0;
static DataSyncBase* mbdownloadInstance;

-(void)setInstance
{
    mbdownloadInstance = self;
}

-(void)setDownloadFlag:(int)flag
{
    mbdownloadExists=flag;
}

-(int)getDownloadFlag
{
    return mbdownloadExists;
}

-(BOOL)isSingleResult
{
    return false;
}

-(BOOL)isExist:(int)uid uname:(NSString*)uname
{
    //Members* m = [Members MR_findFirstByAttribute:@"appUserId" withValue:[NSString stringWithFormat:@"%d", uid] inContext:[NSManagedObjectContext MR_defaultContext]];
    //return m!=nil;
    return FALSE;
}

-(void)queryData
{
    [self.service getUserMembers: self.userId];
}

-(void)updateData:(NSDictionary*)keyValues
{
    int uid = [keyValues[@"UserID"] intValue];
    int age = [keyValues[@"Age"] intValue];
    NSString* nickName = (NSString*)keyValues[@"NickName"];
    int sex = [keyValues[@"Sex"] intValue];
    double height = [keyValues[@"UserHeight"] doubleValue];
    double weight = [keyValues[@"Weight"] doubleValue];
    NSString* strDate = (NSString*)keyValues[@"RegisterTime"];
    double tick= [[strDate substringWithRange:NSMakeRange(6, 13)] doubleValue]/1000;
    //NSDate* regDate = [NSDate dateWithTimeIntervalSince1970:tick];
    
    User* existUser = [User MR_findFirstByAttribute:@"userId" withValue:[NSString stringWithFormat:@"%d", uid] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if(existUser==nil)
    {
        User* info = [User MR_createEntity];
        info.userId = [NSNumber numberWithInt:uid];
        info.birthday = [NSNumber numberWithInt:age];
        info.nickName = nickName;
        info.sex = [NSNumber numberWithInt:sex];
        info.height = [NSNumber numberWithDouble:height];
        info.weight = [NSNumber numberWithDouble:weight];
        
        if(keyValues[@"UserIco"]!=nil)
        {
            NSData *imgdata = nil;
            NSString* strData = (NSString*)keyValues[@"UserIco"];
            imgdata = [NSData dataWithBase64EncodedString:strData];
            info.userIco = imgdata;
        }
    }
    
    Members* existMember = [Members MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"userId ==%d AND appUserId==%d",uid,self.userId] inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    if(existMember==nil)
    {
        Members* member = [Members MR_createEntity];
        member.userId = [NSNumber numberWithInt:uid];
        member.memberType = [NSNumber numberWithInt:0];
        member.appUserId = [NSNumber numberWithInt:self.userId];
    }
}

-(NSString*)getMethodName
{
    return @"GetUserMembersJson";
}
@end
