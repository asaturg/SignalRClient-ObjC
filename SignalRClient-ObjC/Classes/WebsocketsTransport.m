//
//  WebsocketsTransport.m
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import "WebsocketsTransport.h"
#import "SocketRocket.h"

@interface WebsocketsTransport() <SRWebSocketDelegate> {
    
}

@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation WebsocketsTransport

- (void)start:(NSURL*)url {
    self.webSocket = [[SRWebSocket alloc] initWithURL:url];
    self.webSocket.delegate = self;
    [self.webSocket open];
}

- (void)close {
    [ self.webSocket close];
}

- (void)sendData:(NSData*)data withCompletion:(void (^)(NSError *error))handler {
    
    @try {
        [self.webSocket send:data];
    } @catch (NSException *exception) {
        //TODO: need to handle correct error
        if (handler) {
            handler([NSError errorWithDomain:@"co.realizeit.SignalRClient-ObjC" code:0 userInfo:nil]);
        }
    } @finally {
        if (handler) {
            handler(nil);
        }
    }
}

#pragma mark SRWebSocketDelegate methods

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    [self.delegate transportDidReceiveData:message];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    
    [self.delegate transportDidOpen];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self.delegate transportDidClose:error];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    //TODO: need to handle correct error
    [self.delegate transportDidClose:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload {
    
}


@end
