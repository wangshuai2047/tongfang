//
//  AppCloundService.h
//  TFHealth
//
//  Created by nico on 14-6-22.
//  Copyright (c) 2014年 studio37. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "WebServiceProxy.h"
#import "ASIHTTPRequest/ASIHTTPRequestDelegate.h"
#import "ServiceCallbackDelegate.h"


@interface AppCloundService : NSObject<ServiceCallbackDelegate>
{

    NSString* _methodName;
}


@property (nonatomic,copy) NSString* methodName;
@property (nonatomic,assign) id<ServiceObjectDelegate> objectDelegate;


-(AppCloundService*)initWidthDelegate:(id<ServiceObjectDelegate>)callback;

-(void)GetUserInfo:(int)userId;
-(void)UserLogin:(NSString*)usermail userPassword:(NSString*)password;
-(void)RegisterUser:(NSString*)usermail userPassword:(NSString*)password;
-(void)ImproveUserData:(int)userId userIco:(NSData*)icodata nick:(NSString*)name userAge:(int)age userSex:(int)sex userHeight:(int)height remark:(NSString*)remark;
-(void)SyncUser:(NSString*)usermail userPassword:(NSString*)password;

//上传用户类型，0:手环 1:秤 2:两者都有
-(void) UploadUserDevices:(int)appUserId userType:(NSString*)userType;

//同步运动项目及强度系数列表
-(void) GetCoefficients;

//上传用户喜欢的运动项目
-(void) UploadDefaultSports:(int)appUserId sportName1:(NSString*)sportName1 sportName2:(NSString*)sportName2 sportName3:(NSString*)sportName3;

//上传用户手环运动记录
-(void)UploadUserCoreValue:(int)appUserId ItemId:(int)ItemId ItemName:(NSString*)ItemName StepCount:(int)StepCount KmCount:(float)KmCount CalorieValue:(int)CalorieValue TimeLenght:(int)TimeLenght SleepTimeCount:(int)SleepTimeCount LastCoreStep:(int)LastCoreStep LastCoreCalorieValue:(int)LastCoreCalorieValue CreateTime:(NSDate*)CreateTime;

//添加成员
-(void) AddMembers:(int)appUserId userIco:(NSData*)icodata nick:(NSString*)name userHeight:(int)height userWeight:(int)weight userSex:(int)sex userAge:(int)age userType:(NSString*)utype relationshipName:(NSString*)rName addTime:(NSString*) aTime;

/*获取运动处方 性别（1男2女） 体脂百分比  肌肉  肌肉正常范围的均值  肌肉正常范围下限（上限加下限除以2）  年龄  周减重目标*/
-(void)getSportPrescription:(int)appUserId sex:(int)sex pbf:(float)pbfValue muscle:(float)muscle m1:(float)m1 m2:(float)m2 age:(int)age weeksubtact:(float)weeksubtact;

/*获取营养处方 性别（1男2女） 体脂百分比  肌肉  肌肉正常范围的均值  肌肉正常范围下限（上限加下限除以2）  周减重目标  运动减重百分比　膳食减重百分比*/
-(void)getFoodPrescription:(int)appUserId sex:(int)sex pbf:(float)pbfValue muscle:(float)muscle m1:(float)m1 m2:(float)m2 weeksubtact:(float)weeksubtact sporttarget:(float)sporttarget foodtarget:(float)foodtarget;

/* 更新个人设置  用户编号 目标体重  周减重量   运动减重占比   膳食减重占比  睡眠时长 步伐长度 目标步伐数 提醒时间 */
-(void)addAndUpdatePersonalSet:(int)userId targetWeight:(float)targetWeight weekSubTarget:(float)weekSubTarget sportProp:(float)sportProp foodProp:(float)foodProp  sleepTimeLength:(NSString*)sleepTimeLength stepLength:(int)stepLength stepCount:(int)stepCount alertTime:(NSString*)alertTime;

-(void)getFoodClass;
-(void)getFoodDictionary;

/*删除家庭成员*/
-(void)deleteMemberWithMemberId:(int)userId;

/* 获取用户日常膳食记录  用户编号 */
-(void)getUserDiliyFoodWithUserId:(int)userId;

/* 上传用户膳食记录  用户编号  膳食编号  摄入总量   摄入卡路里   摄入日期  类型：早中晚餐 */
-(void)uploadFoodInfoWithUserId:(int)userId foodId:(int)foodId intakeValue:(NSString *)takeValue calorieValuer:(NSString *)calorieValue intakeDate:(NSString *)date andType:(NSString *)type;
-(void)getUserFriendsWithUserId:(int)userId;
/* 添加自定义膳食   用户编号  膳食分类   膳食名称  单位摄入量卡路里  单位摄入量  是否自定义项目 0-否 1-是*/
-(void)addCustomsFoodWithUserId:(int)userId classId:(int)classId foodName:(NSString *)foodName caloriesValue:(float)caloriesValue gramValue:(float)gramValue isCustoms:(int)isCustom;

/* 添加自定义运动项目 用户编号 运动名称 单位（组，个，分钟） 单位时间消耗卡路里 单位时间 是否自定义项目 备注 */
-(void)addCustomsSportItemWithUserId:(int)userId sportName:(NSString *)sportName uint:(NSString *)uint caloriesValue:(float)caloriesValue timeSpan:(int)timeSpan isCustoms:(int)isCustom remarks:(NSString *)remarks;
-(void)uploadSportWithUserId:(int)userId sportId:(int)sportId movementTime:(int)movementTime calorie:(NSString *)cal sportDate:(NSString *)sportDate;
/* 获取系统运动项目 */
-(void)getSportItems;
/* 获取活跃用户 */
-(void)getActivityUsersWithUserId:(int)userId ;
/* 获取推荐 */
-(void)getLikeUsersWithUserId:(int)userId;
/* 获取排行榜 */
-(void)getBeatPercentageUserId:(int)userId;
/* 添加好友 */
-(void)addFriendWithUserId:(int)userId friendId:(int)friendId time:(NSDate *)date;

/**
 @brief 上传用户检测数据
 */
-(void)uploadUserItemInfo:(int)userId cId:(int)cId itemId:(int)itemId testDate:(NSDate*)date testValue:(NSNumber*)testValue;

/**
 @brief 上传用户综合测试成绩
 */
-(void)uploadCompositeScore:(int)userId score:(NSNumber*)score testDate:(NSDate*)date;

/**
 @brief 获取用户所有综合得成成绩
 */
-(void)getUserCompInfo:(int)userId;

/**
 @brief 获取用户所有测试项目
 */
-(void)getUserItems:(int)userId;

/**
 @brief 获取用户所有家人
 */
-(void)getUserMembers:(int)userId;

/**
 @brief 获取用户设备
 */
-(void)getUserDevices:(int)userId;

/**
 @brief 获取用户设置
 */
-(void)getUserPersonalSetInfo:(int)userId;

/**
 @brief 获取用户手环运动数据
 */
-(void)getUserCoreValue:(int)userId;

/**
 @brief 分享测试信息
 */
-(void)shareTestInfo:(int)appUserId weight:(double) weight stateIndex:(double) stateIndex fatRate:(double) fatRate fat:(double) fat muscle:(double) muscle water:(double) water bone:(double) bone protein:(double) protein stepcount:(int)stepcount burnCalories:(double) burnCalories;

@end


