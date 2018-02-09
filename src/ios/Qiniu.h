// 参考自: https://github.com/wonderchief/qiniuCordova/blob/master/src/ios/Qiniu.h

#import <Cordova/CDV.h>
#import <QiniuSDK.h>

@interface Qiniu : CDVPlugin<QiniuUploadDelegate>

@property (copy, nonatomic)NSString *token;
@property (copy) NSString* callbackId;

- (void)init:(CDVInvokedUrlCommand*)command
- (void)cancel:(CDVInvokedUrlCommand*)command
- (void)simpleUploadFile:(CDVInvokedUrlCommand*)command;


@end