//
//  QRView.h
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSTimeInterval kQrLineanimateDuration = 0.02;

@interface YLCutView : UIView

@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGPoint oldBeginPoint;
@property (nonatomic, assign) CGPoint oldEndPoint;
@property (nonatomic, assign) CGSize cutSize;

- (void)ajustCutRectWithLocation:(CGPoint)_location tranlatePoint:(CGPoint)point;

@end
