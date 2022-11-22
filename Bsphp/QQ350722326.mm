//
//  ViewController.h
//  Radar
//
//  Created by 十三哥 on 2022/8/19.
//
#import "MBProgressHUD+NJ.h"
#import "PubgLoad.h"
#import "QQ350722326.h"
#import "LRKeychain.h"
#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>
#import "NSString+MD5.h"
#import "Config.h"
#import "UIDevice+VKKeychainIDFV.h"
#import <AdSupport/ASIdentifierManager.h>
#import "MBProgressHUD.h"
#include <sys/sysctl.h>
#include <string>
#import <dlfcn.h>
#import "SCLAlertView.h"
static NSTimer*timer;
static NSString* DQTC;//到期时间弹窗
static NSString* UDIDORIDFA;//验证udid还是idfa
static NSString* YZBB;//验证版本更新
static NSString* GZB;//过直播
static NSString* YZ000;//验证机器码是否是
static UITextField *textField;
static UIView *view;
static UIView *aview;
static NSDictionary * baseDict;
static NSString *vdate;
@implementation NSObject (checkStatus)
+(void)load
{
    [NSObject 描述];
}
-(void)描述{
    static NSString*描述;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"api"] =@"miao.in";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    param[@"BSphpSeSsL"] = [dateStr MD5Digest];
    NSDate *date = [NSDate date];
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate * nowDate = [date dateByAddingTimeInterval:interval];
    NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    param[@"date"] = nowDateStr;
    param[@"md5"] = @"";
    param[@"mutualkey"] = BSPHP_MUTUALKEY;
    [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (dict) {
            描述 = dict[@"response"][@"data"];
            NSLog(@"描述=%@",描述);
            NSArray *arr = [描述 componentsSeparatedByString:@"\n"];
            DQTC=arr[0];
            UDIDORIDFA=arr[1];
            YZBB=arr[2];
            GZB=arr[3];
            YZ000=arr[4];
            if ([GZB containsString:@"YES"]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"GZB"];
            }else{
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"GZB"];
            }
        }
    } failure:^(NSError *error) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
            //没网络的情况
            //[NSObject CodeConfig];
            [NSObject Bsphp];
        });
    }];
}
-(void)Bsphp{
    if(![NSObject getIDFA])return;
    NSString*udid=[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    if (udid.length>5) {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"km"] != nil)
        {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"api"] = @"login.ic";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
            param[@"BSphpSeSsL"] = [dateStr MD5Digest];
            NSDate *date = [NSDate date];
            NSTimeZone * zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:date];
            NSDate * nowDate = [date dateByAddingTimeInterval:interval];
            NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
            param[@"date"] = nowDateStr;
            param[@"md5"] = @"";
            param[@"mutualkey"] = BSPHP_MUTUALKEY;
            param[@"icid"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"km"];
            param[@"icpwd"] = @"";
            param[@"key"] = udid;
            param[@"maxoror"] = udid;
            [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject)
             {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
                if(!dict){
                    exit(0);//没数据 直接闪退 不用复制机器码码
                }else
                {
                    NSString *dataString = dict[@"response"][@"data"];
                    NSRange range = [dataString rangeOfString:@"|1081|"];
                    
                    if(range.location != NSNotFound)
                    {
                        
                        NSArray *arr = [dataString componentsSeparatedByString:@"|"];
                        if (arr.count >= 6)
                        {
                            if(![dataString containsString:udid]){
                                
                                [MBProgressHUD showError:@"授权错误，机器码不正确\n联系管理员解绑或更换卡密"];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUD];
                                    [self CodeConfig];
                                });
                            }else{
                                if ([DQTC containsString:@"YES"]) {
                                    NSString *showMsg = [NSString stringWithFormat:@"授权成功,到期时间\n %@", arr[4]];
                                    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                    [alert addTimerToButtonIndex:0 reverse:YES];
                                    [alert showSuccess:@"验证成功" subTitle:showMsg closeButtonTitle:@"确定" duration:5];
                                }
                                //验证版本
                                static dispatch_once_t onceToken;
                                dispatch_once(&onceToken, ^{
                                    if([YZBB containsString:@"YES"]){
                                        //验证通过后验证版本 和公告
                                        [NSObject loadbanben];
                                    }
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [NSObject gonggao];//公告
                                    });
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [[PubgLoad alloc] qidong];
                                    });
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        //验证通过后在这里启动你的辅助
                                        [NSObject dingshiqi];
                                    });
                                
                                });
                                    
                                
                                
                            }
                        }
                        
                    }
                    else
                    {
                        
                        [MBProgressHUD showError:dataString];
                        //验证时间
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [MBProgressHUD hideHUD];
                            [NSObject CodeConfig];
                        });
                    }
                }
            } failure:^(NSError *error)
             {
                
                [MBProgressHUD showError:[NSString stringWithFormat:@"%@",error]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                               {
                    [MBProgressHUD hideHUD];
                    [NSObject CodeConfig];
                });
            }];
        }
        else
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                           {
                [NSObject CodeConfig];
            });
        }
    }else{
        [NSObject getIDFA];
    }
}

