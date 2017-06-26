//
//  CameraViewController.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/17.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "YLEditViewController.h"
#import "YLCutView.h"
#import "YLTipTextField.h"
#import "YLDrawView.h"
#import "YLColorWidthView.h"
#import "YLDrawModel.h"

@interface YLEditViewController ()<UIGestureRecognizerDelegate, UITextFieldDelegate, YLColorWidthViewDelegate>
{
    UIButton * _preBtn;
    CGPoint _location;//裁剪
    YLTipTextField * _preField;//文本
}

//记录开始的缩放比例
@property(nonatomic,assign)CGFloat beginGestureScale;
//最后的缩放比例
@property(nonatomic,assign)CGFloat effectiveScale;
@property (nonatomic, retain) YLCutView * cutView;
@property (nonatomic, assign) PanType panType;
@property (nonatomic, retain) YLDrawView * shape;
@property (nonatomic, retain) YLDrawModel * shapeModel;

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@end

@implementation YLEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.drawColor = [UIColor redColor];
    self.drawWidth = 2;
    self.deleteBtn.hidden = YES;
    [self ajustImageView];
    [self addShape];
    
    self.beginGestureScale = 1;
    self.effectiveScale = 1;
    [self addPinchGesture];
    
}

#pragma mark - Private
- (void)addPinchGesture
{    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinch.delegate = self;
    [self.shape addGestureRecognizer:pinch];
}

- (void)ajustImageView
{
    self.imgView.userInteractionEnabled = YES;
    CGSize imgSize = self.image.size;
    CGFloat scaleW = APP_W / imgSize.width;
    CGFloat imgViewH = imgSize.height * scaleW;
    if (imgViewH > APP_H - 64*2) {
        CGFloat scaleH = (APP_H - 64*2) / imgSize.height;
        CGFloat imgViewW = imgSize.width * scaleH;
        self.imgView.frame = CGRectMake(0, 0, imgViewW, APP_H - 64*2);
    }else{
        self.imgView.frame = CGRectMake(0, 0, APP_W, imgViewH);
    }
    self.imgView.center = CGPointMake(APP_W/2, APP_H/2);
    self.imgView.image = self.image;
}

- (void)addShape
{
    self.shape = [[YLDrawView alloc] initWithFrame:CGRectMake(0, 0, self.imgView.frame.size.width, self.imgView.frame.size.height)];
    
    //将管理绘制的View添加到ImgView上，方便合成
    [self.imgView addSubview:self.shape];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToAddOrMovePath:)];
    [self.shape addGestureRecognizer:pan];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSelectShapeOrAddText:)];
    [self.shape addGestureRecognizer:tap];
    
}

- (void)addSubviewOnFieldWithTextField:(YLTipTextField *)textField
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, textField.frame.size.width, textField.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    [textField addSubview:view];
    
    UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToSelect:)];
    [view addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToEdit:)];
    doubleTap.numberOfTapsRequired = 2;
    [view addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToMove:)];
    [view addGestureRecognizer:pan];
}

- (void)canDeleteShape
{
    self.deleteBtn.hidden = YES;
    for (UIView * view in self.shape.shapeArr) {
        if ([view isKindOfClass:[YLTipTextField class]]) {
            YLTipTextField * field = (YLTipTextField *)view;
            if (field.isSelect) {
                self.deleteBtn.hidden = NO;
            }
        }
        if ([view isKindOfClass:[YLDrawModel class]]) {
            YLDrawModel * model = (YLDrawModel *)view;
            if (model.selected) {
                self.deleteBtn.hidden = NO;
            }
        }
    }
}

- (void)cutImage
{
    //获取裁剪范围
    CGRect cutViewFrame = CGRectMake(self.cutView.beginPoint.x, self.cutView.beginPoint.y, self.cutView.cutSize.width, self.cutView.cutSize.height);
    CGFloat orgX = cutViewFrame.origin.x * (self.image.size.width/self.imgView.frame.size.width);
    CGFloat orgY = cutViewFrame.origin.y * (self.image.size.height/self.imgView.frame.size.height);
    CGFloat width = cutViewFrame.size.width * (self.image.size.width/self.imgView.frame.size.width);
    CGFloat height = cutViewFrame.size.height * (self.image.size.height/self.imgView.frame.size.height);
    //将裁剪范围映射到原图
    CGRect mapRect = CGRectMake(orgX, orgY, width, height);
    
    CGSize size = self.image.size;
    //变换矩阵，x向右为正，y向上为正
    CGAffineTransform transform = CGAffineTransformMake(1, 0, 0, 1, 0, 0);
    CGFloat deviceScale = [UIScreen mainScreen].scale;
    //根据矩阵旋转坐标
    UIGraphicsBeginImageContextWithOptions(size, YES, deviceScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, size.width / 2, size.height / 2);
    CGContextConcatCTM(context, transform);
    CGContextTranslateCTM(context, size.width / -2, size.height / -2);
    [self.image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //获取图片
    CGFloat scale = rotatedImage.scale;
    CGRect cropRect = CGRectApplyAffineTransform(mapRect, CGAffineTransformMakeScale(scale, scale));
    CGImageRef croppedImage = CGImageCreateWithImageInRect(rotatedImage.CGImage, cropRect);
    UIImage *newImg = [UIImage imageWithCGImage:croppedImage scale:deviceScale orientation:rotatedImage.imageOrientation];
    CGImageRelease(croppedImage);
    
    self.image = newImg;
    [self.cutView removeFromSuperview];
    self.imgView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self ajustImageView];
    
}

