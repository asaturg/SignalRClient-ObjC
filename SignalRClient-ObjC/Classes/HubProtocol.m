//
//  HubProtocol.m
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import "HubProtocol.h"

@implementation InvocationMessage

@synthesize messageType;

- (instancetype)initWithInvocationId:(NSString *)invocationId target:(NSString *)target arguments:(NSArray*)arguments nonBlocking:(BOOL)nonBlocking {
    
    if (self = [super init]) {
        
        self.messageType = MessageTypeInvocation;
        self.invocationId = invocationId;
        self.target = target;
        self.arguments = arguments;
        self.nonBlocking = nonBlocking;
    }
    
    return self;
}

@end

@implementation StreamItemMessage

@synthesize messageType;

- (instancetype)initWithInvocationId:(NSString *)invocationId item:(id)item {
    
    if (self = [super init]) {
        
        self.messageType = MessageTypeStreamItem;
        self.invocationId = invocationId;
        self.item = item;
    }
    
    return self;
}

@end

@implementation CompletionMessage

@synthesize messageType;

- (instancetype)initWithInvocationId:(NSString *)invocationId {
  
    if (self = [super init]) {
        self.messageType = MessageTypeCompletion;
        self.invocationId = invocationId;
        self.result = nil;
        self.error = nil;
        self.hasResult = NO;
    }
    
    return self;
}

- (instancetype)initWithInvocationId:(NSString *)invocationId result:(id)result {
    
    if (self = [super init]) {
        self.messageType = MessageTypeCompletion;
        self.invocationId = invocationId;
        self.result = result;
        self.error = nil;
        self.hasResult = YES;
    }
    
    return self;
}

- (instancetype)initWithInvocationId:(NSString *)invocationId error:(NSString*)error {
    
    if (self = [super init]) {
        self.messageType = MessageTypeCompletion;
        self.invocationId = invocationId;
        self.result = nil;
        self.error = error;
        self.hasResult = NO;
    }
    
    return self;
}

@end
