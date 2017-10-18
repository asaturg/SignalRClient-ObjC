//
//  HttpResponse.h
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import <Foundation/Foundation.h>

@interface HttpResponse : NSObject

@property (nonatomic) NSInteger statusCode;
@property (nonatomic) NSData *contents;

- (instancetype)initWithStatusCode:(NSInteger)statusCode contents:(NSData*)contents;

@end
