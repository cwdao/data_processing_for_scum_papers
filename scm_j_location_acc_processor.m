% 加载数据
clc;
clear;

load("data_2024-10-26_16-28_p2point.mat");
%%
% 取点数据
ax = data(:,1);
ay = data(:,2);
point_label = data(:,5);
% 提取前两个校正点，首先给了标签9和8，分别是左上和右下的点
calib_left= [];
i = 1;
j = 1;
k = 1;
% 循环条件希望在看到第一个1标签之后就停下来，以免重复，后面的8，9不是校正点
while (point_label(i,1) ~=1)
    if (point_label(i,1)  == 9)
        calib_left(j,1) = ax(i,1);
        calib_left(j,2) = ay(i,1);
        j = j +1;
    end
    if (point_label(i,1)  == 8)
        calib_right(k,1) = ax(i,1);
        calib_right(k,2) = ay(i,1);
        k = k+1;
    end
    i = i+1;
end

point_calib_l = mean(calib_left);
point_calib_r = mean(calib_right);


%% 更换代码

% 理想点
ideal_points = [50, 350; 150, 250; 250, 150; 350, 50];

% 模拟多个实际点
rng(0); % 固定随机数种子
actual_points = cell(4, 1);
for i = 1:4
    actual_points{i} = ideal_points(i, :) + randn(10, 2) * 10;
end

% 创建图形
figure;
hold on;
colors = lines(4);

for i = 1:4
    % 绘制误差椭圆
    mean_point = mean(actual_points{i});
    cov_matrix = cov(actual_points{i});
    plot_error_ellipse(cov_matrix, mean_point);
    
    % 绘制实际点
    scatter(actual_points{i}(:, 1), actual_points{i}(:, 2), 36, 'r', 'filled', 'MarkerFaceAlpha', 0.6);
    
    % 绘制实际点均值
    scatter(mean_point(1), mean_point(2), 100, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(i, :));
    
    % 绘制理想点
    scatter(ideal_points(i, 1), ideal_points(i, 2), 100, 'o', 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
end

% 标签和图例
xlabel('X轴');
ylabel('Y轴');
title('运动轨迹图');
legend({'误差椭圆', '实际点', '实际点均值', '理想点'}, 'Location', 'best');
grid on;
axis equal;
hold off;

% 误差椭圆辅助函数
function plot_error_ellipse(C, mu)
    % C: 协方差矩阵
    % mu: 均值
    [V, D] = eig(C);
    t = linspace(0, 2*pi, 100);
    a = (V * sqrt(D)) * [cos(t(:))'; sin(t(:))'];
    plot(a(1, :) + mu(1), a(2, :) + mu(2), 'r--', 'LineWidth', 1);
end

function calculate_position()
# 计算实际位置需要的参数
lighthouse_height = 550  # 单位mm
lighthouse_freq = 120  # 120Hz for sync light
lighthouse_period = 1 / lighthouse_freq  # 120Hz~=0.00833s
lighthouse_angular_velocity = 2 * math.pi * lighthouse_freq
resolution = 10000000  # @10M,1s= 10,000,000 ticks


# 当前版本的角度计算方法是一种更易理解的形式，即时间/周期*pi。
# 获得角度后，根据简单的三角函数方法就能计算得到相应的X，Y相对坐标。
def get_position(time_x, time_y, height_lh, resolution):

    time_motor_ax = time_x / resolution  # seconds
    time_motor_ay = time_y / resolution
    theta_ax = time_motor_ax / lighthouse_period * math.pi  # now in radians
    theta_ay = time_motor_ay / lighthouse_period * math.pi
    max_side_x = height_lh / math.sin(theta_ax)
    max_side_y = height_lh / math.sin(theta_ay)
    x_p = max_side_x * math.cos(theta_ax)
    y_p = max_side_y * math.cos(theta_ay)
    return x_p, y_p
end