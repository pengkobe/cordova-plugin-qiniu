#import "Qiniu.h"

@interface Qiniu ()

@property (copy, nonatomic)NSString *token;
@property (copy) NSString *callbackId;
@property (copy) BOOL flag;
@property (copy) QNConfiguration *config;

@end

@implementation Qiniu

// 自定义
- (void)init:(CDVInvokedUrlCommand)command{
    // 初始化 token
    NSString* token = [command.arguments objectAtIndex:0];
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

    // 回传状态
    CDVPluginResult* pluginResult = nil;
    NSLog(@"your uploadtoken:%@",token);
    NSString *message = [NSString stringWithFormat:@"Init your token is: %@\n", token];
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


- (void)cancel:(CDVInvokedUrlCommand)command{
    self.flag = true;
}


// 简单文件上传
-(void)simpleUploadFile:(CDVInvokedUrlCommand *)command
{
     CDVPluginResult* pluginResult = nil;

    // 重用uploadManager。一般地，只需要创建一个uploadManager对象
    NSDictionary* options = [command.arguments objectAtIndex:0];
    NSLog(@"token:%@",command.callbackId);

    // 获取参数
    NSString * token = self.token;
    NSString * key = [options objectForKey:@"key"];
    NSString * filePath = [options objectForKey:@"filePath"];

    // 上传进度更新
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);
    
        // 回传进度
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK key:key percent:percent];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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
            // 方式1
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: [info:info key:key resp:resp];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }
        else{
            NSLog(@"失败");
            // 方式2
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: [info:info key:key resp:resp];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
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