//
//  ShapeModel.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/23.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "YLDrawModel.h"

@implementation YLDrawModel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startPoint = CGPointMake(0, 0);
        self.endPoint = CGPointMake(0, 0);
        self.pointArr = [[NSMutableArray alloc] init];
        self.oldStartPointArr = [[NSMutableArray alloc] init];
        self.oldEndPointArr = [[NSMutableArray alloc] init];
        self.oldPointArr = [[NSMutableArray alloc] init];
        self.selected = NO;
        self.type = PanType_Arrow;
        self.color = [UIColor redColor];
        self.width = 2;
    }
    return self;
}



@end
