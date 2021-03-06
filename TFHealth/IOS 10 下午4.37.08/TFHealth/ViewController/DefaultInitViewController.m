//
//  RegisterViewController.m
//  TFHealth
//
//  Created by chenzq on 14-7-1.
//  Copyright (c) 2014年 studio37. All rights reserved.
//

#import "DefaultInitViewController.h"
#import "WriteInformationViewController.h"
#import "AppCloundService.h"
#import "CXAlertView.h"
#import "UserLog.h"
#import "UIColor+BFPaperColors.h"
#import "UserDevices.h"
#import "SportCoefficient.h"
#import "AppDelegate.h"

@interface DefaultInitViewController ()
- (IBAction)RegisterNext:(id)sender;

- (IBAction)backupView:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *itemsContainerView;
@property (strong,nonatomic) NSMutableArray * itemsArray;
@property (strong,nonatomic) NSMutableArray * itemsNameArray;

@property BFPaperCheckbox *paperCheckbox;
@property BFPaperCheckbox *paperCheckbox2;
@property UILabel *paperCheckboxLabel;
@property UILabel *paperCheckboxLabel2;

@end

@implementation DefaultInitViewController

- (IBAction)textFieldDoneEditing:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)backUpView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
    _itemsArray = [[NSMutableArray alloc]init];
    _itemsNameArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    self.paperCheckbox = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.paperCheckbox.tag = 1001;
    self.paperCheckbox.delegate = self;
    [self.containerView addSubview:self.paperCheckbox];
    
    // Set up first checkbox label:
    self.paperCheckboxLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 100, 31)];
    self.paperCheckboxLabel.text = @"手环用户";
    self.paperCheckboxLabel.font=[UIFont fontWithName:@"Helvetica" size:16];
    self.paperCheckboxLabel.textColor=[UIColor whiteColor];
    self.paperCheckboxLabel.backgroundColor = [UIColor clearColor];
    self.paperCheckboxLabel.center = CGPointMake(self.paperCheckbox.center.x + ((2 * self.paperCheckboxLabel.frame.size.width) / 3), self.paperCheckbox.center.y);
    [self.containerView addSubview:self.paperCheckboxLabel];
    
    
    // Set up second checkbox and customize it:
    self.paperCheckbox2 = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(200, 0, 50, 50)];
    self.paperCheckbox2.center = CGPointMake(self.paperCheckbox2.frame.origin.x, self.paperCheckbox.center.y);
    self.paperCheckbox2.tag = 1002;
    self.paperCheckbox2.delegate = self;
    self.paperCheckbox2.rippleFromTapLocation = NO;
    self.paperCheckbox2.tapCirclePositiveColor = [UIColor paperColorAmber]; // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.paperCheckbox2.tapCircleNegativeColor = [UIColor paperColorRed];   // We could use [UIColor colorWithAlphaComponent] here to make a better tap-circle.
    self.paperCheckbox2.checkmarkColor = [UIColor paperColorLightBlue];
    [self.containerView addSubview:self.paperCheckbox2];
    
    // Set up second checkbox label:
    self.paperCheckboxLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(300, 0, 100, 31)];
    self.paperCheckboxLabel2.text = @"秤用户";
    self.paperCheckboxLabel2.font=[UIFont fontWithName:@"Helvetica" size:16];
    self.paperCheckboxLabel2.textColor=[UIColor whiteColor];
    self.paperCheckboxLabel2.backgroundColor = [UIColor clearColor];
    self.paperCheckboxLabel2.center = CGPointMake(self.paperCheckbox2.center.x + ((2 * self.paperCheckboxLabel2.frame.size.width) / 3), self.paperCheckbox2.center.y);
    [self.containerView addSubview:self.paperCheckboxLabel2];
    [self initItems];
    [self initUI];
}

-(void) initItems
{
    NSArray *items = [SportCoefficient MR_findAll];
    if (items.count>0) {
        [self loadItems:items];
    }
    else  //当本地没有数据时联网获取
    {
        AppCloundService* s= [[AppCloundService alloc] initWidthDelegate:self];
        [s GetCoefficients];
    }
}

-(void)loadItems:(NSArray*)items
{
    int i =100;   //为了防止TAG重复，i从100开始
    int curIndex =0;
    for (SportCoefficient *item in items) {
        BFPaperCheckbox *box = [[BFPaperCheckbox alloc] initWithFrame:CGRectMake(0, (i-100)*50, 50, 50)];
        box.tag = i;
        box.titleLabel.text=item.itemName;
        box.delegate = self;
        [self.itemsContainerView addSubview:box];
        [_itemsNameArray addObject:item.itemName];
        
        // Set up first checkbox label:
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(120, (i-100)*50, 200, 31)];
        label.text = item.itemName;
        label.font=[UIFont fontWithName:@"Helvetica" size:16];
        label.textColor=[UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.center = CGPointMake(self.paperCheckbox.center.x + ((2 * label.frame.size.width) / 3), box.center.y);
        [self.itemsContainerView addSubview:label];
        i++;
    }
    [self.itemsContainerView setContentSize:CGSizeMake(240, (i-100)*50+50)];
    //[self.itemsContainerView reloadData];
}

