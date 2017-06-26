//
//  TypeMacro.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/22.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <CoreGraphics/CGBase.h>

typedef NS_ENUM(NSInteger, PanType) {
    PanType_Rect = 1,
    PanType_Path,
    PanType_Arrow,
    PanType_Text,
    PanType_Cut
};

