#import "SSZipArchive.h"
#import "PubgLoad.h"
#import <UIKit/UIKit.h>

#import "JHPP.h"
#import "MBProgressHUD+NJ.h"
#import "MBProgressHUD.h"
#import "SCLAlertView.h"
#import "JHDragView.h"
@interface PubgLoad()<SSZipArchiveDelegate,NSURLSessionDelegate>
@property (nonatomic, strong) dispatch_source_t timer;
@end
static NSDictionary *json;
@implementation PubgLoad

static PubgLoad *extraInfo;
static BOOL MenDeal;
+(void)load
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PubgLoad alloc] qidong];
    });
}
-(void)qidong
{
  
    extraInfo =  [PubgLoad new];
    [extraInfo initTapGes];
    [extraInfo tapIconView];
}
-(void)initTapGes
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 2;//点击次数
    tap.numberOfTouchesRequired = 3;//手指数
    [[JHPP currentViewController].view addGestureRecognizer:tap];
    [tap addTarget:self action:@selector(tapIconView)];
}


-(void)tapIconView
{
    JHDragView *view = [[JHPP currentViewController].view viewWithTag:100];
    if (!view) {
        view = [[JHDragView alloc] init];
        view.tag = 100;
        [[JHPP currentViewController].view addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onConsoleButtonTapped)];
        tap.numberOfTapsRequired = 1;
        [view addGestureRecognizer:tap];
    }
    
    if (!MenDeal) {
        view.hidden = NO;
        
    } else {
        view.hidden = YES;
        
    }
    
    MenDeal = !MenDeal;
}

-(void)onConsoleButtonTapped
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //解析服务器版本
        NSError *error;
        NSString *txturl = [NSString stringWithFormat:@"https://dke.ios668.cn/nba.json"];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:txturl]];
        json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (error==nil) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert addTimerToButtonIndex:0 reverse:YES];
            alert.shouldDismissOnTapOutside = YES;
            
            NSString *主标题 = [json objectForKey:@"主标题"];//主功能
            NSString *副标题 = [json objectForKey:@"副标题"];//主功能
            NSString *取消 = [json objectForKey:@"取消"];//主功能
            NSArray *功能 = [json objectForKey:@"功能"];
            for (int i =0; i< 功能.count; i++) {
                NSDictionary*功能数组=功能[i];
                NSString *按钮名字 = [功能数组 objectForKey:@"按钮名字"];
                NSString *解压目录 = [功能数组 objectForKey:@"解压目录"];
                NSString *url=[功能数组 objectForKey:@"下载地址"];
                NSString *解压密码=[功能数组 objectForKey:@"解压密码"];
                
                NSString *下载地址 = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [alert addButton:按钮名字 actionBlock:^{
                    //判断密码不为空且大于2 得提示输入密码 效验才下载 否则else 直接下载解压
                    if (解压密码.length>2) {
                        SCLAlertView *alert =  [[SCLAlertView alloc] initWithNewWindow];
                        alert.shouldDismissOnTapOutside = NO;
                        SCLTextView *textF =   [alert addTextField:@"请在输入解压密码"setDefaultText:nil];
                        [alert addButton:@"粘贴解压密码" validationBlock:^BOOL{
                            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                            textF.text =pasteboard.string;
                            return NO;
                        }actionBlock:^{}];
                        [alert alertDismissAnimationIsCompleted:^{
                            if (![textF.text isEqual:解压密码]) {
                                SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                                [alert addTimerToButtonIndex:0 reverse:YES];
                                [alert showError:@"密码错误" subTitle:@"请确认解压密码\n不要有空格" closeButtonTitle:@"确定" duration:nil];
                            }else{
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    NSURL *url = [NSURL URLWithString:下载地址];
                                    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                                    // 2、利用NSURLSessionDownloadTask创建任务(task)
                                    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
                                    // 3、执行任务
                                    [task resume];
                                });
                                
                            }
                        }];
                        
                        [alert showWarning:@"解压密码" subTitle:nil closeButtonTitle:@"解压" duration:30];
                    }else{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            NSURL *url = [NSURL URLWithString:下载地址];
                            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                            // 2、利用NSURLSessionDownloadTask创建任务(task)
                            NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
                            // 3、执行任务
                            [task resume];
                        });
                    }
                    
                    
                    //一下是判断按钮名字的特殊对待方式 比如名字包含QQ 等 点击按钮跳转JSON 的url 等操作
                    if([按钮名字 containsString:@"网络数据"] || [按钮名字 containsString:@"网络解说"] || [按钮名字 containsString:@"存档"]){
                        [[NSUserDefaults standardUserDefaults] setObject:解压目录 forKey:@"解压目录"];
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addTimerToButtonIndex:0 reverse:YES];
                        [alert addButton:@"确定下载" actionBlock:^{
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSURL *url = [NSURL URLWithString:下载地址];
                                NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
                                // 2、利用NSURLSessionDownloadTask创建任务(task)
                                NSURLSessionDownloadTask *task = [session downloadTaskWithURL:url];
                                // 3、执行任务
                                [task resume];
                            });
                            
                        }];
                        [alert showSuccess:主标题 subTitle:按钮名字 closeButtonTitle:@"取消下载" duration:nil];
                        
                    }
                    if([按钮名字 containsString:@"Q"]){
                        [self openurl:下载地址];
                    }
                    if([按钮名字 containsString:@"本地数据"]){
                       
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addTimerToButtonIndex:0 reverse:YES];
                        [alert addButton:@"确定解压本地数据" actionBlock:^{
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [MBProgressHUD showMessage:@"解压中耐心请等候5-10分钟"];
                                NSString *解压路径 = [(NSArray *)NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                                NSString *homeDir = [NSString stringWithFormat:@"%@/LBCVDR.zip",[[NSBundle mainBundle] bundlePath]];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    BOOL isSuccess=[SSZipArchive unzipFileAtPath:homeDir toDestination:解压路径 delegate:self];
                                    if (isSuccess) {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showSuccess:@"解压安装完成。重启APP生效"];
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            exit(0);
                                        });
                                    }
                                    
                                });

                            });
                        }];
                        [alert showSuccess:主标题 subTitle:按钮名字 closeButtonTitle:@"取消" duration:nil];
                        
                        
                    }
                    if([按钮名字 containsString:@"本地解说"]){
                       
                        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
                        [alert addTimerToButtonIndex:0 reverse:YES];
                        [alert addButton:@"确定解压本地解说包" actionBlock:^{
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [MBProgressHUD showMessage:@"解压中耐心请等候5-10分钟"];
                                NSString *解压路径 = [(NSArray *)NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                                NSString *homeDir = [NSString stringWithFormat:@"%@/LBCVDR.zip",[[NSBundle mainBundle] bundlePath]];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    BOOL isSuccess=[SSZipArchive unzipFileAtPath:homeDir toDestination:解压路径 delegate:self];
                                    if (isSuccess) {
                                        [MBProgressHUD hideHUD];
                                        [MBProgressHUD showSuccess:@"解压安装完成。重启APP生效"];
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            exit(0);
                                        });
                                    }
                                    
                                });

                            });
                        }];
                        [alert showSuccess:主标题 subTitle:按钮名字 closeButtonTitle:@"取消" duration:nil];
                        
                        
                    }
                    
                }];
            }
            
            [alert showSuccess:主标题 subTitle:副标题 closeButtonTitle:取消 duration:nil];
        }
        
    });
    
    
}
-(void)openurl:(NSString*)url
{
    NSLog(@"跳转：%@",url);
    [MBProgressHUD showText:@"跳转"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];

}
/*
 1.接收到服务器返回的数据
 bytesWritten: 当前这一次写入的数据大小
 totalBytesWritten: 已经写入到本地文件的总大小
 totalBytesExpectedToWrite : 被下载文件的总大小
 */


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //给progressView赋值进度
    float jd = 1.0 * totalBytesWritten / totalBytesExpectedToWrite;
    NSString*下载进度=[NSString stringWithFormat:@"下载中请稍后-已下载%.0f％",jd*100];
    if (jd!=1) {
        
            [MBProgressHUD hideHUD];
            [MBProgressHUD showJindutiao:下载进度 jd:jd];
       
    }else{
        [MBProgressHUD hideHUD];
    }
    
}

