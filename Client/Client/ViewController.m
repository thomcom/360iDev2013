//
//  ViewController.m
//  Client
//
//  Created by Hugh Thomson Comer on 9/10/13.
//  Copyright (c) 2013 CardinalPeakLLC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSStreamDelegate>
@property NSString* address;
@property NSInteger port;
@property BOOL outStreamIsOpen;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)openPressed:(id)sender{
//    self.address = @"172.19.181.226";
    self.address = @"198.18.118.106";
    self.port = 10240;
    // when outstream has its first HasSpaceAvailable event it will initiate the HTTP POST header
    // only once per button press.
    self.outStreamIsOpen = FALSE;
    
        NSLog(@"Connect to Address: %@:%d",self.address,self.port);
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.address, self.port, &readStream, &writeStream);
    NSInputStream *inputStream = (__bridge_transfer NSInputStream *)readStream;
    NSOutputStream *outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
    self.inStream = inputStream;
    self.outStream = outputStream;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    NSString* who;
    if( aStream == self.inStream ) {
        who = @"Instream";
    }
    if( aStream == self.outStream ) {
        who = @"Outstream";
    }
    switch(eventCode){
        case NSStreamEventNone:{
            NSLog(@"%@ NSStreamEventNone", who);
            break;
        }
        case NSStreamEventOpenCompleted:{
            NSLog(@"%@ NSStreamEventOpenCompleted", who);
            break;
        }
        case NSStreamEventHasBytesAvailable:{
            NSLog(@"%@ NSStreamEventHasBytesAvailable", who);
            if( aStream == self.inStream ){
                char* bytes = malloc(2000);
                uint32_t size = [self.inStream read:(uint8_t*)bytes maxLength:2000];
                if( size < 2000 ) bytes[size-1] = '\0';
                else bytes[1999] = '\0';
                NSLog(@"Instream Read %d Bytes from server:\n %s",size,bytes);
                if( size > 0 ){
                    NSLog(@"%s",bytes);
                }
                
                free(bytes);
            }
            break;
        }
        case NSStreamEventHasSpaceAvailable:{
            NSLog(@"%@ NSStreamEventHasSpaceAvailable initialize connection", who);
            if( aStream == self.outStream ){
                if(self.outStreamIsOpen==FALSE){
                    char* buf = "4*4";
                    [self.outStream write:buf maxLength:3];
                    self.outStreamIsOpen = TRUE;
                }
            }
            break;
        }
        case NSStreamEventErrorOccurred:{
            NSLog(@"%@ NSStreamEventErrorOccurred", who);
            // TODO: Handle error event involving unable to connect to server.
            // Bad Authentication
            // Host doesn't exist
            // 404 error
            // ?
            NSError* error = [aStream streamError];
            NSString* errorMessage = [NSString stringWithFormat:@"%@ (Code = %d)",
                                      [error localizedDescription],
                                      [error code]];
            NSLog(@"%@",errorMessage);
            break;
        }
        case NSStreamEventEndEncountered:{
            NSLog(@"%@ NSStreamEventEndEncountered", who);
            if( aStream == self.inStream ){
                char* bytes = malloc(2000);
                uint32_t size = [self.inStream read:(uint8_t*)bytes maxLength:2000];
                if( size < 2000 ) bytes[size-1] = '\0';
                else bytes[1999] = '\0';
                NSLog(@"Instream Bytes: %s",bytes);
                free(bytes);
            }
            break;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//if( self.outStreamIsOpen == FALSE ){
//    NSString* postMsg = [NSString stringWithCString:"POST /v1/api.cgi HTTP/1.1\r\n" encoding:NSUTF8StringEncoding];
//    NSString* authorizationString = [NSString stringWithFormat:@"Authorization: %@\r\n",self.httpBasicAuthenticationString];
//    postMsg = [postMsg stringByAppendingString:authorizationString];
//    postMsg = [postMsg stringByAppendingString:[NSString stringWithCString:"User-Agent: 360|iDev Client\r\n" encoding:NSUTF8StringEncoding]];
//    postMsg = [postMsg stringByAppendingString:[NSString stringWithCString:"Accept: */*\r\n" encoding:NSUTF8StringEncoding]];
//    //                postMsg = [postMsg stringByAppendingString:[NSString stringWithCString:"Content-Type: audio/basic\r\n" encoding:NSUTF8StringEncoding]];
//    postMsg = [postMsg stringByAppendingString:[NSString stringWithCString:"Content-Length: 30000000\r\n" encoding:NSUTF8StringEncoding]];
//    postMsg = [postMsg stringByAppendingString:[NSString stringWithCString:"Expect: 100-continue\r\n\r\n" encoding:NSUTF8StringEncoding]];
//    NSLog(@"%@",postMsg);
//    [self.outStream write:(uint8_t*)[postMsg cStringUsingEncoding:NSUTF8StringEncoding] maxLength:[postMsg length]];
//}

@end
