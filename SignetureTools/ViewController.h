//
//  ViewController.h
//  SignetureTools
//
//  Created by USER on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignetureViewController.h"

@interface ViewController : UIViewController
{
    UIViewController *signetureViewController;
    IBOutlet UIImageView *imgView;
    IBOutlet UIButton *btnClick;
}

@property (assign) BOOL isSignetureActive;

-(IBAction)Click:(id)sender;

@end
