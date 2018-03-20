//
//  JSONHubProtocol.m
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import "JSONHubProtocol.h"

@interface JSONHubProtocol() {
    NSString *recordSeparator;
}

@end

@implementation JSONHubProtocol

@synthesize type;
@synthesize name;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.name = @"json";
        self.type = ProtocolTypeText;
        
        recordSeparator = [NSString stringWithFormat:@"%C", 0x1e];
    }
    return self;
}


- (NSArray*)parseMessages:(NSString *)data {
    NSMutableArray *hubMessages = [[NSMutableArray alloc] init];
    
    NSRange range = [data rangeOfString:recordSeparator options:NSBackwardsSearch];
    
    NSArray *messages = [[data substringToIndex:range.location] componentsSeparatedByString:recordSeparator];
    
    for (NSString *message in messages) {
        [hubMessages addObject:[self createHubMessage:message]];
    }
    
    return hubMessages;
}

- (NSData *)writeMessage:(id<HubMessage>)message {
    
    if (message.messageType == MessageTypeInvocation) {
        InvocationMessage *invocationMessage = (InvocationMessage *)message;
        
        NSDictionary *invocationJSONObject = @{@"type" : @(invocationMessage.messageType),
                                               @"invocationId" : invocationMessage.invocationId,
                                               @"target" : invocationMessage.target,
                                               @"arguments" : invocationMessage.arguments,
                                               @"nonBlocking" : @(invocationMessage.nonBlocking)
                                               };
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:invocationJSONObject options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        dataString= [dataString stringByAppendingString:recordSeparator];
        
        return [dataString dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
}

- (id<HubMessage>)createHubMessage:(NSString *)message {
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding]  options:NSJSONReadingMutableContainers error:&error];
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        MessageType type = [json[@"type"] integerValue];
        
        switch (type) {
            case MessageTypeInvocation:
                return [self createInvocationMessage:json];
                break;
            case MessageTypeStreamItem:
                return [self createStreamItemMessage:json];
                break;
            case MessageTypeCompletion:
                return [self createCompletionMessage:json];
                break;
            default:
                break;
        }
    }
    
    return nil;
}

- (InvocationMessage*)createInvocationMessage:(NSDictionary *)message {
    
    NSString *invocationId = message[@"invocationId"];
    NSString *target = message[@"target"];
    NSArray *arguments = message[@"arguments"];
    BOOL nonBlocking = [message[@"nonBlocking"] boolValue];
    
    return  [[InvocationMessage alloc] initWithInvocationId:invocationId target:target arguments:arguments nonBlocking:nonBlocking];
}

- (StreamItemMessage*)createStreamItemMessage:(NSDictionary *)message {
    NSString *invocationId = message[@"invocationId"];
    //TODO: handle this case
    return  [[StreamItemMessage alloc] initWithInvocationId:invocationId item:nil];
}

- (CompletionMessage*)createCompletionMessage:(NSDictionary *)message {
    
    NSString *invocationId = message[@"invocationId"];
    NSString *error = message[@"error"];
    if (error) {
        return [[CompletionMessage alloc] initWithInvocationId:invocationId error:error];
    }
    
    BOOL hasResult = [message[@"hasResult"] boolValue];
    if (!hasResult) {
        return [[CompletionMessage alloc] initWithInvocationId:invocationId];
    }
    
    // TODO: handle result
    return [[CompletionMessage alloc] initWithInvocationId:invocationId result:nil];
}


@end
