#import "CDVQiNiuUploadPlugin.h"

@interface CDVQiNiuUploadPlugin ()

@property (copy, nonatomic)NSString *token;
@property (copy) NSString *callbackId;
@property (nonatomic) BOOL flag;
@property (copy) QNConfiguration *config;

@end

@implementation CDVQiNiuUploadPlugin

// 自定义
- (void)init:(CDVInvokedUrlCommand *)command{
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


- (void)cancel:(CDVInvokedUrlCommand *)command{
    self.flag = TRUE;
}


// 简单文件上传
-(void)simpleUploadFile:(CDVInvokedUrlCommand *)command
{
    __block CDVPluginResult* pluginResult = nil;
    NSMutableDictionary* result = [NSMutableDictionary dictionaryWithCapacity: 3];

    NSDictionary* options = [command.arguments objectAtIndex:0];
    NSLog(@"token:%@",command.callbackId);

    // 获取参数
    NSString * token = self.token;
    NSString * key = [options objectForKey:@"name"];
    NSString * filePath = [options objectForKey:@"filePath"];
    filePath = [filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"filePath:%@",filePath);

    // 上传进度更新
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            NSLog(@"percent == %.2f", percent);
            key = key != nil ? key : @"";
            [result setObject:key forKey:@"key"];
            [result setObject:[NSNumber numberWithFloat:percent] forKey:@"percent"];
            // 回传进度
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        params:nil
        checkCrc:NO
        cancellationSignal:^BOOL() {
            return self.flag;
        }
                                    ];

    // 上传管理器
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:self.config];
    [upManager putFile:filePath key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if(info.ok)
        {
            NSLog(@"请求成功");
            key = key != nil ? key : nil;
            info = info != nil ? info : nil;
            resp = resp != nil ? resp : nil;
            [result setObject:key forKey:@"key"];
            // [result setObject:info forKey:@"info"];
            [result setObject:resp forKey:@"resp"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

        }
        else{
            NSLog(@"失败");
            key = key != nil ? key : @"";
            info = info != nil ? info : nil;
            resp = resp != nil ? resp : nil;
            [result setObject:key forKey:@"key"];
            // [result setObject:info forKey:@"info"];
            [result setObject:resp forKey:@"resp"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary: result];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
    }
    option:uploadOption];
}


// ================ 断点续传配置 ======================
// NSError *error;
// builder.recorder =  [QNFileRecorder fileRecorderWithFolder:@"保存目录" error:&error];
// }];

@end
