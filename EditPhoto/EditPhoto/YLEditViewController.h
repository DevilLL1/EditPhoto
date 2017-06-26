//
//  CameraViewController.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/17.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLEditViewController : UIViewController

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) UIImage * image;
@property (nonatomic, assign) NSInteger drawWidth;//默认为2
@property (nonatomic, retain) UIColor * drawColor;//默认为红

@end

@protocol YLEditViewControllerDelegate <NSObject>

- (void)editViewController:(YLEditViewController *)cameraVC disClickToSaveImage:(UIImage *)image;

@end
