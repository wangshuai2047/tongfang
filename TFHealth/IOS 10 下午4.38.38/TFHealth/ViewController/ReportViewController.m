//
//  ReportViewController.m
//  TFHealth
//
//  Created by chenzq on 14-7-20.
//  Copyright (c) 2014年 studio37. All rights reserved.
//

#import "ReportViewController.h"
#import "ReportTableViewCell.h"
#import "LineGraphView.h"
#import "UIViewController+MMDrawerController.h"
#import "ReportModel.h"
#import "AppDelegate.h"
#import "PersonalSet.h"
#import "User_Item_Info.h"
#import "TestItemID.h"
#import "DalidFood.h"
#import "Sport_Item_Value.h"
#import "UserCoreValues.h"

@interface ReportViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *reportTable;
@property (weak, nonatomic) IBOutlet UILabel *title_desc;
@property (weak, nonatomic) IBOutlet UIView *report_container;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *comp_title;
- (IBAction)BackAction:(id)sender;

@end

@implementation ReportViewController

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
    // Do any additional setup after loading the view.
    self.reportTable.delegate = self;
    self.reportTable.dataSource = self;
    self.reportTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self initData];
}

-(void) initData
{
    AppDelegate *appdelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    User* user = appdelegate.user;
    _dataValues = [[NSMutableArray alloc] init];
    
    NSDate *startDate = [NSDate date];
    NSDate *endDate = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"yyyy-MM-dd"];
    
    NSDateFormatter *mdformat = [[NSDateFormatter alloc] init];
    [mdformat setDateFormat:@"M-d"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSArray* targets = [PersonalSet MR_findByAttribute:@"userId" withValue:user.userId andOrderBy:@"startDate" ascending:false inContext:[NSManagedObjectContext MR_defaultContext]];
    int index=0;
    for (PersonalSet *p in targets) {
        if (index>0) {
            break;
        }
        if (p.endDate!=nil&&p.endDate!=NULL && p.endDate!=@"") {
            endDate=p.endDate;
        }
        startDate = p.startDate;

        NSString *tmpStartTime = [NSString stringWithFormat:@"%@ 00:00:00",[formate stringFromDate:startDate]];
        NSString *tmpEndTime =[NSString stringWithFormat:@"%@ 23:59:59",[formate stringFromDate:endDate]];;
        
        startDate = [dateFormatter dateFromString:tmpStartTime];
        endDate = [dateFormatter dateFromString:tmpEndTime];
        
        //这里需要把开始时间格式为 0:0:0,结束时间格式为23:59:59
        
        NSTimeInterval time=[endDate timeIntervalSinceDate:p.startDate];
        int days = ((int)time)/(3600*24);
        if (days==0) {
            days=1;
        }
        NSString *report_desc=@"";
        NSString *comp_status_desc=@"";
        NSMutableArray* xLables=[NSMutableArray arrayWithCapacity:7];
        NSMutableArray* weightValues=[NSMutableArray arrayWithCapacity:7];
        NSMutableArray* fatValues =[NSMutableArray arrayWithCapacity:7];
        NSArray * fats = [User_Item_Info MR_findAllSortedBy:@"testDate" ascending:true withPredicate:[NSPredicate predicateWithFormat:@"userId==%d AND itemId==%d AND testDate>=%@ And testDate < %@",user.userId.intValue,[TestItemID getFat],startDate,endDate] inContext:[NSManagedObjectContext MR_defaultContext]];
        
        NSArray * weights = [User_Item_Info MR_findAllSortedBy:@"testDate" ascending:true withPredicate:[NSPredicate predicateWithFormat:@"userId==%d AND itemId==%d AND testDate>=%@ And testDate < %@",user.userId.intValue,[TestItemID getWeight],startDate,endDate] inContext:[NSManagedObjectContext MR_defaultContext]];
        
        report_desc = [self getReportTitle:weights stDate:startDate tWeight:p.targetWeight.floatValue];
        comp_status_desc = [self getCompletedDesc:weights tWeight:p.targetWeight.floatValue];
        
        NSMutableArray* tmpLables=[self getXLables:days sDate:startDate];
        NSDate *date = startDate;
        
        for (int i=0; i<tmpLables.count; i++) {
            NSDate *date1 = [tmpLables objectAtIndex:i];
            if (i==0) {
                date1=[date dateByAddingTimeInterval:(24*60*60)];
            }
            int weightCount=0;
            float weightSum=0;
            for (int j =0; j<weights.count; j++) {
                User_Item_Info* info = [weights objectAtIndex:j];
                float x =[info.testDate timeIntervalSinceDate:date];
                float y =[info.testDate timeIntervalSinceDate:date1];
                if (x>=0&&y<0 && info.testValue>0) {
                    NSLog(@"x=%.2f",x);
                    NSLog(@"y=%.2f",y);
                    weightSum += info.testValue.floatValue;
                    weightCount++;
                }
            }
            float weightAvg =0;
            if(weightCount>0)weightAvg=weightSum/weightCount;
            [weightValues addObject: [NSNumber numberWithFloat:weightAvg]];
            
            int fatCount=0;
            float fatSum=0;
            for (int j =0; j<fats.count; j++) {
                User_Item_Info* info = [fats objectAtIndex:j];
                float x =[info.testDate timeIntervalSinceDate:date];
                float y =[info.testDate timeIntervalSinceDate:date1];
                if (x>=0&&y<0 && info.testValue>0)  {
                    fatSum += info.testValue.floatValue;
                    fatCount++;
                }
            }
            float fatAvg =0;
            if(fatCount>0)fatAvg=fatSum/fatCount;
            [fatValues addObject: [NSNumber numberWithFloat:fatAvg]];
            [xLables addObject:[mdformat stringFromDate:date]];
            date=date1;
        }
        
        NSArray * sports = [UserCoreValues MR_findAllSortedBy:@"createTime" ascending:true withPredicate:[NSPredicate predicateWithFormat:@"userId==%d AND createTime>=%@ And createTime < %@",user.userId.intValue,startDate,endDate] inContext:[NSManagedObjectContext MR_defaultContext]];
        int sportCount =0;//calorieValue
        float sportSum=0;
        for (int i=0;i<sports.count; i++) {
            UserCoreValues *item =[sports objectAtIndex:i];
            sportCount++;
            sportSum+=item.calorieValue.floatValue;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"M-d"];

        NSString *_st =[dateFormatter stringFromDate:startDate];
        NSString *_et =[dateFormatter stringFromDate:endDate];
        
        NSString *sport_desc=[NSString stringWithFormat:@"在%@到%@期间，您共进行了%d次运动，共消耗%.f卡路里热量，为了健康，请您多参加体育运动。",_st,_et,sportCount,sportSum/1000];;
        
        NSArray * foods = [DalidFood MR_findAllSortedBy:@"intakeDate" ascending:true withPredicate:[NSPredicate predicateWithFormat:@"userId==%d AND intakeDate>=%@ And intakeDate < %@",user.userId.intValue,startDate,endDate] inContext:[NSManagedObjectContext MR_defaultContext]];
        int foodCount =0;
        float foodSum=0;
        for (int i=0;i<foods.count; i++) {
            DalidFood *item =[foods objectAtIndex:i];
            foodCount++;
            foodSum+=item.calorieValue.floatValue;
        }
        float foodAvg=0;
        if (foodCount>0) {
            foodAvg=foodSum/foodCount;
        }
        NSString *food_desc=[NSString stringWithFormat:@"在%@到%@期间，您共摄入了%.f卡路里热量，平均每天的摄入量为%.f卡路里，人体健康摄入量为600-800卡路里。",_st,_et,foodSum,foodAvg];
        
        ReportModel *model =[[ReportModel alloc] init];
        model.report_desc=report_desc;
        model.sport_desc=sport_desc;
        model.food_desc=food_desc;
        model.xLable=xLables;
        model.weightValues=weightValues;
        model.pfbValues=fatValues;
        model.comp_desc=comp_status_desc;
        [_dataValues addObject:model];
        
        index++;
    }
}

