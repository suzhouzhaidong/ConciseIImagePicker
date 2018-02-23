//
//  ViewController.m
//  ConciseIImagePicker
//
//  Created by Snail Ark on 2018/2/23.
//  Copyright © 2018年 com.snailgames. All rights reserved.
//

#import "ViewController.h"
#import "ConciseImageCutViewController.h"
@interface ViewController ()<ConciseImageCutViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
}


-(void)conciseImageCutViewDidFinishCutWithImage:(UIImage *)image cutViewController:(UIViewController *)cutViewController{
    [cutViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)conciseImageCutViewDidCancel:(UIViewController *)cutViewController{
    [cutViewController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)showCutViewController:(id)sender {
     ConciseImageCutViewController *cutViewController = [ConciseImageCutViewController initWithOriginalImage:[UIImage imageNamed:@"test"] ratio:1.0 delegate:self];
    [self presentViewController:cutViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