- (void)composeImageAndShape
{
    //合成image和路径（管理路径的view需添加到imageView上）
    UIGraphicsBeginImageContext(CGSizeMake(self.imgView.frame.size.width, self.imgView.frame.size.height));
    [self.imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * newImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.image = newImg;
    if ([_delegate respondsToSelector:@selector(editViewController:disClickToSaveImage:)]) {
        [_delegate editViewController:self disClickToSaveImage:self.image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PinchGestureDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ( [gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidChanged:(UITextField *)textField
{
    CGRect rect = [textField.text boundingRectWithSize:CGSizeMake(APP_W, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:self.drawWidth + 8]} context:nil];
    if (rect.size.width > 0) {
        CGRect fieldRect = textField.frame;
        fieldRect.size.width = rect.size.width + 10;
        textField.frame = fieldRect;
    }
}

- (BOOL)textFieldShouldReturn:(YLTipTextField *)textField
{
    if ([textField.text isEqualToString:@""]) {
        [textField removeFromSuperview];
        return YES;
    }
    textField.canSelect = YES;
    textField.layer.borderColor = [UIColor clearColor].CGColor;
    [textField resignFirstResponder];
    
    [self addSubviewOnFieldWithTextField:textField];
    return YES;
}

#pragma mark - YLColorWidthViewDelegate
- (void)colorWidthView:(YLColorWidthView *)view didSelectAWidth:(NSInteger)width
{
    self.drawWidth = width;
}

- (void)colorWidthView:(YLColorWidthView *)view didSelectAColor:(UIColor *)color
{
    self.drawColor = color;
}

#pragma mark - Action
- (IBAction)clickToCut:(UIButton *)sender
{
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [self.saveBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.saveBtn setBackgroundImage:[UIImage imageNamed:@""]forState:UIControlStateNormal];

    _preBtn.backgroundColor = [UIColor blackColor];
    sender.backgroundColor = [UIColor lightGrayColor];
    _preBtn = sender;
    
    self.panType = PanType_Cut;
    self.imgView.transform = CGAffineTransformMakeScale(0.8, 0.8);

    if (!self.cutView.superview) {
        YLCutView * cutView = [[YLCutView alloc] initWithFrame:self.imgView.frame];
        self.cutView = cutView;
        cutView.oldBeginPoint = cutView.beginPoint;
        cutView.oldEndPoint = cutView.endPoint;
        [self.view addSubview:cutView];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panToCutImage:)];
        [cutView addGestureRecognizer:pan];
    }
}

- (IBAction)clickToAddShape:(UIButton *)sender
{
    _preBtn.backgroundColor = [UIColor blackColor];
    sender.backgroundColor = [UIColor lightGrayColor];
    _preBtn = sender;
    switch (sender.tag) {
        case 0:
            self.panType = PanType_Rect;
            break;
        case 1:
            self.panType = PanType_Arrow;
            break;
        case 2:
            self.panType = PanType_Path;
            break;
        case 3:
            self.panType = PanType_Text;
            break;
        default:
            break;
    }
    
}

- (IBAction)clickToChangeColorOrWidth:(UIButton *)sender
{
    YLColorWidthView * cw = [[YLColorWidthView alloc] init];
    cw.delegate = self;
//    cw.type = self.panType;
    [cw showWidthViewWithPosition:sender.center];
    [cw showColorViewWithPosition:sender.center];
    [self.view addSubview:cw];
}

- (IBAction)clickToRevert:(UIButton *)sender
{
    [sender setImage:[UIImage imageNamed:@"revert_gray"] forState:UIControlStateHighlighted];
    BOOL isMoveBack = NO;
    for (UIView * view in self.shape.shapeArr) {
        if ([view isKindOfClass:[YLTipTextField class]]) {
            YLTipTextField * field = (YLTipTextField *)view;
            CGRect oldFrame = [[field.oldFrameArr lastObject] CGRectValue];
            if (!CGRectEqualToRect(oldFrame, CGRectZero)  && !CGRectEqualToRect(field.frame, oldFrame)) {
                isMoveBack = YES;
                field.frame = oldFrame;
                [field.oldFrameArr removeLastObject];
            }
            NSString * oldText = [field.oldTextArr lastObject];
            if (oldText != nil  && ![oldText isEqualToString:field.text]) {
                isMoveBack = YES;
                field.text = oldText;
                [field.oldTextArr removeLastObject];
            }
        }else{
            YLDrawModel * model = (YLDrawModel *)view;
            CGPoint oldStartPoint = [[model.oldStartPointArr lastObject] CGPointValue];
            CGPoint oldEndPoint = [[model.oldEndPointArr lastObject] CGPointValue];
            NSMutableArray * oldPointArr = [model.oldPointArr lastObject];
            if (!CGPointEqualToPoint(oldEndPoint, CGPointZero) && !CGPointEqualToPoint(model.startPoint, oldStartPoint)) {
                isMoveBack = YES;
                model.startPoint = oldStartPoint;
                model.endPoint = oldEndPoint;
                model.pointArr = oldPointArr;
                [model.oldStartPointArr removeLastObject];
                [model.oldEndPointArr removeLastObject];
                [model.oldPointArr removeLastObject];
                [self.shape setNeedsDisplay];
            }
        }
    }
    
    if (!isMoveBack) {
        UIView * view = [self.shape.shapeArr lastObject];
        if ([view isKindOfClass:[YLTipTextField class]]) {
            YLTipTextField * field = (YLTipTextField *)view;
            [field removeFromSuperview];
            [self.shape.shapeArr removeLastObject];
        }else{
            
            [self.shape.shapeArr removeLastObject];
            [self.shape setNeedsDisplay];
        }
    }
    [self canDeleteShape];
}
         
- (IBAction)clickToCancel:(UIButton *)sender
{
    _preBtn.backgroundColor = [UIColor blackColor];
    if ([self.cancelBtn.titleLabel.text isEqualToString:@"取消"]) {
        [self.cancelBtn setTitle:nil forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.text = nil;
        [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.saveBtn setTitle:nil forState:UIControlStateNormal];
        self.saveBtn.titleLabel.text = nil;
        [self.saveBtn setBackgroundImage:[UIImage imageNamed:@"save"]forState:UIControlStateNormal];
        [self.cutView removeFromSuperview];
        self.imgView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)clickToDelete:(UIButton *)sender
{
    for (NSUInteger i = self.shape.shapeArr.count; i > 0; i--) {
        UIView * view = self.shape.shapeArr[i-1];
        if ([view isKindOfClass:[YLTipTextField class]]) {
            YLTipTextField * field = (YLTipTextField *)view;
            if (field.isSelect == YES) {
                [field removeFromSuperview];
                [self.shape.shapeArr removeObject:field];
            }
        }else{
            YLDrawModel * model = (YLDrawModel *)view;
            if (model.selected == YES) {
                [self.shape.shapeArr removeObject:model];
                [self.shape setNeedsDisplay];
            }
        }
    }
    [self canDeleteShape];
   
}

- (IBAction)clickToSave:(UIButton *)sender
{
    _preBtn.backgroundColor = [UIColor blackColor];
    if ([self.saveBtn.titleLabel.text isEqualToString:@"完成"]) {
        [self.cancelBtn setTitle:nil forState:UIControlStateNormal];
        self.cancelBtn.titleLabel.text = nil;
        [self.cancelBtn setBackgroundImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.saveBtn setTitle:nil forState:UIControlStateNormal];
        self.saveBtn.titleLabel.text = nil;
        [self.saveBtn setBackgroundImage:[UIImage imageNamed:@"save"]forState:UIControlStateNormal];
        [self cutImage];
    }else{
        [self composeImageAndShape];
    }
    //保存到相册
    //UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    NSLog(@"WriteToPhotosAlbum-error>>>>>%@",error);
}

#pragma mark - Gesture
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch
{
    BOOL touchesOnPreviewLayer = YES;
    NSUInteger numTouches = [pinch numberOfTouches];
    for (int i = 0; i < numTouches; i++ ) {
        CGPoint location = [pinch locationOfTouch:i inView:self.view];
        CGPoint convertedLocation = [self.imgView.layer convertPoint:location fromLayer:self.view.layer];
        if ( ! [self.imgView.layer containsPoint:convertedLocation] ) {
            touchesOnPreviewLayer = NO;
            break;
        }
    }
    
    if ( touchesOnPreviewLayer ) {
        self.effectiveScale = self.beginGestureScale * pinch.scale;
        if (self.effectiveScale < 1.0){
            self.effectiveScale = 1.0;
        }
        
        CGFloat maxScale = 10.0;
        if (self.effectiveScale > maxScale){
            self.effectiveScale = maxScale;
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        self.imgView.transform = CGAffineTransformMakeScale(self.effectiveScale, self.effectiveScale);
        [CATransaction commit];
        
    }
}

- (void)panToCutImage:(UIPanGestureRecognizer *)pan
{
    YLCutView * cutView = (YLCutView *)pan.view;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _location = [pan locationInView:cutView];
    }
    CGPoint point = [pan translationInView:cutView];
    [cutView ajustCutRectWithLocation:_location tranlatePoint:point];
    if (pan.state == UIGestureRecognizerStateEnded) {
        cutView.oldBeginPoint = cutView.beginPoint;
        cutView.oldEndPoint = cutView.endPoint;
        cutView.cutSize = CGSizeMake(cutView.endPoint.x - cutView.beginPoint.x, cutView.endPoint.y - cutView.beginPoint.y);
    }

}

- (void)panToAddOrMovePath:(UIPanGestureRecognizer *)pan
{
    if(self.panType == PanType_Cut){
        return;
    }
    
    CGPoint point = [pan locationInView:pan.view];
    
    //滑动开始时先判断是要绘制还是要移动
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.shape.moveObj = [self.shape panOnSelectedObjectWithLocation:point];
    }
    
    if (self.shape.moveObj) {
        //移动
        CGPoint movePoint = [pan translationInView:pan.view];
        [self.shape moveShapeWithPoint:movePoint gesture:pan];
    }else{
        //绘制
        if (pan.state == UIGestureRecognizerStateBegan) {
            self.shapeModel = [[YLDrawModel alloc] init];
            self.shapeModel.type = self.panType;
            self.shapeModel.color = self.drawColor;
            self.shapeModel.width = self.drawWidth;
            self.shapeModel.startPoint = point;
            [self.shape.shapeArr addObject:self.shapeModel];
        }
        self.shapeModel.endPoint = point;        
        [self.shapeModel.pointArr addObject:[NSValue valueWithCGPoint:point]];
        [self.shape setNeedsDisplay];
    }
}

- (void)panToMove:(UIPanGestureRecognizer *)pan
{
    YLTipTextField * field = (YLTipTextField *)pan.view.superview;
    CGPoint movePoint = [pan translationInView:pan.view];
    if (field && field.isSelect) {
        [self.shape moveShapeWithPoint:movePoint gesture:pan];
    }

}

- (void)tapToSelectShapeOrAddText:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:tap.view];
    
    //判断是选择形状还是添加文本
    self.shape.selectObj = [self.shape tapOnObjectWithLocation:point];
    
    //选择形状:刷新改变颜色
    if (self.shape.selectObj == YES) {
        [self.shape setNeedsDisplay];
        [self canDeleteShape];
    }
    
    //添加文本
    if (self.shape.selectObj == NO && self.panType == PanType_Text) {
        if ([_preField.text isEqualToString:@""]) {
            [_preField removeFromSuperview];
        }
        if (_preField.canSelect == NO) {
            [self addSubviewOnFieldWithTextField:_preField];
        }
        if (_preField.isSelect == NO) {
            _preField.layer.borderColor = [UIColor clearColor].CGColor;
        }
        YLTipTextField * field = [[YLTipTextField alloc] initWithFrame:CGRectMake(point.x, point.y, 30, 30)];
        _preField = field;
        field.font = [UIFont systemFontOfSize:self.drawWidth + 8];
        field.textColor = self.drawColor;
        field.borderStyle = UITextBorderStyleNone;
        field.layer.borderWidth = 1;
        field.layer.borderColor = [UIColor redColor].CGColor;
        field.delegate = self;
        [field becomeFirstResponder];
        [field addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
        [self.shape addSubview:field];
        [self.shape.shapeArr addObject:field];
    }
    
}

- (void)tapToSelect:(UITapGestureRecognizer *)tap
{
    YLTipTextField * field = (YLTipTextField *)tap.view.superview;
    field.isSelect = !field.isSelect;
    field.layer.borderWidth = 1;
    if (field.isSelect) {
        field.layer.borderColor = [UIColor blueColor].CGColor;
    }else{
        field.layer.borderColor = [UIColor clearColor].CGColor;
    }
    [self canDeleteShape];
}

- (void)tapToEdit:(UITapGestureRecognizer *)tap
{
    YLTipTextField * field = (YLTipTextField *)tap.view.superview;
    [tap.view removeFromSuperview];
    [field.oldTextArr addObject:field.text];
    [field becomeFirstResponder];
    
}



@end
