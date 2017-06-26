//
//  QRView.m
//  QRWeiXinDemo
//
//  Created by lovelydd on 15/4/25.
//  Copyright (c) 2015年 lovelydd. All rights reserved.
//

#import "YLCutView.h"

@interface YLCutView ()

//@property (nonatomic, assign)CGPoint originPont;
@property (nonatomic, assign) CGFloat partW;
@property (nonatomic, assign) CGFloat partH;

@end

@implementation YLCutView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.beginPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(self.frame.size.width, self.frame.size.height);
        self.cutSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    }
    return self;
}

- (void)setCutSize:(CGSize)cutSize
{
    _cutSize = cutSize;
    _partW = cutSize.width / 3;
    _partH = cutSize.height / 3;
    
}

- (void)drawRect:(CGRect)rect {
    
    CGRect drawRect = CGRectMake(self.beginPoint.x, self.beginPoint.y, self.endPoint.x - self.beginPoint.x, self.endPoint.y - self.beginPoint.y);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [self addWhiteRect:ctx rect:drawRect];
    
    [self addCornerLineWithContext:ctx rect:drawRect];
    
}

- (void)addWhiteRect:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGContextStrokeRect(ctx, rect);
    CGContextSetRGBStrokeColor(ctx, 1, 1, 1, 1);
    CGContextSetLineWidth(ctx, 1);
    CGContextAddRect(ctx, rect);
    CGContextStrokePath(ctx);
}

- (void)addCornerLineWithContext:(CGContextRef)ctx rect:(CGRect)rect{
    
    //画四个边角
    CGContextSetLineWidth(ctx, 4);
    CGContextSetRGBStrokeColor(ctx, 83 /255.0, 239/255.0, 111/255.0, 1);//绿色
    
    //左上角
    CGPoint poinsTopLeftA[] = {
        CGPointMake(rect.origin.x+0.7, rect.origin.y),
        CGPointMake(rect.origin.x+0.7 , rect.origin.y + 15)
    };
    
    CGPoint poinsTopLeftB[] = {CGPointMake(rect.origin.x, rect.origin.y +0.7),CGPointMake(rect.origin.x + 15, rect.origin.y+0.7)};
    [self addLine:poinsTopLeftA pointB:poinsTopLeftB ctx:ctx];
    
    //左下角
    CGPoint poinsBottomLeftA[] = {CGPointMake(rect.origin.x+ 0.7, rect.origin.y + rect.size.height - 15),CGPointMake(rect.origin.x +0.7,rect.origin.y + rect.size.height)};
    CGPoint poinsBottomLeftB[] = {CGPointMake(rect.origin.x , rect.origin.y + rect.size.height - 0.7) ,CGPointMake(rect.origin.x+0.7 +15, rect.origin.y + rect.size.height - 0.7)};
    [self addLine:poinsBottomLeftA pointB:poinsBottomLeftB ctx:ctx];
    
    //右上角
    CGPoint poinsTopRightA[] = {CGPointMake(rect.origin.x+ rect.size.width - 15, rect.origin.y+0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y +0.7 )};
    CGPoint poinsTopRightB[] = {CGPointMake(rect.origin.x+ rect.size.width-0.7, rect.origin.y),CGPointMake(rect.origin.x + rect.size.width-0.7,rect.origin.y + 15 +0.7 )};
    [self addLine:poinsTopRightA pointB:poinsTopRightB ctx:ctx];
    
    //右下角
    CGPoint poinsBottomRightA[] = {CGPointMake(rect.origin.x+ rect.size.width -0.7 , rect.origin.y+rect.size.height+ -15),CGPointMake(rect.origin.x-0.7 + rect.size.width,rect.origin.y +rect.size.height )};
    CGPoint poinsBottomRightB[] = {CGPointMake(rect.origin.x+ rect.size.width - 15 , rect.origin.y + rect.size.height-0.7),CGPointMake(rect.origin.x + rect.size.width,rect.origin.y + rect.size.height - 0.7 )};
    [self addLine:poinsBottomRightA pointB:poinsBottomRightB ctx:ctx];
    CGContextStrokePath(ctx);
}

- (void)addLine:(CGPoint[])pointA pointB:(CGPoint[])pointB ctx:(CGContextRef)ctx {
    CGContextAddLines(ctx, pointA, 2);
    CGContextAddLines(ctx, pointB, 2);
}

