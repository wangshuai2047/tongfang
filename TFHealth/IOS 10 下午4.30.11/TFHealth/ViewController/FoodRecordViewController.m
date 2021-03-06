//
//  FoodRecordViewController.m
//  TFHealth
//
//  Created by hzth hzth－mac2 on 6/12/14.
//  Copyright (c) 2014 studio37. All rights reserved.
//

#import "FoodRecordViewController.h"
#import "PPiFlatSegmentedControl.h"
#import "SportItem.h"
#import "AppCloundService.h"
#import "AddFoodViewController.h"
#import "DalidFood.h"
#import "FoodDictionary.h"
#import "AppDelegate.h"
#import "UIViewController+CWPopup.h"
#import "TodayMealViewController.h"
#import "NTSlidingViewController.h"
#import "UIViewController+MMDrawerController.h"
#import "FoodClass.h"

@interface FoodRecordViewController ()<PPiFlatSegmentedDelegate,ServiceObjectDelegate,ServiceCallbackDelegate,UITextFieldDelegate>{
    int selectItemTag;
    int showItemTag;
    NSMutableArray *usualyFoodArray;
    NSDictionary *addCustomFoodDict;
}
@property (weak, nonatomic) IBOutlet UIScrollView *recordScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *usualyScrollView;

@property (weak, nonatomic) IBOutlet UITextField *customNameTextF;
@property (weak, nonatomic) IBOutlet UITextField *customCaloriesTextF;
@property (weak, nonatomic) IBOutlet UITextField *customGramTextF;
@property (weak, nonatomic) IBOutlet UIView *drop_container;

//选择早中晚餐view

@property (weak, nonatomic) IBOutlet UIView *selectItemView;
@property (weak, nonatomic) IBOutlet UILabel *selectResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *allClassTextView;

@property (weak, nonatomic) IBOutlet UIButton *selectResultButton;
@property (weak, nonatomic) IBOutlet UIView *seletItemView_S;
@property (weak, nonatomic) IBOutlet UIView *foodClassDropList;
@property (weak, nonatomic) IBOutlet UIView *classDropView;
@property (weak, nonatomic) IBOutlet UIScrollView *classScrollView;

//请求食物字典列表数组-刘飞-7.12
@property (strong,nonatomic) NSMutableArray* foodArray;
@property (nonatomic,retain) NSMutableArray *usualyFoodArray;

@property (weak, nonatomic) IBOutlet UIView *commonlyUsedView;
@property (weak, nonatomic) IBOutlet UIView *labraryView;
- (IBAction)dropClicked:(id)sender;

#define Font 15
@end

@implementation FoodRecordViewController
@synthesize superview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [_customGramTextF resignFirstResponder];
    [_customCaloriesTextF resignFirstResponder];
    [_customNameTextF resignFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [self getUsualyFoodDictionary];
    [self getSystemFoodDictionary];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.foodArray = [NSMutableArray arrayWithCapacity:0];
    PPiFlatSegmentedControl *segmented=[[PPiFlatSegmentedControl alloc] initWithFrame:CGRectMake(10,80, 300, 30) items:@[@{@"text":@"食品营养库",@"icon":@"icon-food"},@{@"text":@"我的项目",@"icon":@"icon-star"},@{@"text":@"自定义",@"icon":@"icon-coffee"}                                                                                                                                         ]iconPosition:IconPositionRight andSelectionBlock:^(NSUInteger segmentIndex) {}];
    segmented.color=[UIColor clearColor];
    segmented.borderWidth=1;
    segmented.borderColor= COLOR(54, 148, 254, 1);
    segmented.selectedColor=COLOR(54, 148, 254, 1);;
    segmented.textAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                               NSForegroundColorAttributeName:[UIColor whiteColor]};
    segmented.selectedTextAttributes=@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                       NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    segmented.enabled = YES;
    segmented.userInteractionEnabled  = YES;
    segmented.delegate = self;
    [self.view addSubview:segmented];
    
    showItemTag = 0;
    selectItemTag = 0;
    
    //取本地数据库中 FoodDictionary
    //[self getSystemFoodDictionary];
    [self getUsualyFoodDictionary];
    //取系统食品库
    [self downloadFoodClass];
    
    [self initUI];
    
}

