//
//  HubConnection.h
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import <Foundation/Foundation.h>
#import "SocketConnection.h"
#import "HubProtocol.h"

@class HubConnection;

@protocol HubConnectionDelegate <NSObject>

- (void)connectionDidOpen:(HubConnection*)connection;
- (void)connectionDidFailToOpen:(NSError *)error;
- (void)connectionDidClose:(NSError *)error;

@end

@interface HubConnection : NSObject

@property (nonatomic) id<HubConnectionDelegate> delegate;

- (instancetype)initWithUrl:(NSURL*)url;
- (instancetype)initWithUrl:(NSURL*)url hubProtocol:(id<HubProtocol>)hubProtocol;

- (void)start:(WebsocketsTransport*)transport;
- (void)stop;

- (void)on:(NSString*)method callback:(void (^) (id arguments))callback;
- (void)invokeMethod:(NSString *)method withArguments:(id)arguments withCompletion:(void (^) (id result, NSError* error))completion;

@end