- (void)ajustCutRectWithLocation:(CGPoint)location tranlatePoint:(CGPoint)point
{
    CGPoint newBeginPoint = self.oldBeginPoint;
    CGPoint newEngPoint = self.oldEndPoint;
    
    if (location.x < self.oldBeginPoint.x + self.partW && location.y < self.oldBeginPoint.y + self.partH) {
        //从左上角开始滑动
        newBeginPoint = CGPointMake(self.oldBeginPoint.x + point.x, self.oldBeginPoint.y + point.y);
        if (newBeginPoint.x < 0) {
            newBeginPoint.x = 0;
        }
        if (newBeginPoint.y < 0) {
            newBeginPoint.y = 0;
        }
        
    }else if (location.x < self.oldBeginPoint.x + self.partW && location.y < self.oldBeginPoint.y + 2*self.partH) {
        //左中
        newBeginPoint.x = self.oldBeginPoint.x + point.x;
        if (newBeginPoint.x < 0) {
            newBeginPoint.x = 0;
        }
        
    }else if (location.x < self.oldBeginPoint.x + self.partW && location.y < self.oldBeginPoint.y + 3*self.partH) {
        //左下
        newBeginPoint.x = self.oldBeginPoint.x + point.x;
        newEngPoint.y = self.oldEndPoint.y + point.y;
        if (newBeginPoint.x < 0) {
            newBeginPoint.x = 0;
        }
        if (newEngPoint.y > self.self.frame.size.height) {
            newEngPoint.y = self.self.frame.size.height;
        }
        
    }else if (location.x < self.oldBeginPoint.x + 2*self.partW && location.y < self.oldBeginPoint.y + self.partH) {
        //中上
        newBeginPoint.y = self.oldBeginPoint.y + point.y;
        if (newBeginPoint.y < 0) {
            newBeginPoint.y = 0;
        }
        
    }else if (location.x < self.oldBeginPoint.x + 2*self.partW && location.y < self.oldBeginPoint.y + 2*self.partH) {
        //中中（移动）
        if (self.cutSize.width < self.self.frame.size.width || self.cutSize.height < self.self.frame.size.height) {
            newBeginPoint = CGPointMake(self.oldBeginPoint.x + point.x, self.oldBeginPoint.y + point.y);
            newEngPoint = CGPointMake(self.oldEndPoint.x + point.x, self.oldEndPoint.y + point.y);
            if (newBeginPoint.x < 0) {
                newBeginPoint.x = 0;
                newEngPoint.x = self.cutSize.width;
            }
            if (newBeginPoint.y < 0) {
                newBeginPoint.y = 0;
                newEngPoint.y = self.cutSize.height;
            }
            if (newEngPoint.x > self.self.frame.size.width) {
                newEngPoint.x = self.self.frame.size.width;
                newBeginPoint.x = newEngPoint.x - self.cutSize.width;
            }
            if (newEngPoint.y > self.self.frame.size.height) {
                newEngPoint.y = self.self.frame.size.height;
                newBeginPoint.y = newEngPoint.y - self.cutSize.height;
            }
        }
        
    }else if (location.x < self.oldBeginPoint.x + 2*self.partW && location.y < self.oldBeginPoint.y + 3*self.partH) {
        //中下
        newEngPoint.y = self.oldEndPoint.y + point.y;
        if (newEngPoint.y > self.self.frame.size.height) {
            newEngPoint.y = self.self.frame.size.height;
        }
        
    }else if (location.x < self.oldBeginPoint.x + 3*self.partW && location.y < self.oldBeginPoint.y + self.partH) {
        //右上
        newBeginPoint.y = self.oldBeginPoint.y + point.y;
        newEngPoint.x = self.oldEndPoint.x + point.x;
        if (newBeginPoint.y < 0) {
            newBeginPoint.y = 0;
        }
        if (newEngPoint.x > self.self.frame.size.width) {
            newEngPoint.x = self.self.frame.size.width;
        }
        
    }else if (location.x < self.oldBeginPoint.x + 3*self.partW && location.y < self.oldBeginPoint.y + 2*self.partH) {
        //右中
        newEngPoint.x = self.oldEndPoint.x + point.x;
        if (newEngPoint.x > self.self.frame.size.width) {
            newEngPoint.x = self.self.frame.size.width;
        }
        
    }else if (location.x < self.oldBeginPoint.x + 3*self.partW && location.y < self.oldBeginPoint.y + 3*self.partH) {
        //右下
        newEngPoint = CGPointMake(self.oldEndPoint.x + point.x, self.oldEndPoint.y + point.y);
        if (newEngPoint.x > self.self.frame.size.width) {
            newEngPoint.x = self.self.frame.size.width;
        }
        if (newEngPoint.y > self.self.frame.size.height) {
            newEngPoint.y = self.self.frame.size.height;
        }
    }
    self.beginPoint = newBeginPoint;
    self.endPoint = newEngPoint;
    [self setNeedsDisplay];
    
}


@end