-(void)serviceSuccessed:(NSDictionary*)keyValues pMethod:(NSString*)method
{
    if ([method isEqualToString:@"UpLoadUserConfigSportsJson"]) {
        //上传默认项目成功
        UIViewController * hsvc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateInitialViewController];
        [self presentViewController:hsvc animated:YES completion:nil];
        
    }
    else if([method isEqualToString:@"SetUserDevicesJson"])
    {
        //设置用户类型成功
        [self UploadSports];
    }
    else if(keyValues.count>0 )
    {
        NSMutableArray *tmp =[[NSMutableArray alloc]init];
        for (NSDictionary *dict in keyValues) {
            SportCoefficient *coefficient = [SportCoefficient MR_createEntity];
            coefficient.itemId=[dict objectForKey:@"sportId"];
            coefficient.itemName =[dict objectForKey:@"sportName"];
            coefficient.coefficientValue =[dict objectForKey:@"coefficientValue"];
            [[NSManagedObjectContext MR_defaultContext] MR_save];
            [tmp addObject:coefficient];
        }
        [self loadItems:tmp];
    }
}

-(void)serviceFailed:(NSString*) message pMethod:(NSString*)method
{
    
}

-(void) initUI
{
    UIColor *borderColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:0.2];
    _itemsContainerView.layer.masksToBounds = YES;
    _itemsContainerView.layer.cornerRadius = 6.0;
    _itemsContainerView.layer.borderWidth = 1.0;
    _itemsContainerView.layer.borderColor = [borderColor CGColor];
    _itemsContainerView.layer.backgroundColor=[borderColor CGColor];
}

#pragma mark - BFPaperCheckbox Delegate
- (void)paperCheckboxChangedState:(BFPaperCheckbox *)checkbox
{
    if (checkbox.tag>=1000) {
        return;
    }
    BOOL isHas = false;
    for (int i=0; i<_itemsArray.count; i++) {
        NSInteger tmp = [[_itemsArray objectAtIndex:i] integerValue];
        if (tmp==checkbox.tag) {
            isHas=true;
            break;
        }
    }
    if (!isHas) {
        if (checkbox.isChecked) {
            [_itemsArray addObject:[NSNumber numberWithInt:checkbox.tag]];
        }
    }
    else
    {
        if (!checkbox.isChecked) {
            [_itemsArray removeObject:[NSNumber numberWithInt:checkbox.tag]];
        }
    }
    
    /*
     if (checkbox.tag == 1001) {      // First box
     self.paperCheckboxLabel.text = self.paperCheckbox.isChecked ? @"BFPaperCheckbox [ON]" : @"BFPaperCheckbox [OFF]";
     }
     else if (checkbox.tag == 1002) { // Second box
     self.paperCheckboxLabel2.text = self.paperCheckbox2.isChecked ? @"Customized [ON]" : @"Customized [OFF]";
     }
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)RegisterNext:(id)sender {
    if (self.paperCheckbox.isChecked==false&& self.paperCheckbox2.isChecked== false) {
        [self showSystemAlert:@"请至少选择一个您使用的设备类型。"];
        return;
    }
    
    if (_itemsArray.count<3) {
        [self showSystemAlert:@"请选择三个您平时喜欢的运动项目。"];
        return;
    }

    [self saveUserLog];
    [self saveDevice];
    
}

-(void)UploadSports
{
    NSString *itemName1=@"";
    NSString *itemName2=@"";
    NSString *itemName3=@"";
    for (int i=0; i<_itemsArray.count&&i<3; i++) {
        NSInteger tmp = [[_itemsArray objectAtIndex:i] integerValue]-100;
        if (i==0) {
            itemName1=[_itemsNameArray objectAtIndex:tmp];
        }
        else if (i==1) {
            itemName2=[_itemsNameArray objectAtIndex:tmp];
        }
        else if (i==2) {
            itemName3=[_itemsNameArray objectAtIndex:tmp];
        }
    }
    AppCloundService* s= [[AppCloundService alloc] initWidthDelegate:self];
    [s UploadDefaultSports:self.userId sportName1:itemName1 sportName2:itemName2 sportName3:itemName3];
}

-(void)saveDevice
{
    UserDevices *device = [UserDevices MR_createEntity];
    device.userName = _username;
    if (self.paperCheckbox.isChecked&&self.paperCheckbox2.isChecked) {
        device.deviceType=[NSNumber numberWithInt:2];
    }
    else if(self.paperCheckbox.isChecked)
    {
        device.deviceType=[NSNumber numberWithInt:0];
    }
    else if(self.paperCheckbox2.isChecked)
    {
        device.deviceType=[NSNumber numberWithInt:1];
    }
    else
    {
        device.deviceType=[NSNumber numberWithInt:2];
    }
    [[NSManagedObjectContext MR_defaultContext] MR_save];
    
    AppDelegate *appdelegate =(AppDelegate*) [[UIApplication sharedApplication] delegate];
    appdelegate.deviceType = device.deviceType.intValue;
    
    AppCloundService* s= [[AppCloundService alloc] initWidthDelegate:self];
    [s UploadUserDevices:self.userId userType:[NSString stringWithFormat:@"%@",device.deviceType]];
}

-(void)saveUserLog
{
    UserLog *user = [UserLog MR_createEntity];
    user.lastLoginTime=[NSDate date];
    user.username=_username;
    [[NSManagedObjectContext MR_defaultContext] MR_save];
}

- (IBAction)backupView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showSystemAlert:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:sender delegate:nil cancelButtonTitle:@"好" otherButtonTitles: nil];
    
    [alertView show];
}

-(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
