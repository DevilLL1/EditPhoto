//
//  ViewController.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/12.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "ViewController.h"
#import "YLEditViewController.h"

@interface ViewController ()<YLEditViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *upLoadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
- (IBAction)clickToUpLoadPhoto:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
   
}

- (IBAction)clickToUpLoadPhoto:(UIButton *)sender
{
    UIImagePickerController * pickerVC = [[UIImagePickerController alloc] init];
    pickerVC.delegate = self;
    pickerVC.allowsEditing = YES;
    //加载适合蜂窝移动数据流量的低质量图片
    pickerVC.videoQuality = UIImagePickerControllerQualityTypeLow;

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * camaAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            pickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:pickerVC animated:YES completion:nil];
        }
    }];
    UIAlertAction * albmAction  = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:pickerVC animated:YES completion:nil];
        }
    }];
    UIAlertAction * cancelAction  = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:camaAction];
    [alert addAction:albmAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - CameraViewControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.upLoadBtn.hidden = NO;
    [self dismissViewControllerAnimated:NO completion:nil];
    
    YLEditViewController * editVC = [[YLEditViewController alloc] init];
    editVC.delegate = self;
    editVC.image = image;
    [self presentViewController:editVC animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YLEditViewControllerDelegate
- (void)editViewController:(YLEditViewController *)cameraVC disClickToSaveImage:(UIImage *)image
{
    self.imgView.image = image;
}




@end