-(NSMutableArray*) getXLables:(int)days sDate:(NSDate*)startDate
{
    NSMutableArray *lables = [NSMutableArray arrayWithCapacity:7];
    
    //[lables addObject:startDate];
    int step = days / 7;
    if (days%7>0) {
        step++;
    }
    for (int i=1; i<=7; i++) {
        NSDate *nextDay=[startDate dateByAddingTimeInterval:(step*i*24*60*60)];
        [lables addObject:nextDay];
    }
    return lables;
}

-(NSString*)getReportTitle:(NSArray *)items stDate:(NSDate*)startDate tWeight:(float)targetWeight
{
    NSString *report_desc =@"";
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    [formate setDateFormat:@"M月d日"];
    NSString *sDate = [formate stringFromDate:startDate];
    
    NSString *status = @"未达成";
    float curWeight=0;
    if (items.count>0) {
        User_Item_Info *curItemInfo =[items objectAtIndex:items.count-1];
        curWeight = curItemInfo.testValue.floatValue;
    }
    
    if (targetWeight>=curWeight&&curWeight>0) {
        status=@"已达成";
    }
    report_desc= [NSString stringWithFormat:@"您%@设定体重目标%.1fkg",sDate,targetWeight];
    return report_desc;
}

-(NSString*) getCompletedDesc:(NSArray *)items tWeight:(float)targetWeight
{
    NSString *report_desc =@"";
    
    NSString *status = @"未达成";
    float curWeight=0;
    if (items.count>0) {
        User_Item_Info *curItemInfo =[items objectAtIndex:items.count-1];
        curWeight = curItemInfo.testValue.floatValue;
    }
    
    if (targetWeight>=curWeight&&curWeight>0) {
        status=@"已达成";
    }
    report_desc= [NSString stringWithFormat:@"(%@)",status];
    return report_desc;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataValues.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReportTableViewCell"];
    if (_dataValues.count==0) {
        return cell;
    }
    ReportModel *model = [_dataValues objectAtIndex:indexPath.row];
    if (model==nil||model==NULL) {
        return  cell;
    }
    //报搞表头
    cell.report_title.text=model.report_desc;
    cell.comp_title.text=model.comp_desc;
    if ([model.comp_desc isEqualToString:@"(已达成)"]) {
        cell.comp_title.textColor = [UIColor colorWithRed:(69/255.0) green:(190/255.0) blue:(159/255.0) alpha:1];
    }
    else
    {
        cell.comp_title.textColor = [UIColor colorWithRed:(255/255.0) green:(240/255.0) blue:(0/255.0) alpha:1];
    }
    //报告图表
    NSMutableArray * ArrayOfValues = [[NSMutableArray alloc] init];
    NSMutableArray * ArrayOfDates = model.xLable;
    
    ArrayOfValues = model.weightValues;
    // The labels to report the values of the graph when the user touches it
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    float widthLine = 2.0;
    [dic setValue:[NSString stringWithFormat:@"%f",widthLine] forKey:@"widthLine"];
    
    [dic setValue:ArrayOfValues forKey:@"values"];
    [dic setValue:ArrayOfDates forKey:@"dates"];
    [dic setValue:[UIColor clearColor] forKey:@"colorTop"];
    [dic setValue:[UIColor clearColor] forKey:@"colorBottom"];
    [dic setValue:[UIColor yellowColor] forKey:@"colorLine"];
    [dic setValue:[UIColor whiteColor] forKey:@"colorXaxisLabel"];
    [dic setValue:[UIColor whiteColor] forKey:@"colorVerticalLine"];
    [dic setValue:[UIColor greenColor] forKey:@"bigRoundColor"];
    [dic setValue:[UIColor yellowColor] forKey:@"smallRoundColor"];
    [dic setValue:[UIColor clearColor] forKey:@"barGraphColor"];
    CGRect frame = cell.chart_scroll_view.frame;
    frame.origin.x = 15;
    frame.origin.y = 5;
    frame.size.width-=30;
    frame.size.height-=10;
    
    LineGraphView * graphView = [[LineGraphView alloc]initWithDictionary:dic AndFrame:frame];
    [graphView addLine: [NSArray arrayWithArray:model.pfbValues]];
    [cell.chart_scroll_view addSubview:graphView];
    
    //运动报告
    cell.sport_desc.text=model.sport_desc;
    //膳食报告
    cell.food_desc.text = model.food_desc;
    
    AppDelegate *appdelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (appdelegate.deviceType==1) {
        cell.sport_container.hidden=YES;
    }
    return cell;
    
}
-(double)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ReportTableViewCell"];
    return cell.frame.size.height-10;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)BackAction:(id)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end
