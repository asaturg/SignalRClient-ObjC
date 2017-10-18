//
//  SocketConnection.m
//  Pods
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import "SocketConnection.h"
#import "HttpClient.h"

typedef NS_ENUM(NSUInteger, ConnectionState) {
    ConnectionStateUnknown = 0,
    ConnectionStateInitial = 1,
    ConnectionStateConnecting,
    ConnectionStateConnected,
    ConnectionStateStopped
};

@interface SocketConnection() <TransportDelegate> {
    dispatch_queue_t connectionQueue;
    dispatch_group_t startDispatchGroup;
}

@property (nonatomic) NSURL *url;
@property (nonatomic) id<TransportDelegate> transportDelegate;
@property (nonatomic) ConnectionState state;
@property (nonatomic) WebsocketsTransport *transport;

@end

@implementation SocketConnection

- (instancetype)initWithUrl:(NSURL*)url {
    if (self = [super init]) {
        self.url = url;
        self.transportDelegate = self;
        self.state = ConnectionStateInitial;
        
        connectionQueue = dispatch_queue_create("SignalR.connection.queue", NULL);
        startDispatchGroup = dispatch_group_create();
    }
    return self;
}

- (void)start:(WebsocketsTransport *)transport {
    if ([self changeStateFrom:ConnectionStateInitial to:ConnectionStateConnecting] == ConnectionStateUnknown) {
        //TODO: handle error - invalid state
        [self failOpenWithError:nil changeState:NO];
        return;
    }
    
    dispatch_group_enter(startDispatchGroup);
    
    [HttpClient optionsWithUrl:self.url completionHandler:^(HttpResponse *response, NSError *error) {
        if (error) {
            NSLog(@"error %@", error.debugDescription);
            dispatch_group_leave(startDispatchGroup);
            [self failOpenWithError:error changeState:YES];
        
        } else {
        
            if (response.statusCode == 200) {
                if (self.state != ConnectionStateConnecting) {
                    dispatch_group_leave(startDispatchGroup);
                    //TODO handle error - connectionIsBeingClosed
                    [self failOpenWithError:nil changeState:NO];
                } else {
                    
                    NSDictionary *contents = [NSJSONSerialization JSONObjectWithData:response.contents options:NSJSONReadingMutableContainers error:nil];
                    
                    NSString *connectionId = contents[@"connectionId"];
                    
                    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:self.url resolvingAgainstBaseURL:NO];
                    
                    NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:@"id" value:connectionId];
                    
                    [urlComponents setQueryItems:@[queryItem]];
                    
                    NSString *urlString = [[urlComponents URL] absoluteString];
                    urlString = [urlString stringByReplacingOccurrencesOfString:@"http" withString:@"ws"];
                    
                    self.transport = transport ? transport : [[WebsocketsTransport alloc] init];
                    self.transport.delegate = self.transportDelegate;
                    [transport start:[NSURL URLWithString:urlString]];
                    
                }
            } else {
                dispatch_group_leave(startDispatchGroup);
                //TODO handle error - HTTP request error. statusCode: response.statusCode
                [self failOpenWithError:nil changeState:YES];
            }
        }
    }];
}

- (void)sendData:(NSData*)data withCompletion:(void (^)(NSError *error))completion {
    if (self.state != ConnectionStateConnected) {
        // TODO: handle error invalid State
        completion(nil);
    } else {
        [self.transport sendData:data withCompletion:completion];
    }
}

- (void)stop {
    if (self.state == ConnectionStateStopped) {
        return;
    }
    
    ConnectionState previousState = [self changeStateFrom:ConnectionStateUnknown to:ConnectionStateStopped];
    if (previousState == ConnectionStateInitial) {
        return;
    }
    
    dispatch_async(connectionQueue, ^{
        dispatch_group_wait(startDispatchGroup,DISPATCH_TIME_NOW);
        
        if (self.transport) {
            [self.transport close];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate connectionDidClose:nil];
            });
        }
        

    });

}

- (void)failOpenWithError:(NSError *)error changeState:(BOOL)changeState {
    if (changeState) {
        [self changeStateFrom:ConnectionStateUnknown to:ConnectionStateStopped];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionDidFailToOpen:error];
    });
}

- (ConnectionState)changeStateFrom:(ConnectionState)from to:(ConnectionState)to {
    __block ConnectionState previousState = ConnectionStateUnknown;
    
    dispatch_sync(connectionQueue, ^{
        if (from == ConnectionStateUnknown || from == self.state) {
            previousState = self.state;
            self.state = to;
        }
    });
    
    return previousState;
}

#pragma mark TransportDelegate methods

- (void)transportDidOpen {
    ConnectionState previousState = [self changeStateFrom:ConnectionStateUnknown to:ConnectionStateConnected];
    
    NSAssert(previousState == ConnectionStateConnecting, nil);
    
    dispatch_group_leave(startDispatchGroup);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionDidOpen:self];
    });
    
}

- (void)transportDidClose:(NSError *)error {
    [self changeStateFrom:ConnectionStateUnknown to:ConnectionStateStopped];
    
    dispatch_async(connectionQueue, ^{
        dispatch_group_wait(startDispatchGroup,DISPATCH_TIME_NOW);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate connectionDidClose:error];
        });
    });
}

- (void)transportDidReceiveData:(NSData *)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate connectionDidReceiveData:data connection:self];
    });
}

@end
