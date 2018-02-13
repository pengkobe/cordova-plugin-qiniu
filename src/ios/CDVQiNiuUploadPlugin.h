// 参考自: https://github.com/wonderchief/qiniuCordova/blob/master/src/ios/Qiniu.h

#import <Cordova/CDV.h>
#import "QiniuSDK.h"
#import "HappyDNS.h"
#import "QNRefresher.h"


@interface CDVQiNiuUploadPlugin : CDVPlugin{}

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)cancel:(CDVInvokedUrlCommand*)command;
- (void)simpleUploadFile:(CDVInvokedUrlCommand*)command;

@end