/**
 加载版本信息 API
 */
- (void)loadbanben{
    NSString *localv = JN_VERSION;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"api"] =@"v.in";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    param[@"BSphpSeSsL"] = [dateStr MD5Digest];
    NSDate *date = [NSDate date];
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate * nowDate = [date dateByAddingTimeInterval:interval];
    NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    param[@"date"] = nowDateStr;
    param[@"md5"] = @"";
    param[@"mutualkey"] = BSPHP_MUTUALKEY;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            if (dict) {
                NSString *version = dict[@"response"][@"data"];
                BOOL result = [version isEqualToString:localv];
                if (!result){
                    [NSObject getnew];
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.detailsLabelText =@"请更新新版,5秒后跳转下载";
                    hud.userInteractionEnabled = NO;
                   
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:vdate] options:@{} completionHandler:nil];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            exit(0);
                        });
                    });
                }
            }
        } failure:^(NSError *error) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText =@"网络链接失败";
            hud.userInteractionEnabled = NO;
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
            });
        }];
    });
}
/**
 获取版本URL
 */
- (void)getnew{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"api"] =@"url.in";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    param[@"BSphpSeSsL"] = [dateStr MD5Digest];
    NSDate *date = [NSDate date];
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate * nowDate = [date dateByAddingTimeInterval:interval];
    NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    param[@"date"] = nowDateStr;
    param[@"md5"] = @"";
    param[@"mutualkey"] = BSPHP_MUTUALKEY;
    [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        if (dict) {
            vdate = dict[@"response"][@"data"];
        }
    } failure:^(NSError *error) {
         
    }];
    
}

/**
 加载公告 API
 */
- (void)gonggao{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"api"] = @"gg.in";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        param[@"BSphpSeSsL"] = [dateStr MD5Digest];
        NSDate *date = [NSDate date];
        NSTimeZone * zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:date];
        NSDate * nowDate = [date dateByAddingTimeInterval:interval];
        NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
        param[@"date"] = nowDateStr;
        param[@"md5"] = @"";
        param[@"mutualkey"] = BSPHP_MUTUALKEY;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (dict) {
                    NSString *message = dict[@"response"][@"data"];
                    if (message.length>2 ) {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.detailsLabelText =message;
                        hud.userInteractionEnabled = NO;
                       
                        
                    }
                }
            } failure:^(NSError *error) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabelText =@"网络链接失败";
                hud.userInteractionEnabled = NO;
               
                
            }];
        });
    });
}

/**
 激活弹窗
 */


