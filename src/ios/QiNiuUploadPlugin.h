// 参考自: https://github.com/wonderchief/qiniuCordova/blob/master/src/ios/Qiniu.h

#import <Cordova/CDV.h>
#import <QiniuSDK.h>

@interface QiNiuUploadPlugin : CDVPlugin<QiniuUploadDelegate>

- (void)init:(CDVInvokedUrlCommand*)command
- (void)cancel:(CDVInvokedUrlCommand*)command
- (void)simpleUploadFile:(CDVInvokedUrlCommand*)command;

@end