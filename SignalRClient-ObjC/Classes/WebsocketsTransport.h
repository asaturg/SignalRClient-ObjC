//
//  WebsocketsTransport.h
//  Pods
//
//  Created by Asatur Galstyan on 10/17/17.
//

#import <Foundation/Foundation.h>

@protocol TransportDelegate <NSObject>

- (void)transportDidOpen;
- (void)transportDidReceiveData:(NSString *)data;
- (void)transportDidClose:(NSError *)error;

@end

@interface WebsocketsTransport : NSObject

@property (nonatomic) id<TransportDelegate> delegate;

- (void)start:(NSURL*)url;
- (void)close;
- (void)sendData:(id)data withCompletion:(void (^)(NSError *error))handler;

@end
