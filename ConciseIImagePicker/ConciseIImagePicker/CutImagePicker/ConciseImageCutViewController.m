//
//  SnailImageCutViewController.m
//  GameTalk
//
//  Created by Snail Ark on 2018/1/11.
//  Copyright © 2018年 linfei. All rights reserved.
//

#import "ConciseImageCutViewController.h"
@interface ConciseImageCutViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *leftTopCorner;
@property (strong, nonatomic) IBOutlet UIView *leftbottomCorner;
@property (strong, nonatomic) IBOutlet UIView *rightTopCorner;
@property (strong, nonatomic) IBOutlet UIView *rightBottomCorner;
@property (strong, nonatomic) IBOutlet UIView *cutView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cutViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cutViewWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *cutViewVerticalCenter;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *curHorizonCenter;
@property (strong, nonatomic) IBOutlet UIImageView *origialImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UIView *shadeView;
@property(strong,nonatomic)CAShapeLayer *bgLayer;
@property(strong,nonatomic)CAShapeLayer *cutLayer;
@property(nonatomic)BOOL isLandScape;
@property(nonatomic)float imagescale;
@end

@implementation ConciseImageCutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.originalImage = [self fixOrientation:self.originalImage];
    self.origialImageView.image = self.originalImage;
    self.imageScrollView.maximumZoomScale = 10.0;
    self.imageScrollView.minimumZoomScale = 1.0;
    self.imageScrollView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - (self.view.bounds.size.width-24.0)/_ratio)/2.0, 0, (self.view.bounds.size.height - (self.view.bounds.size.width-24.0)/_ratio)/2.0, 0);
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    self.imageScrollView.showsVerticalScrollIndicator = NO;
    self.imageScrollView.delegate = self;
    if (self.originalImage.size.height > self.originalImage.size.width) {
        self.isLandScape = NO;
        self.imagescale = (self.view.bounds.size.width - 24.0)/self.originalImage.size.width;
        self.imageWidth.constant = self.view.bounds.size.width - 24.0;
        self.imageHeight.constant = (self.view.bounds.size.width - 24.0)*(self.originalImage.size.height/self.originalImage.size.width);
    }
    else{
        self.isLandScape = YES;
        if ((self.originalImage.size.width/self.originalImage.size.height) >= _ratio) {
            self.imagescale = (self.view.bounds.size.width - 24.0)/(self.originalImage.size.height*_ratio);
            self.imageHeight.constant = (self.view.bounds.size.width - 24.0)/_ratio;
            self.imageWidth.constant = self.imagescale*self.originalImage.size.width;
        }
        else{
            self.imagescale = (self.view.bounds.size.width - 24.0)/self.originalImage.size.height;
            self.imageHeight.constant = (self.view.bounds.size.width - 24.0);
            self.imageWidth.constant = (self.view.bounds.size.width - 24.0)*self.originalImage.size.width/self.originalImage.size.height;
        }
   
    }
    self.cutViewWidth.constant = self.view.bounds.size.width - 24.0;
    self.cutViewHeight.constant = self.view.bounds.size.height;
    self.cutViewVerticalCenter.constant = (self.view.bounds.size.height - self.view.bounds.size.width+24.0)/2.0;
    if (_isLandScape) {
        self.imageScrollView.contentOffset = CGPointMake(0, -(self.view.bounds.size.height - self.cutViewHeight.constant)/2.0);
    }
    else{
        self.imageScrollView.contentOffset = CGPointMake(0, -(self.view.bounds.size.height - _imageHeight.constant)/2.0);
    }
    // Do any additional setup after loading the view.
}

+(instancetype)initWithOriginalImage:(UIImage *)image ratio:(float)ration delegate:(id<ConciseImageCutViewControllerDelegate>)delegate{
    ConciseImageCutViewController *cutViewController = [[UIStoryboard storyboardWithName:@"ImagePicker" bundle:nil] instantiateViewControllerWithIdentifier:@"ConciseImageCutViewController"];
    cutViewController.ratio = ration;
    cutViewController.delegate = delegate;
    cutViewController.originalImage = image;
    return cutViewController;
}

