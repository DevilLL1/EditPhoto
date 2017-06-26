//
//  ColorWidthView.h
//  EditPhoto
//
//  Created by 玉立 on 17/5/31.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YLColorWidthView : UIView

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger drawWidth;
@property (nonatomic, retain) UIColor * drawColor;
//@property (nonatomic, assign) PanType type;

- (void)showWidthViewWithPosition:(CGPoint)positon;
- (void)showColorViewWithPosition:(CGPoint)positon;

@end

@protocol YLColorWidthViewDelegate <NSObject>

- (void)colorWidthView:(YLColorWidthView *)view didSelectAWidth:(NSInteger)width;

- (void)colorWidthView:(YLColorWidthView *)view didSelectAColor:(UIColor *)color;

@end