/*
 2.下载完成
 downloadTask:里面包含请求信息，以及响应信息
 location：下载后自动帮我保存的地址
 */
static NSString *下载路径;
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    //location为下载好的文件路径
    NSLog(@"location为下载好的文件路径, %@", location);
    //1、生成的Caches地址
    下载路径 = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingString:downloadTask.response.suggestedFilename];
    NSLog(@"生成的Caches地址, %@", 下载路径);
    //2、移动图片的存储地址
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager moveItemAtURL:location toURL:[NSURL fileURLWithPath:下载路径] error:nil];
    
}

/*
 3.请求完毕
 如果有错误, 那么error有值
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (!error) {
        [MBProgressHUD hideHUD];
        NSString*解压目录=[[NSUserDefaults standardUserDefaults] objectForKey:@"解压目录"];
        
        UIViewController*rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"下载完成-是否安装存档" preferredStyle:UIAlertControllerStyleAlert];
        //增加确定按钮；
        [alertController addAction:[UIAlertAction actionWithTitle:@"安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD showMessage:@"解压安装中-请勿 关闭、切换后台"];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([解压目录 containsString:@"Documents"]) {
                            NSString *解压路径 = [(NSArray *)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                            BOOL isSuccess=[SSZipArchive unzipFileAtPath:下载路径 toDestination:解压路径 delegate:self];
                            if (isSuccess) {
                                [MBProgressHUD showSuccess:@"解压安装完成。重启APP生效"];
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    exit(0);
                                });
                            }
                        }
                        if ([解压目录 containsString:@"Library"]) {
                            NSString *解压路径 = [(NSArray *)NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
                            BOOL isSuccess=[SSZipArchive unzipFileAtPath:下载路径 toDestination:解压路径 delegate:self];
                            if (isSuccess) {
                               
                                [MBProgressHUD showSuccess:@"解压安装完成。重启APP生效"];
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    exit(0);
                                });
                            }
                        }
                    });
                    
                    
                
            });
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        
        [rootViewController presentViewController:alertController animated:YES completion:nil];
        
    }else{
        [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:[NSString stringWithFormat:@"下载失败\n%@",error]];
        NSLog(@"请求失败=%@",error);
    }
    
}

@end
