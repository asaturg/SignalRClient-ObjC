//
//  HttpClient.h
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import <Foundation/Foundation.h>
#import "HttpResponse.h"

@interface HttpClient : NSObject

+ (void)getWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler;

+ (void)postWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler;

+ (void)optionsWithUrl:(NSURL*)url completionHandler:(void (^) (HttpResponse *response, NSError *error))handler;

@end
