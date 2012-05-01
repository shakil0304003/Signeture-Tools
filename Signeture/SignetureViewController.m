//
//  SignetureViewController.m
//  CybCommAudit
//
//  Created by USER on 3/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SignetureViewController.h"

#define degreesToRadians(x) (M_PI * (x) / 180.0)

@implementation SignetureViewController
@synthesize SignetureImage,IsSaveSignature;
@synthesize FirstTimeInit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) detectOrientation {

}

- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 320; // Or whatever
    
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    return imageCopy;
}

- (void)AddLastCurve
{
    if([points count]>0)
    {
        [allDrawings addObject:points];
        [allDrawingsColor addObject:currentColor];
        points = [[NSMutableArray alloc] init];
    }
}

- (void)Back
{
    /*
    if(pastIsPortait)
    {
        UIDevice *device = [UIDevice currentDevice];
        [device setOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
    */
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)Save
{
#ifdef __BLOCKS__
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Saving Image";
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{        
        
        [self AddLastCurve];
        SignetureImage = [self scaleAndRotateImage: imgSigneture.image];
        IsSaveSignature = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            allDrawings = [[NSMutableArray alloc] init];
            allDrawingsColor = [[NSMutableArray alloc] init];
            points = [[NSMutableArray alloc] init];
            [self Back];
        });
    }); 
#endif
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    currentColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]; 
    DrawingImage = FALSE;
    allDrawings = [[NSMutableArray alloc] init];
    allDrawingsColor = [[NSMutableArray alloc] init];
    
    self.navigationItem.title = @"Signeture";
    self.navigationController.navigationBarHidden = FALSE;
    navController = self.navigationController;
    navController.delegate = self;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(Save)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectOrientation) name:@"UIDeviceOrientationDidChangeNotification" object:nil]; 
    
    
    imgSigneture.layer.cornerRadius = 5;
    imgSigneture.clipsToBounds = YES;
    
    /*
    UIViewController *viewController = [[UIViewController alloc] init];
    [self presentModalViewController:viewController animated:NO];
    [self dismissModalViewControllerAnimated:NO];
     */
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(FirstTimeInit)
    {
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]))
            pastIsPortait = YES;
        else
            pastIsPortait = NO;
        FirstTimeInit = FALSE;
    }
    
    UIDevice *device = [UIDevice currentDevice];
    [device setOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateNormal];
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateHighlighted];
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateSelected];
    
    currentColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]; 
    allDrawings = [[NSMutableArray alloc] init];
    allDrawingsColor = [[NSMutableArray alloc] init];
    [self DrawAllLayer];
    IsSaveSignature = FALSE;
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:YES];
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:YES];
}

- (void)DrawAllLayer
{
    UIGraphicsBeginImageContext(imgSigneture.frame.size);

    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //sets the line width for a graphic context
    CGContextSetLineWidth(ctx,3.0);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    for (int i=0; i<[allDrawings count]; i++) {
        points = [allDrawings objectAtIndex:i];
        
        CGColorRef color = [[allDrawingsColor objectAtIndex:i] CGColor];
        const CGFloat *components = CGColorGetComponents(color);
        CGFloat red = components[0];
        CGFloat green = components[1];
        CGFloat blue = components[2];
        
        //set the line colour
        CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
        //creates a new empty path in a graphics context
        CGContextBeginPath(ctx);
        
        CGPoint point =  [[points objectAtIndex:0] CGPointValue];
        
        //begin a new path at the point you specify
        CGContextMoveToPoint(ctx, point.x, point.y);
        
        
        
        for (int j=1; j<[points count]; j++) {
            CGPoint point =  [[points objectAtIndex:j] CGPointValue];
            
            //Appends a straight line segment from the current point to the provided point 
            CGContextAddLineToPoint(ctx, point.x,point.y);    
        }
        
        //paints a line along the current path
        CGContextStrokePath(ctx);
    }
    
    imgSigneture.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    points = [[NSMutableArray alloc] init];
}

-(IBAction)UndoChangeClick:(id)sender
{
    if([allDrawings count]>0)
    {
        [allDrawings removeLastObject];
        [allDrawingsColor removeLastObject];
        [self DrawAllLayer];
    }
    
    if([allDrawings count]==0)
    {
        [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateNormal];
        [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateHighlighted];
        [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateSelected];
    }
}

-(IBAction)EraseAllClick:(id)sender
{
    [allDrawings removeAllObjects];
    [allDrawingsColor removeAllObjects];
    [self DrawAllLayer];
    
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateNormal];
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateHighlighted];
    [btnAddSignature setTitle:@"Please add signature here" forState:UIControlStateSelected];
}

