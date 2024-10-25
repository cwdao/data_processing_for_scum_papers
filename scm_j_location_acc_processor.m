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