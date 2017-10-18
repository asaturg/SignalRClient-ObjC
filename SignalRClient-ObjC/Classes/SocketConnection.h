//
//  SocketConnection.h
//  Pods
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import <Foundation/Foundation.h>
#import "WebsocketsTransport.h"

@class SocketConnection;

@protocol SocketConnectionDelegate <NSObject>

- (void)connectionDidOpen:(SocketConnection*)connection;
- (void)connectionDidFailToOpen:(NSError *)error;
- (void)connectionDidReceiveData:(NSString *)data connection:(SocketConnection*)connection;
- (void)connectionDidClose:(NSError *)error;

@end

@interface SocketConnection : NSObject

@property (nonatomic) id<SocketConnectionDelegate> delegate;

- (instancetype)initWithUrl:(NSURL*)url;

- (void)start:(WebsocketsTransport *)transport;
- (void)sendData:(NSData*)data withCompletion:(void (^)(NSError *error))completion;
- (void)stop;

@end