-(void)DrawLastLayerLastLine
{
    UIGraphicsBeginImageContext(imgSigneture.frame.size);
    [imgSigneture.image drawInRect:CGRectMake(0, 0, imgSigneture.frame.size.width, imgSigneture.frame.size.height)];
    
    //sets the style for the endpoints of lines drawn in a graphics context
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineCap(ctx, kCGLineCapButt);
    //sets the line width for a graphic context
    CGContextSetLineWidth(ctx,3.0);
    
    CGColorRef color = [currentColor CGColor];
    const CGFloat *components = CGColorGetComponents(color);
    CGFloat red = components[0];
    CGFloat green = components[1];
    CGFloat blue = components[2];
    
    //set the line colour
    CGContextSetRGBStrokeColor(ctx, red, green, blue, 1.0);
    //creates a new empty path in a graphics context
    CGContextBeginPath(ctx);
    
    CGPoint point =  [[points objectAtIndex:([points count] - 2)] CGPointValue];
    
    //begin a new path at the point you specify
    CGContextMoveToPoint(ctx, point.x, point.y);
    point =  [[points objectAtIndex:([points count]-1)] CGPointValue];
    
    //Appends a straight line segment from the current point to the provided point 
    CGContextAddLineToPoint(ctx, point.x,point.y);    
    
    //paints a line along the current path
    CGContextStrokePath(ctx);
    
    imgSigneture.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
   
        if(pt.x >= imgSigneture.frame.origin.x && pt.x <= imgSigneture.frame.origin.x + imgSigneture.frame.size.width &&
           pt.y >=imgSigneture.frame.origin.y && pt.y <= imgSigneture.frame.origin.y + imgSigneture.frame.size.height)
        {
            [self AddLastCurve];
            DrawingImage = TRUE;
            pt.x = pt.x - imgSigneture.frame.origin.x;
            pt.y = pt.y - imgSigneture.frame.origin.y;
            points = [[NSMutableArray alloc] init];
            [points addObject:[NSValue valueWithCGPoint:pt]];
            
            [btnAddSignature setTitle:@"" forState:UIControlStateNormal];
            [btnAddSignature setTitle:@"" forState:UIControlStateHighlighted];
            [btnAddSignature setTitle:@"" forState:UIControlStateSelected];
        }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
        if(DrawingImage == TRUE)
        {
            if(pt.x >= imgSigneture.frame.origin.x && pt.x <= imgSigneture.frame.origin.x + imgSigneture.frame.size.width &&
               pt.y >= imgSigneture.frame.origin.y && pt.y <= imgSigneture.frame.origin.y + imgSigneture.frame.size.height)
            {
                pt.x = pt.x - imgSigneture.frame.origin.x;
                pt.y = pt.y - imgSigneture.frame.origin.y;
                [points addObject:[NSValue valueWithCGPoint:pt]];
                [self DrawLastLayerLastLine];
                [self AddLastCurve];
            }
            DrawingImage = FALSE;
        }
        else if(pt.x >= btnErrasAll.frame.origin.x && pt.x<= btnErrasAll.frame.origin.x + btnErrasAll.frame.size.width &&
                pt.y >= btnErrasAll.frame.origin.y && pt.y<= btnErrasAll.frame.origin.y + btnErrasAll.frame.size.height)
        {
            [self EraseAllClick:btnErrasAll];
        }
        else if(pt.x >= btnUndoChange.frame.origin.x && pt.x<= btnUndoChange.frame.origin.x + btnUndoChange.frame.size.width &&
                pt.y >= btnUndoChange.frame.origin.y && pt.y<= btnUndoChange.frame.origin.y + btnUndoChange.frame.size.height)
        {
            [self UndoChangeClick:btnUndoChange];
        }
        
        [self AddLastCurve];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if(DrawingImage == TRUE)
    {
        if(pt.x >= imgSigneture.frame.origin.x && pt.x <= imgSigneture.frame.origin.x + imgSigneture.frame.size.width &&
            pt.y >= imgSigneture.frame.origin.y && pt.y <= imgSigneture.frame.origin.y + imgSigneture.frame.size.height)
        {
            pt.x = pt.x - imgSigneture.frame.origin.x;
            pt.y = pt.y - imgSigneture.frame.origin.y;
            [points addObject:[NSValue valueWithCGPoint:pt]];
            [self DrawLastLayerLastLine];
        }
    }
}

@end
