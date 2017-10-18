//
//  AGViewController.m
//  SignalRClient-ObjC
//
//  Created by asaturg@gmail.com on 10/17/2017.
//  Copyright (c) 2017 asaturg@gmail.com. All rights reserved.
//

#import "AGViewController.h"
#import "HubConnection.h"

@interface AGViewController () <HubConnectionDelegate> {
    HubConnection *hubConnection;
}

@end

@implementation AGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    hubConnection = [[HubConnection alloc] initWithUrl:[NSURL URLWithString:@"http://localhost:51996/cablr"]];
    hubConnection.delegate = self;
    [hubConnection start:[[WebsocketsTransport alloc] init]];
    
    [hubConnection on:@"NewMessage" callback:^(id arguments) {
        NSLog(@"arguments %@" , arguments);
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectionDidClose:(NSError *)error {
    NSLog(@"HubConnectionDidClose: %@" , [error localizedDescription]);
}

- (void)connectionDidFailToOpen:(NSError *)error {
    NSLog(@"HubConnectionDidFailToOpen: %@" , [error localizedDescription]);
}

- (void)connectionDidOpen:(HubConnection *)connection {
    NSLog(@"HubConnectionDidOpen");
    
    [hubConnection invokeMethod:@"Broadcast" withArguments:@[@"bbb",@"ccc"] withCompletion:^(id result, NSError *error) {
        NSLog(@"result %@", result);
    }];
}

@end
