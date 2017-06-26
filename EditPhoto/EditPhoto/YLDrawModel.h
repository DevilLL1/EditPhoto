//
//  ShapeModel.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/23.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLDrawModel : UIView

@property (nonatomic, assign) PanType type;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, retain) UIColor * color;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, retain) NSMutableArray * pointArr;
@property (nonatomic, retain) NSMutableArray * oldStartPointArr;
@property (nonatomic, retain) NSMutableArray * oldEndPointArr;
@property (nonatomic, retain) NSMutableArray * oldPointArr;

@end
