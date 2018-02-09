// 参考自: https://github.com/wonderchief/qiniuCordova/blob/master/src/ios/Qiniu.m

#import "Qiniu.h"

@interface Qiniu ()

@end

@implementation Qiniu

// 自定义
- (void)init:(CDVInvokedUrlCommand)command{
    QNConfiguration *config =[QNConfiguration build:^(QNConfigurationBuilder *builder) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [array addObject:[QNResolver systemResolver]];
    QNDnsManager *dns = [[QNDnsManager alloc] init:array networkInfo:[QNNetworkInfo normal]];
    builder.dns = dns;
    //是否选择  https  上传
    builder.useHttps = YES;
    //设置断点续传
    NSError *error;
    builder.recorder =  [QNFileRecorder fileRecorderWithFolder:@"保存目录" error:&error];
    }];
}

- (void)cancel:(CDVInvokedUrlCommand)command{
}


// 自定义
-(void)simpleUploadFile:(CDVInvokedUrlCommand *)command
{
    //重用uploadManager。一般地，只需要创建一个uploadManager对象
    NSDictionary* options = [command.arguments objectAtIndex:0];
    self.callbackId = command.callbackId;
    NSLog(@"token:%@",self.callbackId);
    NSString* uptoken = [options objectForKey:@"uptoken"];
    // 可以调用初始化方法传过来
    NSString * token = @"从服务端SDK获取";
    NSString * key = [options objectForKey:@"key"];
    NSString * filePath = [options objectForKey:@"filePath"];
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    params:nil
    checkCrc:NO
    cancellationSignal:nil];
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
    option:nil];
}

@end