//
//  ShapeView.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/22.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YLDrawModel.h"

@interface YLDrawView : UIView

@property (nonatomic, assign) BOOL moveObj;
@property (nonatomic, assign) BOOL selectObj;
@property (nonatomic, retain) NSMutableArray * shapeArr;

- (BOOL)tapOnObjectWithLocation:(CGPoint)point;
- (BOOL)panOnSelectedObjectWithLocation:(CGPoint)point;
- (void)moveShapeWithPoint:(CGPoint)movePoint gesture:(UIPanGestureRecognizer *)pan;

@end
