#import "Qiniu.h"

@interface Qiniu ()

@property (copy, nonatomic)NSString *token;
@property (copy) NSString* callbackId;
@property (copy) BOOL flag;
@property (copy) QNConfiguration *config;

@end

@implementation Qiniu

// 自定义
- (void)init:(CDVInvokedUrlCommand)command{
    // 初始化 token
    NSString* token = [command.arguments objectAtIndex:0];
    self.callbackId = command.callbackId;
    self.token = token;

    // 配置自动选择 scope
    self.config =[QNConfiguration build:^(QNConfigurationBuilder *builder) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[QNResolver systemResolver]];
        QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
        builder.dns = dns;
        // 是否选择  https  上传
        // builder.useHttps = YES;
    }];
}


- (void)cancel:(CDVInvokedUrlCommand)command{
    self.flag = true;
}


// 简单文件上传
-(void)simpleUploadFile:(CDVInvokedUrlCommand *)command
{
    // 重用uploadManager。一般地，只需要创建一个uploadManager对象
    NSDictionary* options = [command.arguments objectAtIndex:0];
    self.callbackId = command.callbackId;
    NSLog(@"token:%@",self.callbackId);

    // 获取参数
    NSString * token = self.token;
    NSString * key = [options objectForKey:@"key"];
    NSString * filePath = [options objectForKey:@"filePath"];

    // 上传进度更新
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);

        // 回传进度
        CDVPluginResult* pluginResult = nil;
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK key:key percent:percent];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:^() {
       return flag;
    }];

    // 上传管理器
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:self.config];
    [upManager putFile:filePath key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if(info.ok)
        {
            NSLog(@"请求成功");
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK info:info key:key resp:resp];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }
        else{
            NSLog(@"失败");
            CDVPluginResult* pluginResult = nil;
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR info:info key:key resp:resp];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
            //如果失败，这里可以把info信息上报自己的服务器，便于后面分析上传错误原因
        }
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
    }
    option:uploadOption];
}


// ================ 断点续传配置 ======================
// //设置断点续传
// NSError *error;
// builder.recorder =  [QNFileRecorder fileRecorderWithFolder:@"保存目录" error:&error];
// }];

@end