//
//  HubConnection.m
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import "HubConnection.h"
#import "JSONHubProtocol.h"
#import "InvocationDescriptor.h"

@interface HubConnection()<SocketConnectionDelegate> {
    
    NSInteger invocationId;
    dispatch_queue_t hubConnectionQueue;
    NSMutableDictionary *callbacks;
    NSMutableDictionary *pendingCalls;
}

@property (nonatomic) SocketConnection *connection;
@property (nonatomic) id<HubProtocol> hubProtocol;
@end

@implementation HubConnection

- (instancetype)initWithUrl:(NSURL *)url {
    return [self initWithUrl:url hubProtocol:[[JSONHubProtocol alloc] init]];
}

- (instancetype)initWithUrl:(NSURL *)url hubProtocol:(id<HubProtocol>)hubProtocol {
    if (self = [super init]) {
        self.connection = [[SocketConnection alloc] initWithUrl:url];
        self.hubProtocol = hubProtocol;
        
        callbacks = [NSMutableDictionary new];
        pendingCalls = [NSMutableDictionary new];

        hubConnectionQueue = dispatch_queue_create("SignalR.hubconnection.queue", NULL);
        self.connection.delegate = self;
    }
    
    return self;
}

- (void)start:(WebsocketsTransport*)transport {
    [self.connection start:transport];
}

- (void)connectionStarted {

    NSDictionary *json = @{@"protocol": self.hubProtocol.name};
    NSData *data = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:nil];
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    dataString= [dataString stringByAppendingFormat:@"%C", 0x1e];
    
    [self.connection sendData:[dataString dataUsingEncoding:NSUTF8StringEncoding] withCompletion:^(NSError *error) {
        if (error) {
            [self.delegate connectionDidFailToOpen:error];
        } else {
            [self.delegate connectionDidOpen:self];
        }
    }];
}

- (void)stop {
    [self.connection stop];
}

- (void)on:(NSString*)method callback:(void (^) (id arguments))callback {
    dispatch_sync(hubConnectionQueue, ^{
        callbacks[method] = callback;
    });
}

- (void)invokeMethod:(NSString *)method withArguments:(id)arguments withCompletion:(void (^) (id result, NSError* error))completion {
    
    __block NSInteger Id = 0;
    
    void (^callback)(NSArray* , NSError*) = ^void(NSArray* arguments, NSError* error) {
        if (error) {
            completion(nil, error);
            return;
        }
        completion(arguments, nil);
        
    };

    dispatch_sync(hubConnectionQueue, ^{
        invocationId += 1;
        Id = invocationId;
        pendingCalls[[NSString stringWithFormat:@"%@", @(invocationId)]] = callback;
    });

    InvocationMessage *invocationMessage = [[InvocationMessage alloc] initWithInvocationId:[NSString stringWithFormat:@"%@", @(invocationId)] target:method arguments:arguments nonBlocking:true];
    
    NSData *invocationData = [self.hubProtocol writeMessage:invocationMessage];
    [self.connection sendData:invocationData withCompletion:^(NSError *error) {
        if (error) {
            [pendingCalls removeObjectForKey:[NSString stringWithFormat:@"%@", @(invocationId)]];
            completion(nil, error);
        } else {
            completion(invocationMessage.arguments, nil);
        }
        
    }];
}

- (void)hubConnectionDidReceiveData:(NSString *)data {
    
    NSArray* hubMessages = [self.hubProtocol parseMessages:data];
    
    for (id<HubMessage> hubMessage in hubMessages) {
        switch (hubMessage.messageType) {
            case MessageTypeInvocation: {
                
                void (^callback)(NSArray*, NSError*) = callbacks[[(InvocationMessage*)hubMessage target]];
                if (callback) {
                    callback([(InvocationMessage*)hubMessage arguments], nil);
                }
            }

                break;
            case MessageTypeCompletion:
            case MessageTypeStreamItem:
                //TODO: handle this types
                break;
            default:
                break;

        }
    }
    
}

#pragma mark SocketConnectionDelegate methods

- (void)connectionDidOpen:(SocketConnection *)connection {
    [self connectionStarted];
}

- (void)connectionDidClose:(NSError *)error {
    
}

- (void)connectionDidFailToOpen:(NSError *)error {
    
}

- (void)connectionDidReceiveData:(NSString *)data connection:(SocketConnection *)connection {
    [self hubConnectionDidReceiveData:data];
}

@end
