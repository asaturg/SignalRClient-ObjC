//
//  InvocationDescriptor.h
//  SignalRClient-ObjC
//
//  Created by Asatur Galstyan on 10/18/17.
//

#import <Foundation/Foundation.h>

@interface InvocationDescriptor : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString *method;
@property (nonatomic) NSArray *arguments;

- (instancetype)initWithId:(NSInteger)id method:(NSString*)method arguments:(NSArray*)arguments;

@end

@interface InvocationResult : NSObject

@property (nonatomic) NSInteger id;
@property (nonatomic) NSString* error;

- (id)getResult;

@end
