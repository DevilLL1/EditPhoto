//
//  TipTextField.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/24.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLTipTextField : UITextField

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL canSelect;
@property (nonatomic, retain) NSMutableArray * oldFrameArr;
@property (nonatomic, retain) NSMutableArray * oldTextArr;

@end
