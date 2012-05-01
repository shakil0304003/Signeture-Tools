//
//  ViewController.m
//  SignetureTools
//
//  Created by USER on 4/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize isSignetureActive;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(isSignetureActive)
    {
        UIDevice *device = [UIDevice currentDevice];
        [device setOrientation:UIInterfaceOrientationPortrait animated:NO];
        
        if(((SignetureViewController*)signetureViewController).IsSaveSignature)
        {
            [btnClick setTitle:@"" forState:UIControlStateNormal];            
            imgView.image = ((SignetureViewController*)signetureViewController).SignetureImage;
        }
        
        isSignetureActive = FALSE;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(IBAction)Click:(id)sender
{
    if(signetureViewController == nil)
    {
        signetureViewController = [[SignetureViewController alloc] initWithNibName:@"SignetureViewController" bundle:nil];
    }
    
    ((SignetureViewController*)signetureViewController).FirstTimeInit = TRUE;
    [self.navigationController pushViewController:signetureViewController animated:YES];
    isSignetureActive = YES;
}

@end
