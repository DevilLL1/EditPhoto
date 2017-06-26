//
//  ShapeView.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/22.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "YLDrawView.h"
#import "YLTipTextField.h"

@implementation YLDrawView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.shapeArr = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    for (int i = 0; i < self.shapeArr.count; i ++) {
        UIView * view = self.shapeArr[i];
        if ([view isKindOfClass:[YLTipTextField class]]) {
            continue;
        }
        YLDrawModel * model = (YLDrawModel *)view;
        if (model.type == PanType_Rect) {
            [self addRectWithModel:model];
        }else if (model.type == PanType_Path){
            [self addPathWithModel:model];
        }else if (model.type == PanType_Arrow){
            [self addArrowWithModel:model];
        }
    }
}

- (void)addRectWithModel:(YLDrawModel *)model
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat width = model.endPoint.x - model.startPoint.x;
    CGFloat height = model.endPoint.y - model.startPoint.y;
    CGRect drawRect = CGRectMake(model.startPoint.x, model.startPoint.y, width, height);
    CGContextStrokeRect(ctx, drawRect);
    CGContextAddRect(ctx, drawRect);
    CGContextSetLineWidth(ctx, model.width);
    CGContextSetStrokeColorWithColor(ctx, model.color.CGColor);
    if (model.selected) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    }
    CGContextStrokePath(ctx);
}

- (void)addPathWithModel:(YLDrawModel *)model
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (int i = 0; i < model.pointArr.count; i ++) {
        NSValue * value = model.pointArr[i];
        CGPoint point = [value CGPointValue];
        if (i == 0) {
             CGContextMoveToPoint(ctx, point.x, point.y);
        }else{
             CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }
    CGContextSetLineWidth(ctx, model.width);
    CGContextSetStrokeColorWithColor(ctx, model.color.CGColor);
    if (model.selected) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    }
    CGContextStrokePath(ctx);
}

- (void)addArrowWithModel:(YLDrawModel *)model
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //添加直线
    CGContextMoveToPoint(ctx, model.startPoint.x, model.startPoint.y);
    CGContextAddLineToPoint(ctx, model.endPoint.x, model.endPoint.y);
    CGContextSetLineWidth(ctx, model.width);
    CGContextSetStrokeColorWithColor(ctx, model.color.CGColor);
    if (model.selected) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor blueColor].CGColor);
    }
    CGContextStrokePath(ctx);//绘制路径
    
    //添加箭头
    double r = sqrt((model.endPoint.x-model.startPoint.x)*(model.endPoint.x-model.startPoint.x)+(model.startPoint.y-model.endPoint.y)*(model.startPoint.y-model.endPoint.y));//直线长度
    CGContextMoveToPoint(ctx,model.endPoint.x,model.endPoint.y);
    CGContextAddLineToPoint(ctx,model.endPoint.x-(5*(model.startPoint.y-model.endPoint.y)/r),model.endPoint.y-(5*(model.endPoint.x-model.startPoint.x)/r));
    CGContextAddLineToPoint(ctx,model.endPoint.x+(10*(model.endPoint.x-model.startPoint.x)/r), model.endPoint.y-(10*(model.startPoint.y-model.endPoint.y)/r));
    CGContextAddLineToPoint(ctx,model.endPoint.x+(5*(model.startPoint.y-model.endPoint.y)/r),model.endPoint.y+(5*(model.endPoint.x-model.startPoint.x)/r));
    CGContextAddLineToPoint(ctx, model.endPoint.x,model.endPoint.y);
    CGContextSetLineWidth(ctx, model.width);
    CGContextSetFillColorWithColor(ctx, model.color.CGColor);
    if (model.selected) {
        CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
    }
    if (model.width < 6) {
        CGContextFillPath(ctx);//填充路径
    }else{
        CGContextStrokePath(ctx);
    }
}

//PanType为AddText时，单击在形状上，则为选择，反之为添加文本
- (BOOL)tapOnObjectWithLocation:(CGPoint)point
{
    BOOL selectShape = NO;
    for (UIView * view in self.shapeArr) {
        if ([view isKindOfClass:[YLTipTextField class]]) {
            continue;
        }
        YLDrawModel * model = (YLDrawModel *)view;
        for (int i = 0; i < model.pointArr.count; i ++) {
            NSValue * value = model.pointArr[i];
            CGPoint pt = [value CGPointValue];
            if (fabs(point.x-pt.x) < 8  && fabs(point.y-pt.y) < 8) {
                selectShape = YES;
                model.selected = !model.selected;
                break;
            }
        }
    }
    return selectShape;

}

//滑动的起点在被选中的形状上，则为移动，反之为绘制
- (BOOL)panOnSelectedObjectWithLocation:(CGPoint)point
{
    for (UIView * view in self.shapeArr) {
        if ([view isKindOfClass:[YLTipTextField class]]) {
            continue;
        }
        YLDrawModel * model = (YLDrawModel *)view;
        if (model.selected == NO) {
            continue;
        }
        for (int i = 0; i < model.pointArr.count; i ++) {
            NSValue * value = model.pointArr[i];
            CGPoint pt = [value CGPointValue];
            if (fabs(point.x-pt.x) < 10  && fabs(point.y-pt.y) < 10) {
                return YES;
                break;
            }
        }
    }
    return NO;
}

- (void)moveShapeWithPoint:(CGPoint)movePoint gesture:(UIPanGestureRecognizer *)pan
{
    for (UIView * view in self.shapeArr) {
        if ([view isKindOfClass:[YLTipTextField class]]) {
            //移动文本
            YLTipTextField * moveField = (YLTipTextField *)view;
            if (pan.state == UIGestureRecognizerStateBegan) {
                //记录历史位置，用于撤销操作
                [moveField.oldFrameArr addObject:[NSValue valueWithCGRect:moveField.frame]];
            }
            if (!moveField.isSelect) {
                continue;
            }
            CGRect newFrame = CGRectMake(moveField.frame.origin.x + movePoint.x, moveField.frame.origin.y + movePoint.y, moveField.frame.size.width, moveField.frame.size.height);
            moveField.frame = newFrame;
            [pan setTranslation:CGPointZero inView:pan.view];
            
        }else if([view isKindOfClass:[YLDrawModel class]]){
            //移动其他，重置起始点的同时需重置点数组，否则画笔路径移动不正常
            YLDrawModel * model = (YLDrawModel *)view;
            if (pan.state == UIGestureRecognizerStateBegan) {
                //记录历史位置，用于撤销操作
                [model.oldStartPointArr addObject:[NSValue valueWithCGPoint:model.startPoint]];
                [model.oldEndPointArr addObject:[NSValue valueWithCGPoint:model.endPoint]];
                NSMutableArray * arr = [NSMutableArray arrayWithArray:model.pointArr];
                [model.oldPointArr addObject:arr];
            }
            if (!model.selected) {
                continue;
            }
            model.startPoint = CGPointMake(model.startPoint.x + movePoint.x, model.startPoint.y + movePoint.y);
            model.endPoint = CGPointMake(model.endPoint.x + movePoint.x, model.endPoint.y + movePoint.y);
            [pan setTranslation:CGPointZero inView:pan.view];
            for (int i = 0; i < model.pointArr.count; i ++) {
                CGPoint oldPoint = [model.pointArr[i] CGPointValue];
                CGPoint newPt = CGPointMake(oldPoint.x + movePoint.x, oldPoint.y + movePoint.y);
                model.pointArr[i] = [NSValue valueWithCGPoint:newPt];
                [pan setTranslation:CGPointZero inView:pan.view];
            }
            [self setNeedsDisplay];
        }
    }
}

@end