- (void)CodeConfig
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    });
    
    SCLAlertView *alert =  [[SCLAlertView alloc] initWithNewWindow];
    alert.shouldDismissOnTapOutside = NO;
    SCLTextView *textF =   [alert addTextField:@"请在30秒内填写授权码"setDefaultText:nil];
    [alert addButton:@"粘贴" validationBlock:^BOOL{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        textF.text =pasteboard.string;
        return NO;
    }actionBlock:^{}];
    [alert alertDismissAnimationIsCompleted:^{
        if (textF.text.length==0) {
            [self CodeConfig];
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:textF.text forKey:@"km"];
            [NSObject YzCode:textF.text];
        }
    }];
    
    [alert showWarning:@"授权" subTitle:nil closeButtonTitle:@"授权" duration:30];
}

/**
 验证逻辑
 */
- (void)YzCode:(NSString *)code
{
    NSString*udid=[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    //授权码验证
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"api"] = @"login.ic";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    param[@"BSphpSeSsL"] = [dateStr MD5Digest];
    NSDate *date = [NSDate date];
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    NSDate * nowDate = [date dateByAddingTimeInterval:interval];
    NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
    param[@"date"] = nowDateStr;
    param[@"md5"] = @"";
    param[@"mutualkey"] = BSPHP_MUTUALKEY;
    param[@"icid"] = code;
    param[@"icpwd"] = @"";
    param[@"key"] = udid;
    param[@"maxoror"] = udid;
    [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject)
     {
        NSError*error;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
        if (dict)
        {
            NSString *dataString = dict[@"response"][@"data"];
            NSRange range = [dataString rangeOfString:@"|1081|"];
            if (range.location != NSNotFound)
            {
                NSString *activationDID = [[NSUserDefaults standardUserDefaults]objectForKey:@"km"];
                
                if (![activationDID isEqualToString:code])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"km"];
                }
                NSArray *arr = [dataString componentsSeparatedByString:@"|"];
                if (arr.count >= 6)
                {
                    if(![dataString containsString:udid]){
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                        hud.mode = MBProgressHUDModeText;
                        hud.detailsLabelText = @"授权错误，机器码不正确\n联系管理员解绑或更换卡密";
                        hud.userInteractionEnabled = NO;
                       
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self CodeConfig];
                        });
                    }else{
                       
                        NSString *showMsg = [NSString stringWithFormat:@"授权成功-到期时间\n%@\n重启App生效", arr[4]];
                        
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addTimerToButtonIndex:0 reverse:YES];
                        [alert addButton:@"确定" actionBlock:^{
                            exit(0);
                        }];
                        [alert showSuccess:@"验证成功" subTitle:showMsg closeButtonTitle:nil duration:5];
                        
                    }
                }
            }
            else
            {
                NSString *messageStr = dict[@"response"][@"data"];
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabelText =messageStr;
                hud.userInteractionEnabled = NO;
               
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self CodeConfig];
                });
                
            }
        }
        else{
            [self CodeConfig];
        }
    } failure:^(NSError *error)
     {
        [self CodeConfig];
    }];
}

/**
 获取设备码IDFA 刷机变 升级变 -设置-隐私-限制广告跟踪 开关 变 UDID 永久不变 推荐
 */

