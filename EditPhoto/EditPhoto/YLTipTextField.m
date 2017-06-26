//
//  TipTextField.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/24.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "YLTipTextField.h"

@implementation YLTipTextField

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.isSelect = NO;
        self.canSelect = NO;
        self.oldFrameArr = [[NSMutableArray alloc] init];
        self.oldTextArr = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
