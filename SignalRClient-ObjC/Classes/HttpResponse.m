//
//  HttpResponse.m
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import "HttpResponse.h"

@implementation HttpResponse

- (instancetype)initWithStatusCode:(NSInteger)statusCode contents:(NSData*)contents {
    
    if (self = [super init]) {
        _statusCode = statusCode;
        _contents = contents;
    }
    
    return self;
}

@end
