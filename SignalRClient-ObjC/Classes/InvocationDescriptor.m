//
//  InvocationDescriptor.m
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import "InvocationDescriptor.h"

@implementation InvocationDescriptor

- (instancetype)initWithId:(NSInteger)id method:(NSString *)method arguments:(NSArray *)arguments {
    if (self = [super init]) {
        self.id = id;
        self.method = method;
        self.arguments = arguments;
    }
    return self;
}

@end

@implementation InvocationResult

- (id)getResult {
    
    return nil;
}

@end
