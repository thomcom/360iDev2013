//
//  ViewController.h
//  Client
//
//  Created by Hugh Thomson Comer on 9/10/13.
//  Copyright (c) 2013 CardinalPeakLLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (retain) NSInputStream* inStream;
@property (retain) NSOutputStream* outStream;
- (IBAction)openPressed:(id)sender;
@end
