//
//  HttpClient.m
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import "HttpClient.h"

@implementation HttpClient

+ (void)getWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler {
    
    [self sendHttpRequestWithUrl:url method:@"GET" completionHandler:handler];
}

+ (void)postWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler {
    [self sendHttpRequestWithUrl:url method:@"POST" completionHandler:handler];
}

+ (void)optionsWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler {
    [self sendHttpRequestWithUrl:url method:@"OPTIONS" completionHandler:handler];
}

+ (void)sendHttpRequestWithUrl:(NSURL*)url method:(NSString *)method completionHandler:(void (^) (HttpResponse *response, NSError *error))handler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        HttpResponse *httpResponse =  [[HttpResponse alloc] initWithStatusCode:[(NSHTTPURLResponse*)response statusCode] contents:data];
        handler(httpResponse,error);
        
    }] resume];
}

@end
