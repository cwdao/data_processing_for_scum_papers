% 加载数据
clc;
clear;

load("data_2024-10-26_16-28_p2point.mat");
% # 单位mm
lighthouse_height = 550;
% # 120Hz for sync light
lighthouse_freq = 120; 
% # 120Hz~=0.00833s
lighthouse_period = 1 / lighthouse_freq; 
lighthouse_angular_velocity = 2 * pi * lighthouse_freq;
% # @10M,1s= 10,000,000 ticks
resolution = 10000000; 
%% 标签定义
% 采集代码中只有0-9共10个标签，第一个点是右下校正点，标签9，第二个点是左上校正点，标签8，然后从1-9-1如此往复
% 取点数据
ax = data(:,1);
ay = data(:,2);
point_label = data(:,5);
% 先直接给位置
j = 1;
for i=1:length(point_label)
    [point_xy(j,1),point_xy(j,2)] = get_position(ax(i,1),ay(i,1),lighthouse_height,resolution);
    j = j+1;
end
% 提取前两个校正点，首先给了标签9和8，分别是左上和右下的点
calib_left= [];
i = 1;
j = 1;
k = 1;
% 循环条件希望在看到第一个1标签之后就停下来，以免重复，后面的8，9不是校正点
while (point_label(i,1) ~=1)
    if (point_label(i,1)  == 9)
        calib_right(j,1) = point_xy(i,1);
        calib_right(j,2) = point_xy(i,2);
        j = j +1;
    end
    if (point_label(i,1)  == 8)
        calib_left(k,1) = point_xy(i,1);
        calib_left(k,2) = point_xy(i,2);
        k = k+1;
    end
    i = i+1;
end


% 尝试去除异常值

% 查找并去除异常值
outliers_rx = isoutlier(calib_right(:,1));
outliers_ry = isoutlier(calib_right(:,2));
outliers_lx = isoutlier(calib_left(:,1));
outliers_ly = isoutlier(calib_left(:,2));

% 仅保留非异常值
filtered_data_rp = calib_right(~outliers_rx & ~outliers_ry, :);
filtered_data_lp = calib_left(~outliers_lx & ~outliers_ly, :);

% 计算过滤后数据的均值
mean_values_rp = mean(filtered_data_rp);
mean_values_lp = mean(filtered_data_lp);

% 打印结果
fprintf('Filtered Mean rX: %.4f\n', mean_values_rp(1));
fprintf('Filtered Mean rY: %.4f\n', mean_values_rp(2));
fprintf('Filtered Mean lX: %.4f\n', mean_values_lp(1));
fprintf('Filtered Mean lY: %.4f\n', mean_values_lp(2));
% 回到原接口
point_calib_l = mean_values_lp;
point_calib_r = mean_values_rp;

%% 计算坐标变换参数，设置新的原点和实际坐标系
% 原始坐标
x1 = point_calib_l(1,1); y1 = point_calib_l(1,2);
x2 = point_calib_r(1,1); y2 = point_calib_r(1,2);

% 目标坐标
x1_prime = 100; y1_prime = 150;
x2_prime = 250; y2_prime = 100;

% 计算缩放因子
s_x = (x2_prime - x1_prime) / (x2 - x1);
s_y = (y2_prime - y1_prime) / (y2 - y1);

% 计算偏移量
t_x = x1_prime - s_x * x1;
t_y = y1_prime - s_y * y1;

% 转换函数
% transform_point = @(x, y) deal(s_x * x + t_x, s_y * y + t_y);
point_calibed_xy(:,1) = point_xy(:,1)*s_x+t_x;
point_calibed_xy(:,2) = point_xy(:,2)*s_y+t_y;
%% 删除非静态点数据
i = 1;
j = 1;
for i=1:length(point_label)
    if (point_label(i,1)~=0)
        point_stable(j,1) = point_calibed_xy(i,1);
        point_stable(j,2) = point_calibed_xy(i,2);
        j = j+1;
    end
end
% scatter(point_calibed_xy(:,1),point_calibed_xy(:,2),point_stable(:,1),point_stable(:,2))
% 创建图形窗口
figure;

% 绘制第一个数组
scatter(point_calibed_xy(:,1), point_calibed_xy(:,2), 'filled', 'MarkerFaceColor', [0.1, 0.5, 0.9], 'MarkerEdgeColor', 'none');
hold on; % 保持当前图形

% 绘制第二个数组
scatter(point_stable(:,1), point_stable(:,2), 'filled', 'MarkerFaceColor', [0.9, 0.3, 0.1], 'MarkerEdgeColor', 'none');

% 添加图例
legend('moving', 'stable');
axis equal
% 添加标题和标签
title('Scatter Plot of Two Arrays');
xlabel('X-axis (mm)');
ylabel('Y-axis (mm)');
%% 更换代码


