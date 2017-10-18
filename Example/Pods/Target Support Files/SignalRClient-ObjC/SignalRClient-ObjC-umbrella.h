#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HttpClient.h"
#import "HttpResponse.h"
#import "HubConnection.h"
#import "HubProtocol.h"
#import "InvocationDescriptor.h"
#import "JSONHubProtocol.h"
#import "SocketConnection.h"
#import "WebsocketsTransport.h"

FOUNDATION_EXPORT double SignalRClient_ObjCVersionNumber;
FOUNDATION_EXPORT const unsigned char SignalRClient_ObjCVersionString[];