-(BOOL)getIDFA{
    NSString* UDID;
    if ([UDIDORIDFA containsString:@"YES"]) {
        NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
        NSArray *urlTypes = dict[@"CFBundleURLTypes"];
        NSString *urlSchemes = nil;
        for (NSDictionary *scheme in urlTypes) {
            urlSchemes = scheme[@"CFBundleURLSchemes"][0];
        }
        NSInteger cc;
        cc=[[NSUserDefaults standardUserDefaults] integerForKey:@"cc"];
        //不存在就储存cc
        if (cc==0) {
            cc=arc4random() % 100000;
            [[NSUserDefaults standardUserDefaults] setInteger:cc forKey:@"cc"];
        }
        //读取本地UDID
        UDID=[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
        //存在就返回UDID
        if (UDID.length>10) {
            if ([YZ000 containsString:@"YES"]) {
                if ([UDID containsString:@"0000-000"] || [UDID containsString:@"00000000"] ) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"udid"];
                    return NO;
                }else{
                    [[NSUserDefaults standardUserDefaults] setObject:UDID forKey:@"udid"];
                    return YES;
                }
            }
            
        }
        //不存在就读取服务器的txt
        NSString *requestStr = [NSString stringWithFormat:@"%@udid%ld.txt",UDID_HOST,cc];
        NSError*error;
        UDID = [NSString stringWithContentsOfURL:[NSURL URLWithString:requestStr] encoding:NSUTF8StringEncoding error:&error];
        if (error==nil) {
            //储存
            [[NSUserDefaults standardUserDefaults] setObject:UDID forKey:@"udid"];
            return YES;
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"防封模块安装" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"退出应用" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"udid"];
                    exit(0);
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    NSDictionary *dict = [[NSBundle mainBundle] infoDictionary];
                    NSArray *urlTypes = dict[@"CFBundleURLTypes"];
                    NSString *urlSchemes = nil;
                    for (NSDictionary *scheme in urlTypes) {
                        urlSchemes = scheme[@"CFBundleURLSchemes"][0];
                    }
                    NSInteger cc;
                    cc=[[NSUserDefaults standardUserDefaults] integerForKey:@"cc"];
                    if (cc==0) {
                        cc=arc4random() % 100000;
                        [[NSUserDefaults standardUserDefaults] setInteger:cc forKey:@"cc"];
                    }
                    NSString*url=[NSString stringWithFormat:@"%@udid.php?id=%ld&openurl=%@",UDID_HOST,cc,urlSchemes];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        exit(0);
                    });
                    
                }]];
                
                UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
                [rootViewController presentViewController:alertController animated:YES completion:nil];
            });
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"udid"];
        }
    }else{
        ASIdentifierManager *as = [ASIdentifierManager sharedManager];
        UDID= as.advertisingIdentifier.UUIDString;
//        UDID= [UIDevice VKKeychainIDFV];
        if ([YZ000 containsString:@"YES"]) {
            if ([UDID containsString:@"0000-000"] || [UDID containsString:@"000000000"]) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.detailsLabelText =@"机器码获取失败-请打开您的设备\n系统设置-隐私-跟踪-开启跟踪\n游戏的跟踪选项";
                hud.userInteractionEnabled = NO;
                
                [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"udid"];
                return NO;
            }
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:UDID forKey:@"udid"];
            return YES;
        }
    }
    NSLog(@"UDID=%@",UDID);
    return NO;
}

-(void)dingshiqi
{
    timer=[NSTimer timerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString*udid=[[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"api"] = @"login.ic";
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd#HH:mm:ss"];
            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
            param[@"BSphpSeSsL"] = [dateStr MD5Digest];
            NSDate *date = [NSDate date];
            NSTimeZone * zone = [NSTimeZone systemTimeZone];
            NSInteger interval = [zone secondsFromGMTForDate:date];
            NSDate * nowDate = [date dateByAddingTimeInterval:interval];
            NSString *nowDateStr = [[nowDate description] stringByReplacingOccurrencesOfString:@" +0000" withString:@""];
            param[@"date"] = nowDateStr;
            param[@"md5"] = @"";
            param[@"mutualkey"] = BSPHP_MUTUALKEY;
            param[@"icid"] = [[NSUserDefaults standardUserDefaults] objectForKey:@"km"];
            param[@"icpwd"] = @"";
            param[@"key"] = udid;
            param[@"maxoror"] = udid;
            [NetTool Post_AppendURL:BSPHP_HOST parameters:param success:^(id responseObject)
             {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                
                if(!dict){
                    exit(0);//没数据 直接闪退 不用复制机器码码
                }else
                {
                    NSString *dataString = dict[@"response"][@"data"];
                    NSRange range = [dataString rangeOfString:@"|1081|"];
                    
                    if(range.location != NSNotFound)
                    {
                        return;
                    }
                    else
                    {
                        //验证时间
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                       {
                            [NSObject CodeConfig];
                        });
                    }
                }
            } failure:^(NSError *error)
             {
                
            }];
        });
        
    }];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
}
@end




