//
//  SnailImageCutViewController.h
//  GameTalk
//
//  Created by Snail Ark on 2018/1/11.
//  Copyright © 2018年 linfei. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol ConciseImageCutViewControllerDelegate<NSObject>

-(void)conciseImageCutViewDidFinishCutWithImage:(UIImage *)image cutViewController:(UIViewController *)cutViewController;

-(void)conciseImageCutViewDidCancel:(UIViewController *)cutViewController;;

@end

@interface ConciseImageCutViewController : UIViewController
@property(strong,nonatomic)UIImage *originalImage;

/**
 图片宽高比
 */
@property(nonatomic)float ratio;

@property(weak,nonatomic)id<ConciseImageCutViewControllerDelegate> delegate;

+(instancetype)initWithOriginalImage:(UIImage *)image ratio:(float)ration delegate:(id<ConciseImageCutViewControllerDelegate>)delegate;
@end
