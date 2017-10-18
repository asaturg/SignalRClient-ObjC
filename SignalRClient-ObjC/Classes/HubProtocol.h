//
//  HubProtocol.h
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ProtocolType) {
    ProtocolTypeText = 1,
    ProtocolTypeBinary
};

typedef NS_ENUM(NSUInteger, MessageType) {
    MessageTypeInvocation = 1,
    MessageTypeStreamItem,
    MessageTypeCompletion
};

@protocol HubMessage <NSObject>

@property (nonatomic) MessageType messageType;
@property (nonatomic) NSString* invocationId;

@end

@protocol HubProtocol <NSObject>

@property (nonatomic) NSString *name;
@property (nonatomic) ProtocolType type;

- (NSArray*)parseMessages:(NSData*)data;
- (NSData *)writeMessage:(id<HubMessage>)message;

@end

@interface InvocationMessage : NSObject <HubMessage>

@property (nonatomic) NSString *invocationId;
@property (nonatomic) NSString *target;
@property (nonatomic) NSArray *arguments;
@property (nonatomic) BOOL nonBlocking;

- (instancetype)initWithInvocationId:(NSString *)invocationId target:(NSString *)target arguments:(NSArray*)arguments nonBlocking:(BOOL)nonBlocking;

@end

@interface StreamItemMessage: NSObject<HubMessage>

@property (nonatomic) NSString *invocationId;
@property (nonatomic) id item;

- (instancetype)initWithInvocationId:(NSString *)invocationId item:(id)item;
    
@end

@interface CompletionMessage: NSObject<HubMessage>

@property (nonatomic) NSString *invocationId;
@property (nonatomic) id result;
@property (nonatomic) NSString *error;
@property (nonatomic) BOOL hasResult;

- (instancetype)initWithInvocationId:(NSString *)invocationId;
- (instancetype)initWithInvocationId:(NSString *)invocationId result:(id)result;
- (instancetype)initWithInvocationId:(NSString *)invocationId error:(NSString*)error;

@end