-(void)downloadFoodClass
{
    NSMutableArray* foodClassArray = [NSMutableArray arrayWithArray:[FoodClass MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]]];
    if (foodClassArray.count==0) {
        //本地没有数据，从网络下载，适用于安装软件首次使用些功能
        AppCloundService * foodClassArrayRequest = [[AppCloundService alloc]initWidthDelegate:self];
        [foodClassArrayRequest getFoodClass];
    }
    else
    {
        [self loadFoodClass:foodClassArray];
        [self getSystemFoodDictionary];
    }
}

-(void)downloadFoodDict
{
    AppCloundService * foodArrayRequest = [[AppCloundService alloc]initWidthDelegate:self];
    [foodArrayRequest getFoodDictionary];
}

-(void)loadFoodClass:(NSMutableArray *)foodClassArray
{
    if (foodClassArray!=nil) {
        int i=0;
        
        CGRect rect = self.classDropView.frame;
        rect.origin.y=i*36;
        rect.size.height=36;
        
        UIButton *item = [[UIButton alloc]init];
        [item setTitle:@"全部分类" forState:UIControlStateNormal];
        item.tag=-1;
        item.frame=rect;
        item.showsTouchWhenHighlighted=YES;
        item.font=[UIFont fontWithName:@"Helvetica" size:16];
        [item addTarget:self action:@selector(ItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.classScrollView addSubview:item];
        i++;
        
        self.classScrollView.contentSize = CGSizeMake(self.classDropView.frame.size.width,(foodClassArray.count+2)*36);
        for (FoodClass * dic in foodClassArray) {
            CGRect rect = self.classDropView.frame;
            rect.origin.y=i*36;
            rect.size.height=36;
            UIButton *item = [[UIButton alloc]init];
            [item setTitle:dic.cName forState:UIControlStateNormal];
            item.tag=dic.classId.intValue;
            item.frame=rect;
            item.showsTouchWhenHighlighted=YES;
            item.font=[UIFont fontWithName:@"Helvetica" size:16];
            [item addTarget:self action:@selector(ItemSelected:) forControlEvents:UIControlEventTouchUpInside];

            [self.classScrollView addSubview:item];
            i++;
        }
        rect = self.classDropView.frame;
        rect.origin.y=i*36;
        rect.size.height=36;

        item = [[UIButton alloc]init];
        [item setTitle:@"自定义" forState:UIControlStateNormal];
        item.tag=0;
        item.frame=rect;
        item.showsTouchWhenHighlighted=YES;
        item.font=[UIFont fontWithName:@"Helvetica" size:16];
        [item addTarget:self action:@selector(ItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.classScrollView addSubview:item];
    }
}
-(void)ItemSelected:(id)sender{
    UIButton *button = (UIButton * )sender;
    NSArray* dict = nil;
    if(button.tag!=-1)
    {
        dict = [FoodDictionary MR_findAllSortedBy:@"foodName" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"classId==%d",button.tag] inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    else
    {
        dict = [FoodDictionary MR_findAll];
    }
    NSMutableArray *myMutableArray = [dict mutableCopy];
    [self updateScrollViewData:myMutableArray AndScrollView:self.myScrollView];
    self.classDropView.hidden=YES;
    self.allClassTextView.text=button.titleLabel.text;
}

- (IBAction)dropClicked:(id)sender {
    self.classDropView.hidden=!self.classDropView.hidden;
}

-(void)initUI
{
    UIColor *borderColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
    
    _commonlyUsedView.layer.masksToBounds = YES;
    _commonlyUsedView.layer.cornerRadius = 6.0;
    _commonlyUsedView.layer.borderWidth = 1.0;
    _commonlyUsedView.layer.borderColor = [borderColor CGColor];
    _commonlyUsedView.layer.backgroundColor=[borderColor CGColor];
    
    _labraryView.layer.masksToBounds = YES;
    _labraryView.layer.cornerRadius = 6.0;
    _labraryView.layer.borderWidth = 1.0;
    _labraryView.layer.borderColor = [borderColor CGColor];
    _labraryView.layer.backgroundColor=[borderColor CGColor];
    
    _foodClassDropList.layer.masksToBounds = YES;
    _foodClassDropList.layer.cornerRadius = 6.0;
    _foodClassDropList.layer.borderWidth = 1.0;
    _foodClassDropList.layer.borderColor = [borderColor CGColor];
    _foodClassDropList.layer.backgroundColor=[borderColor CGColor];
    
    _classDropView.layer.masksToBounds = YES;
    _classDropView.layer.cornerRadius = 6.0;
    _classDropView.layer.borderWidth = 1.0;
    _classDropView.layer.borderColor = [borderColor CGColor];
    //_classDropView.layer.backgroundColor=[borderColor CGColor];
    
    _drop_container.layer.masksToBounds = YES;
    _drop_container.layer.cornerRadius = 6.0;
    _drop_container.layer.borderWidth = 1.0;
    _drop_container.layer.borderColor = [borderColor CGColor];
    _drop_container.layer.backgroundColor=[borderColor CGColor];
    _drop_container.hidden=true;
    
}

#pragma  mark -- Service Delegate -- 刘飞
-(void)requestSuccessed:(NSString *)request
{
    
}
-(void)requestFailed:(NSString *)request
{
    NSLog(@"food record failure");
}
-(void)serviceSuccessed:(NSDictionary *)keyValues pMethod:(NSString*)method
{
    
    if ([method isEqualToString:@"AddCustomsFoodJson"]){ //添加自定义膳食
        if ([keyValues[@"res"] intValue] != 0 ) {
            
            NSArray *array1 = [FoodDictionary MR_findByAttribute:@"foodName" withValue:_customNameTextF.text inContext:[NSManagedObjectContext MR_defaultContext]];
            if (array1.count > 0) {
                [self showAlertWithMessage:@"该膳食名称已存在" cancelButtonTitle:@"确定"];
            }
            else {
                FoodDictionary *food = [FoodDictionary MR_createEntity];
                [food setFoodName:addCustomFoodDict[@"foodName"]];
                [food setFoodId:[NSNumber numberWithInt:[keyValues[@"res"] intValue]]];
                [food setClassId:[NSNumber numberWithInt:[keyValues[@"classId"] intValue]]];
                [food setCaloriesValue:addCustomFoodDict[@"caloriesValue"]];
                [food setGramValue:addCustomFoodDict[@"gramValue"]];
                [[NSManagedObjectContext MR_defaultContext] MR_save];
                [self showAlertWithMessage:@"您的膳食已成功添加到食品营养库。" cancelButtonTitle:@"确定"];
                [self changeToAddFoodVC:food];
            }
            NSArray *array = [FoodDictionary MR_findAll];
            NSLog(@"array :%@",array);
        } else {
            [self showAlertWithMessage:@"添加自定义膳食失败，请稍后重试" cancelButtonTitle:@"确定"];
        }
    }
    else if([method isEqualToString:@"GetFoodClassJson"])
    {
        for (NSDictionary * dic in keyValues) {
            FoodClass *fClass = [FoodClass MR_createEntity];
            [fClass setClassId:[NSNumber numberWithInt:[dic[@"ClassId"]intValue]]];
            [fClass setCName:dic[@"ClassName"]];
            if (dic[@"ClassDesc"]!=nil&& (NSNull *)dic[@"ClassDesc"] != [NSNull null]) {
                [fClass setClassDesc:dic[@"ClassDesc"]];
            }
            [[NSManagedObjectContext MR_defaultContext] MR_save];
        }
        NSMutableArray* foodClassArray = [NSMutableArray arrayWithArray:[FoodClass MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]]];
        [self loadFoodClass:foodClassArray];
        [self downloadFoodDict];
    }
    else if ([method isEqualToString:@"GetFoodDictionaryJson"]) { //返回系统膳食
        /*
         if (_foodArray.count > 0) {
         [_foodArray removeAllObjects];
         }
         */
        for (NSDictionary * dic in keyValues) {
            /*
             NSArray *array = [FoodDictionary MR_findByAttribute:@"foodId" withValue:dic[@"FoodID"]  inContext:[NSManagedObjectContext MR_defaultContext]];
             if (array.count > 0) {
             NSLog(@"已有 ：%@",dic[@"FoodName"]);
             } else {*/
            FoodDictionary *fDictionary = [FoodDictionary MR_createEntity];
            [fDictionary setClassId:[NSNumber numberWithInt:[dic[@"ClassId"]intValue]]];
            [fDictionary setFoodName:dic[@"FoodName"]];
            [fDictionary setFoodId:[NSNumber numberWithInt:[dic[@"FoodID"]intValue]]];
            [fDictionary setGramValue:[NSNumber numberWithInt:[dic[@"GramValue"] intValue]]];
            [fDictionary setCaloriesValue:[NSNumber numberWithInt:[dic[@"CaloriesValue"]intValue]]];
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
            //}
        }
        [self getSystemFoodDictionary];
    }
    //
}

-(void)getSystemFoodClass
{
}

-(void)getSystemFoodDictionary {
    
    _foodArray = [NSMutableArray arrayWithArray:[FoodDictionary MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]]];
    
    
    [self updateScrollViewData:_foodArray AndScrollView:self.myScrollView];
}
-(void)getUsualyFoodDictionary {
    _usualyFoodArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *array = [DalidFood MR_findAllInContext:[NSManagedObjectContext MR_defaultContext]];
    for (int i = 0; i < MIN(12,array.count);  i ++) {
        BOOL hasIt = NO;
        DalidFood *daliF = [array objectAtIndex:i];
        if (daliF!=nil&&daliF.foodName!=nil) {
            FoodDictionary *dict = [[FoodDictionary MR_findByAttribute:@"foodName" withValue:daliF.foodName  inContext:[NSManagedObjectContext MR_defaultContext]] firstObject];
            if (dict!=nil) {
                for (FoodDictionary *d in _usualyFoodArray) {
                    if ([d.foodName isEqualToString:dict.foodName]) {
                        hasIt = YES;
                    }
                }
                if (!hasIt) {
                    [_usualyFoodArray addObject:dict];
                }
            }
        }
    }
    [self updateScrollViewData:_usualyFoodArray AndScrollView:self.usualyScrollView];
}
-(void)serviceFailed:(NSString *)message pMethod:(NSString*)method
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"添加食物失败，请检查网络连接" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"food record request failure");
}

