/************************************************************
 Class    : OneWayHTTPS.m
 Describe : AFN 自签名单项 HTTPS 认证请求
 Company  : Prient
 Author   : Yanzheng 严正
 Date     : 2017-11-27
 Version  : 1.0
 Declare  : Copyright © 2017 Yanzheng. All rights reserved.
 ************************************************************/

#import "OneWayHTTPS.h"
#import "AFNetworking.h"

@implementation OneWayHTTPS

+ (AFHTTPSessionManager *)sessionManager {
    static dispatch_once_t onceToken;
    static AFHTTPSessionManager *_manager = nil;
    dispatch_once(&onceToken, ^{
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
        
        /// 注意将你的证书加入项目，并把下面名称改为自己证书的名称
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"root-cert" ofType:@"der"];
        NSData *caCertData = [NSData dataWithContentsOfFile:cerPath];
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:[NSSet setWithObject:caCertData]];
        
        /// 是否允许使用自签名证书
        securityPolicy.allowInvalidCertificates = YES;
        /// 是否需要验证域名
        securityPolicy.validatesDomainName = NO;
        
        _manager.securityPolicy = securityPolicy;
        
        // 声明返回的结果类型
        // 不加上这句话，会报“Request failed: unacceptable content-type: text/plain”错误，因为我们要获取text/plain类型数据
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // 如果报接受类型不一致请替换一致text/html  或者 text/plain
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
        // 设置请求头类型
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        // 请求超时，时间设置
        _manager.requestSerializer.timeoutInterval = 20.0;
        
        /// 关闭缓存避免干扰测试
        _manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        /// 客户端请求验证 重写 setSessionDidReceiveAuthenticationChallengeBlock 方法
        [_manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing *_credential) {
            
            /// 获取服务器的trust object
            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
            SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCertData);
            NSCAssert(caRef != nil, @"caRef is nil");
            
            NSArray *caArray = @[(__bridge id)(caRef)];
            NSCAssert(caArray != nil, @"caArray is nil");
            
            /// 将读取到的证书设置为serverTrust的根证书
            OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
            SecTrustSetAnchorCertificatesOnly(serverTrust,NO);
            NSCAssert(errSecSuccess == status, @"SecTrustSetAnchorCertificates failed");
            
            /// 选择质询认证的处理方式
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential = nil;
            
            /// NSURLAuthenticationMethodServerTrust质询认证方式
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                
                /// 基于客户端的安全策略来决定是否信任该服务器，不信任则不响应质询。
                if ([_manager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    
                    /// 创建质询证书
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    /// 确认质询方式
                    if (credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    /// 取消挑战
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
                
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            }
            
            return disposition;
        }];
        
    });
    return _manager;
}

+ (void)POST:(NSString *)URLString parameters:(id)parameters
     success:(void (^)(NSURLSessionDataTask *, id))success
     failure:(void (^)(NSURLSessionDataTask *, NSString *))failure {
    
    [[[self class] sessionManager] POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"POST 请求结果：%@", result);
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        success(task, resultDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, [self stringWithError:error]);
    }];
    
}

+ (void)GET:(NSString *)URLString parameters:(id)parameters
    success:(void (^)(NSURLSessionDataTask *, id))success
    failure:(void (^)(NSURLSessionDataTask *, NSString *))failure {
    
    [[[self class] sessionManager] GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"GET 请求结果：%@", result);
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        
        success(task, resultDict);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(task, [self stringWithError:error]);
    }];
}

/**
 * @brief 把错误信息转换成文字描述
 * @param error 错误信息
 * @return 返回字符串
 */
+ (NSString *)stringWithError:(NSError *)error{
    
    DLog("错误提示信息：%@", error.description);
    
    switch (error.code) {
        case NSURLErrorCancelled:
            return @"取消错误！";
            break;
        case NSURLErrorBadURL:
            return @"无效的URL！";
            break;
        case NSURLErrorTimedOut:
            return @"访问服务器超时！";
            break;
        case NSURLErrorUnsupportedURL:
            return @"不支持的URL地址！";
            break;
        case NSURLErrorCannotFindHost:
            return @"找不到服务器！";
            break;
        case NSURLErrorCannotConnectToHost:
            return @"无法连接服务器！";
            break;
        case NSURLErrorNetworkConnectionLost:
            return @"网络连接异常！";
            break;
        case NSURLErrorDNSLookupFailed:
            return @"DNS解析失败！";
            break;
        case NSURLErrorHTTPTooManyRedirects:
            return @"HTTP重定向太多！";
            break;
        case NSURLErrorResourceUnavailable:
            return @"资源不可用！";
            break;
        case NSURLErrorNotConnectedToInternet:
            return @"无网络连接！";
            break;
        case NSURLErrorRedirectToNonExistentLocation:
            return @"重定向位置不存在！";
            break;
        case NSURLErrorBadServerResponse:
            return @"服务器响应异常！";
            break;
        case NSURLErrorUserCancelledAuthentication:
            return @"用户取消授权！";
            break;
        case NSURLErrorUserAuthenticationRequired:
            return @"需要用户授权！";
            break;
        case NSURLErrorZeroByteResource:
            return @"零字节资源！";
            break;
        case NSURLErrorCannotDecodeRawData:
            return @"无法解码原始数据！";
            break;
        case NSURLErrorCannotDecodeContentData:
            return @"无法解码内容数据！";
            break;
        case NSURLErrorCannotParseResponse:
            return @"无法解析响应！";
            break;
        default:
            return @"未知异常！";
            break;
    }
}

@end
