Y = 3;
X = 4;
n = 1;
Oring_image = imread('D:\桌面\校正亮度不均匀问题并分析前景对象\image\image1.jpg');
subplot(Y, X, n);
imshow(Oring_image);
title('Oringimage');
%图像预处理 
Gray_image = rgb2gray(Oring_image);
n = n+1;
subplot(Y, X, n);
imshow(Gray_image);
title('Grayimage');
Bin_image = imbinarize(Gray_image);
n = n+1;
subplot(Y, X, n);
imshow(Bin_image);
title('Binimage');
%开运算 运算半径15  先腐蚀 再膨胀
%第一步，使用形态学开运算删除所有前景（米粒）。
%开运算会删除无法完全包含结构元素的小对象。定义半径为 15 的盘形结构元素，
%它完全可放入一粒米内   实际为顶帽操作
SE = strel('disk',15);
background = imopen(Gray_image,SE);
n = n+1;
subplot(Y, X, n);
imshow(background);
title('background');
fore_image = Gray_image - background;
n = n+1;
subplot(Y, X, n);
imshow(fore_image);
title('foreimage');
%使用 imadjust，通过在低强度和高强度下都对 1% 的数据进行饱和处理，
%并通过拉伸强度值以填充 uint8 动态范围，来提高处理后的图像 foreimage 的对比度。
fore_image_enhance = imadjust(fore_image);
n = n+1;
subplot(Y, X, n);
imshow(fore_image_enhance);
title('foreimageenhance');
%对前景拉伸图像二值化 OTSU方法全局阈值
bin_fore_image_enhance = imbinarize(fore_image_enhance);
%滤波 去除小面积
bin_fore_image_enhance = bwareaopen(bin_fore_image_enhance,50);
n = n+1;
subplot(Y, X, n);
imshow(bin_fore_image_enhance);
title('binforeimageenhance');
%标记所有米粒
find_roi_obj = bwconncomp(bin_fore_image_enhance,4);
%{
 find_roi_obj = struct with fields:
                Connectivity: 4 
                ImageSize: [285 286]
                NumObjects: 99
                PixelIdxList: {1x99 cell}
 %}
%创建一个逻辑数组 存储某个米粒图像
disp(['总米粒数:',num2str(find_roi_obj.NumObjects)]);
certain_image = false(size(bin_fore_image_enhance));
certain_image(find_roi_obj.PixelIdxList{27}) = true;
n = n+1;
subplot(Y, X, n);
imshow(certain_image);
title('certainimage');
%打标签分组
labeled = labelmatrix(find_roi_obj);
%{
labeled  struct：
  Name           Size             Bytes  Class    Attributes
  labeled      285x286            81510  uint8  
%}
RGB_label = label2rgb(labeled,'autumn','g','shuffle');
n = n+1;
subplot(Y, X, n);
imshow(RGB_label);
title('RGBlabel');
%计算基于面积的统计量
roi_obj_data = regionprops(find_roi_obj,'basic');
%{
  roi_obj_data struct:
             Area
            Centroid
            BoundingBox 
%}
roi_obj_areas = [roi_obj_data.Area];
disp(['第50个米粒大小:',num2str(roi_obj_areas(50))]);
[min_area, idx] = min(roi_obj_areas);
disp(['最小米粒位置:',num2str(idx)]);
disp(['最小米粒大小:',num2str(roi_obj_areas(idx))]);
%显示最小米粒
show_min_rice = false(size(bin_fore_image_enhance));
show_min_rice(find_roi_obj.PixelIdxList{idx}) = true;
n = n+1;
subplot(Y, X, n);
imshow(show_min_rice);
title('showminrice');
n = n+1;
subplot(Y, X, n);
histogram(roi_obj_areas)
title('米粒面积直方图')