#pragma mark -- self methods
/*
 添加自定义膳食
 */
- (IBAction)saveButtonClick:(id)sender {
    if ([_customNameTextF.text length] < 1 || [_customNameTextF.text isEqual:[NSNull null]]) {
        [self showAlertWithMessage:@"请填写食物名称" cancelButtonTitle:@"确认"];
        return ;
    }
    if (![self isValueFloadValue:_customCaloriesTextF.text]) {
        [self showAlertWithMessage:@"单位摄入量卡路里数值格式错误,请检查后提交" cancelButtonTitle:@"确认"];
        return ;
    }
    if (![self isValueFloadValue:_customGramTextF.text]) {
        [self showAlertWithMessage:@"单位摄入量数值格式错误,请检查后提交" cancelButtonTitle:@"确认"];
        return;
    }
    
    AppDelegate *appdelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    User* user = appdelegate.user;
    NSLog(@"userid :%d , foodName :%@ ,cal:%@ , gram :%@",[user.userId intValue],_customNameTextF.text,_customCaloriesTextF.text,_customGramTextF.text);
    addCustomFoodDict = @{@"foodName": _customNameTextF.text,
                          @"caloriesValue":[NSNumber numberWithFloat:[_customCaloriesTextF.text floatValue]],
                          @"gramValue":[NSNumber numberWithFloat:[_customGramTextF.text floatValue]],
                          };
    AppCloundService * addCustomsFood = [[AppCloundService alloc]initWidthDelegate:self];
    [addCustomsFood addCustomsFoodWithUserId:[user.userId intValue] classId:3 foodName:_customNameTextF.text caloriesValue:[_customCaloriesTextF.text floatValue] gramValue:[_customGramTextF.text floatValue] isCustoms:1];
    
}