-(void)viewDidAppear:(BOOL)animated{
    [UIView animateWithDuration:0.3 animations:^{
        self.cutViewHeight.constant = (self.view.bounds.size.width - 24.0)/_ratio;
        self.cutViewWidth.constant = self.view.bounds.size.width - 24.0;
        self.cutViewVerticalCenter.constant = 0.0;
        self.curHorizonCenter.constant = 0.0;
        [self.view layoutIfNeeded];
        CAShapeLayer *bgShapeLayer = [CAShapeLayer layer];
        bgShapeLayer.frame = self.view.bounds;
        bgShapeLayer.fillRule = kCAFillRuleEvenOdd;
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, nil,  CGRectMake(12.0, (self.view.bounds.size.height - self.cutViewHeight.constant)/2.0, self.cutViewWidth.constant, self.cutViewHeight.constant));
        CGPathAddRect(path, nil,self.shadeView.bounds);
        [bgShapeLayer setPath:path];
        bgShapeLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
        self.bgLayer  = bgShapeLayer;
        [self.shadeView.layer addSublayer:bgShapeLayer];
    }];


    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didMoveToCorner:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.bgLayer.fillColor = [UIColor clearColor].CGColor;
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        if ([sender.view isEqual:_leftTopCorner]) {
            CGPoint currentpoint = [sender translationInView:self.view];
            float change = MAX(currentpoint.y/_ratio, currentpoint.x);
            float currentWidth = self.view.bounds.size.width - 24.0 - change;
            if (currentWidth <= self.view.bounds.size.width - 24.0 && currentWidth >= 80.0) {
                self.cutViewWidth.constant = currentWidth;
                self.cutViewHeight.constant = currentWidth/_ratio;
                self.cutViewVerticalCenter.constant = change/(2.0*_ratio);
                self.curHorizonCenter.constant = change/2.0;
                [self.view layoutIfNeeded];
            }
        }
        if ([sender.view isEqual:_leftbottomCorner]) {
            CGPoint currentpoint = [sender translationInView:self.view];
            float change = MAX(-currentpoint.y/_ratio, currentpoint.x);
            float currentWidth = self.view.bounds.size.width - 24.0 - change;
            if (currentWidth <= self.view.bounds.size.width - 24.0 && currentWidth >= 80.0) {
                self.cutViewWidth.constant = currentWidth;
                self.cutViewHeight.constant = currentWidth/_ratio;
                self.cutViewVerticalCenter.constant = -change/(2.0*_ratio);
                self.curHorizonCenter.constant = change/2.0;
                [self.view layoutIfNeeded];
            }
            
            NSLog(@"%.1f,%.1f",currentpoint.y,currentpoint.x);
        }
        if ([sender.view isEqual:_rightTopCorner]) {
            CGPoint currentpoint = [sender translationInView:self.view];
            float change = MAX(currentpoint.y/_ratio, -currentpoint.x);
            float currentWidth = self.view.bounds.size.width - 24.0 - change;
            if (currentWidth <= self.view.bounds.size.width - 24.0 && currentWidth >= 80.0) {
                self.cutViewWidth.constant = currentWidth;
                self.cutViewHeight.constant = currentWidth/_ratio;
                self.cutViewVerticalCenter.constant = change/(2.0*_ratio);
                self.curHorizonCenter.constant = -change/2.0;
                [self.view layoutIfNeeded];
            }
        }
        if ([sender.view isEqual:_rightBottomCorner]) {
            CGPoint currentpoint = [sender translationInView:self.view];
            float change = MAX(-currentpoint.y/_ratio, -currentpoint.x);
            float currentWidth = self.view.bounds.size.width - 24.0 - change;
            if (currentWidth <= self.view.bounds.size.width - 24.0 && currentWidth >= 80.0) {
                self.cutViewWidth.constant = currentWidth;
                self.cutViewHeight.constant = currentWidth/_ratio;
                self.cutViewVerticalCenter.constant = -change/(2.0*_ratio);
                self.curHorizonCenter.constant = -change/2.0;
                [self.view layoutIfNeeded];
            }
        }
    }
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(cutViewResumeToBack) withObject:nil afterDelay:0.3];
    }
}


-(void)cutViewResumeToBack{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect zoom = [self.view convertRect:self.cutView.frame toView:self.origialImageView];
        [self.imageScrollView zoomToRect:zoom animated:YES];
        self.cutViewHeight.constant = (self.view.bounds.size.width - 24.0)/_ratio
        ;
        self.cutViewWidth.constant = self.view.bounds.size.width - 24.0;
        self.cutViewVerticalCenter.constant = 0.0;
        self.curHorizonCenter.constant = 0.0;
        self.bgLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)cancel:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(conciseImageCutViewDidCancel:)]) {
        [_delegate conciseImageCutViewDidCancel:self];
    }
}
- (IBAction)complete:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect currentrect = [self.view convertRect:self.cutView.frame toView:self.origialImageView];
        //        self.originalImage.imageOrientation
        CGRect realRect = CGRectMake(currentrect.origin.x/(self.imagescale), currentrect.origin.y/(self.imagescale), currentrect.size.width/(self.imagescale), currentrect.size.height/(self.imagescale));
        CGImageRef imgRef = CGImageCreateWithImageInRect(self.originalImage.CGImage, realRect);
        CGFloat deviceScale = [UIScreen mainScreen].scale;
        UIGraphicsBeginImageContextWithOptions(self.cutView.bounds.size, 0, deviceScale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.cutView.bounds.size.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, CGRectMake(0, 0,  self.cutView.bounds.size.width,  self.cutView.bounds.size.height), imgRef);
        UIImage *cutImage = UIGraphicsGetImageFromCurrentImageContext();
        CGImageRelease(imgRef);
        UIGraphicsEndImageContext();
        if (_delegate && [_delegate respondsToSelector:@selector(conciseImageCutViewDidFinishCutWithImage:cutViewController:)]) {
            [_delegate conciseImageCutViewDidFinishCutWithImage:cutImage cutViewController:self];
        }
    });
}


-(UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}



- (IBAction)resume:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.bgLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
        self.imageScrollView.zoomScale = 1.0;
        self.imageScrollView.contentInset = UIEdgeInsetsMake((self.view.bounds.size.height - (self.view.bounds.size.width-24.0)/_ratio)/2.0, 0, (self.view.bounds.size.height - (self.view.bounds.size.width-24.0)/_ratio)/2.0, 0);
        if (_isLandScape) {
            self.imageScrollView.contentOffset = CGPointMake(0, -(self.view.bounds.size.height - self.cutViewHeight.constant)/2.0);
        }
        else{
            self.imageScrollView.contentOffset = CGPointMake(0, -(self.view.bounds.size.height - _imageHeight.constant)/2.0);
        }
     
        
    });

   
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
   
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.origialImageView;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     self.bgLayer.fillColor = [UIColor clearColor].CGColor;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.bgLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
}

-(void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
      self.bgLayer.fillColor = [UIColor clearColor].CGColor;
}


-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    self.bgLayer.fillColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7].CGColor;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
