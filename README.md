难点

1：图片的裁剪和合并。

a)	裁剪。

使用trasform变换矩阵旋转坐标再获取裁剪区域图片。

b)	合并。

将路径绘制到图片上才能有效合并。

2：形状的选中。

本demo采用点对比的方法判断形状是否被选中，每次选择都要遍历所有形状的所有点，与单击的位置点比较，位置相近，则可选中。（感觉是比较笨的方法，读者若有更好的办法，欢迎留言反馈！）

3：撤销与删除。

a)	撤销--如何做到修改颜色等操作的回退。

将历史操作数据保存到历史数组，撤销时从历史数组的最后一个状态往前回退即可。

b)	删除--如何解决遍历时修改数组崩溃问题。

采用普通遍历

参考：http://www.jianshu.com/p/500c6f9f38d1

4：图片的压缩（参考微信压缩比例）。

使用

1：将YLEditPhoto拖入工程（resource里的图片可自行修改）。

2：导入YLEditViewController.h。

#import "YLEditViewController.h"
3：初始化并弹出YLEditViewController。

YLEditViewController * editVC = [[YLEditViewController alloc] init];
editVC.delegate = self;
editVC.image = image;
[self presentViewController:editVC animated:YES completion:nil];
4：实现代理。

#pragma mark - YLEditViewControllerDelegate
- (void)editViewController:(YLEditViewController *)cameraVC disClickToSaveImage:(UIImage *)image
{
    self.imgView.image = image;
}
文件结构

1：YLEditViewController。

主控制器，管理所有裁剪和绘制逻辑。

2：YLCutView。

管理裁剪框。

3：YLDrawView。

管理箭头、矩形、画笔的绘制。

4：YLDrawModel。

存储箭头、矩形、画笔对象数据。

5：YLTipTextField。

存储文本绘制数据。

6：YLColorWidthView

管理绘制线宽和颜色。