/*
 选择早中晚餐 刘飞 --
 */
- (IBAction)selectetItem:(id)sender {
    UIButton *button = (UIButton * )sender;
    
    //    CGPoint p = self.recordScrollView.contentOffset;
    //    if (p.x < 100) {
    //        switch (button.tag - 600) {
    //            case 0:
    //                [_selectResultButton setTitle:@"早餐" forState:UIControlStateNormal];
    //                break;
    //            case 1:
    //                [_selectResultButton setTitle:@"中餐" forState:UIControlStateNormal];
    //                break;
    //            case 2:
    //                [_selectResultButton setTitle:@"晚餐" forState:UIControlStateNormal];
    //                break;
    //            default:
    //                break;
    //        }
    //        showItemTag = button.tag - 600;
    //        _seletItemView_S.hidden = YES;
    //    } else {
    switch (button.tag - 600) {
        case 0:
            _selectResultLabel.text = @"早餐";
            break;
        case 1:
            _selectResultLabel.text = @"午餐";
            break;
        case 2:
            _selectResultLabel.text = @"晚餐";
            break;
        default:
            break;
    }
    selectItemTag = button.tag - 600;
    _selectItemView.hidden = YES;
    //    }
    
    
    
}
- (IBAction)showSelectItem:(id)sender {
    _selectItemView.hidden = NO;
}
- (IBAction)showSelectItem_S:(id)sender {
    _seletItemView_S.hidden = NO;
}

