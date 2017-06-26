//
//  ColorWidthView.m
//  EditPhoto
//
//  Created by 玉立 on 17/5/31.
//  Copyright © 2017年 YuLi. All rights reserved.
//

#import "YLColorWidthView.h"

#define BASE_W self.baseView.frame.size.width
#define BASE_H self.baseView.frame.size.height

@interface YLColorWidthView ()

@property (nonatomic, retain) NSArray * colorArr;
@property (nonatomic, retain) UIView * baseView;

@end

@implementation YLColorWidthView

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, APP_W, APP_H);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.drawWidth = 2;
        self.drawColor = [UIColor redColor];
        self.colorArr = @[[UIColor redColor], [UIColor orangeColor], [UIColor yellowColor], [UIColor greenColor], [UIColor cyanColor], [UIColor blueColor], [UIColor purpleColor]];
    }
    return self;
}

- (void)showWidthViewWithPosition:(CGPoint)positon
{
    CGFloat bgW = 30;
    CGFloat bgH = 40;
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(positon.x - (20+bgW*5), positon.y + 20, bgW*5, bgH*5)];
    [self addSubview:bgView];
    for (int i = 0; i < 5; i ++) {
        UIView * wViewBig = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        wViewBig.center = CGPointMake(bgView.frame.size.width-(i+1)*bgW+bgW/2, (i*bgH)+bgH/2);
        wViewBig.layer.masksToBounds = YES;
        wViewBig.layer.cornerRadius = wViewBig.frame.size.width/2;
        wViewBig.backgroundColor = [UIColor lightGrayColor];
        [bgView addSubview:wViewBig];
        
        UIView * wViewSmall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (i+1)*6, (i+1)*6)];
        wViewSmall.center = CGPointMake(bgView.frame.size.width-(i+1)*bgW+bgW/2, (i*bgH)+bgH/2);
        wViewSmall.layer.masksToBounds = YES;
        wViewSmall.layer.cornerRadius = wViewSmall.frame.size.width/2;
        wViewSmall.backgroundColor = [UIColor blackColor];
        [bgView addSubview:wViewSmall];
        
        UIButton * wBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        wBtn.tag = i;
        wBtn.frame = CGRectMake(bgView.frame.size.width-(i+1)*bgW, i*bgH, 30, 40);
        wBtn.backgroundColor = [UIColor clearColor];
        [wBtn addTarget:self action:@selector(getWidth:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:wBtn];
    }
}

- (void)showColorViewWithPosition:(CGPoint)positon
{
    CGFloat bgW = 40;
    CGFloat bgH = 40;
    UIView * bgView = [[UIView alloc] initWithFrame:CGRectMake(positon.x - bgW/2, positon.y + 30, bgW, bgH*7)];
    [self addSubview:bgView];
    for (int i = 0; i < 7; i ++) {
        UIView * wView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        wView.center = CGPointMake(bgW/2, (i*bgH)+bgH/2);
        wView.layer.masksToBounds = YES;
        wView.layer.cornerRadius = wView.frame.size.width/2;
        wView.backgroundColor = self.colorArr[i];
        [bgView addSubview:wView];
        
        UIButton * wBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        wBtn.tag = i;
        wBtn.frame = CGRectMake(0, i*bgH, bgW, bgH);
        wBtn.backgroundColor = [UIColor clearColor];
        [wBtn addTarget:self action:@selector(getColor:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:wBtn];
    }
}

- (void)getWidth:(UIButton *)sender
{
    self.drawWidth = (sender.tag + 1) * 2;
    if ([self.delegate respondsToSelector:@selector(colorWidthView:didSelectAWidth:)]) {
        [self.delegate colorWidthView:self didSelectAWidth:self.drawWidth];
    }
    [self removeFromSuperview];
}

- (void)getColor:(UIButton *)sender
{
    self.drawColor = self.colorArr[sender.tag];
    if ([self.delegate respondsToSelector:@selector(colorWidthView:didSelectAColor:)]) {
        [self.delegate colorWidthView:self didSelectAColor:self.drawColor];
    }
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}



@end
