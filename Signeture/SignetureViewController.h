//
//  SignetureViewController.h
//  CybCommAudit
//
//  Created by USER on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "ViewController.h"

@interface UIDevice (UndocumentedFeatures) 
-(void)setOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
-(void)setOrientation:(UIInterfaceOrientation)orientation;
@end

@interface SignetureViewController : UIViewController<UINavigationControllerDelegate>
{
    UINavigationController *navController;
    IBOutlet UIImageView *imgSigneture;
    
    NSMutableArray *points;
    NSMutableArray *allDrawings;
    NSMutableArray *allDrawingsColor;
    UIColor *currentColor;
    CGFloat LastY;
    BOOL DrawingImage;
    
    IBOutlet UIButton *btnErrasAll;
    IBOutlet UIButton *btnUndoChange;
    BOOL pastIsPortait;
    
    IBOutlet UIButton *btnAddSignature;
}

@property (nonatomic, retain) UIImage *SignetureImage;
@property (nonatomic) BOOL IsSaveSignature;
@property (assign) BOOL FirstTimeInit;

-(IBAction)UndoChangeClick:(id)sender;
-(IBAction)EraseAllClick:(id)sender;
- (void)DrawAllLayer;

@end