- (IBAction)backButtonClick:(id)sender {
    TodayMealViewController *uv = (TodayMealViewController *)superview;
    [uv dismissPopup];
    /*
     TodayMealViewController *modal = [self.storyboard instantiateViewControllerWithIdentifier:@"TodayMealViewController"];
     NTSlidingViewController *uv = (NTSlidingViewController *)superview;
     UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:uv];
     [self presentViewController:nav animated:YES completion:^{
     
     }];
     */
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)updateScrollViewData:(NSMutableArray*)dataArray AndScrollView:(UIScrollView*)scrollView
{
    for (UIView * subview in scrollView.subviews) {
        [subview removeFromSuperview];
    }
    float width = scrollView.frame.size.width/3;
    float height = 25;
    scrollView.contentSize = CGSizeMake(width*3,height*((dataArray.count+3)/2));
    for (int i = 0; i<(dataArray.count+1)/2; i++) {
        for (int j = 0 ; j<2;j++ )
        {
            if ((j+1)+i*2>dataArray.count) {
                break;
            }
            FoodDictionary *fDictionary = [dataArray objectAtIndex:i*2+j];
            //            NSString * item = [dataArray objectAtIndex:i*2+j];
            UILabel * sportNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(140*j+10, 25*i+10, 140, 20)];
            sportNameLabel.textColor = UIColorFromRGB(0x9be2ff);
            sportNameLabel.text = fDictionary.foodName;
            sportNameLabel.font = [UIFont systemFontOfSize:Font];
            sportNameLabel.textAlignment = NSTextAlignmentLeft;
            sportNameLabel.tag = fDictionary.foodId.intValue;
            //点击事件
            sportNameLabel.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AddFoodLabelClick:)];
            [sportNameLabel addGestureRecognizer:singleTap1];
            [scrollView addSubview:sportNameLabel];
        }
    }
}
//添加餐点
-(void)AddFoodLabelClick:(UITapGestureRecognizer*)tap
{
    UILabel * label = (UILabel*)[tap view];
    FoodDictionary * fDictionary = [FoodDictionary MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"foodId==%d",label.tag]];
    
    //    if ([label.superview isEqual:_myScrollView]) {
    //        if (self.foodArray.count > label.tag) {
    //            fDictionary = [self.foodArray objectAtIndex:label.tag];
    //        }
    //    }else if ([label.superview isEqual:_usualyScrollView]) {
    //        if (usualyFoodArray.count > label.tag) {
    //            fDictionary = [usualyFoodArray objectAtIndex:label.tag];
    //        }
    //    }
    if(fDictionary!=nil)
    {
        [self changeToAddFoodVC:fDictionary];
    }
}
-(void)changeToAddFoodVC:(FoodDictionary *)foodDict {
    
    AddFoodViewController * afvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"AddFoodViewController"];
    NTSlidingViewController *uv = (NTSlidingViewController *)superview;
    [uv setIndexText:1 txt:@"添加膳食"];
    [afvc setFoodDictionary:foodDict];
    [self presentPopupViewController:afvc animated:true completion:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.recordScrollView.contentSize = CGSizeMake(320*2, 439);
    
}
-(void)PPiFlatSegmentedSelectedSegAtIndex:(int)index
{
    selectItemTag = 0;
    _selectResultLabel.text = @"早餐";
    //    [_selectResultButton setTitle:@"早餐" forState:UIControlStateNormal];
    [self.recordScrollView setContentOffset:CGPointMake(index*320, 0)];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)showAlertWithMessage:(NSString *)message cancelButtonTitle:(NSString *)cancel {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:cancel otherButtonTitles:nil, nil];
    [alert show];
}

-(BOOL)isValueFloadValue:(NSString *)str {
    NSString *floatRegex = @"^(([0-9]+\.[0-9]*[1-9][0-9]*)|([0-9]*[1-9][0-9]*\.[0-9]+)|([0-9]*[1-9][0-9]*))$";
    NSPredicate *floatPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",floatRegex];
    return [floatPredicate evaluateWithObject:str];
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
@end
