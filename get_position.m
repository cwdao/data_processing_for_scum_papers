function [x_p, y_p] = get_position(time_x, time_y, height_lh, resolution)
    % 定义常量
    lighthouse_freq = 120;  % 120Hz for sync light
    lighthouse_period = 1 / lighthouse_freq;  % 120Hz ~= 0.00833s
    
    % 计算时间
    time_motor_ax = time_x / resolution;  % seconds
    time_motor_ay = time_y / resolution;
    
    % 计算角度（弧度）
    theta_ax = time_motor_ax / lighthouse_period * pi;
    theta_ay = time_motor_ay / lighthouse_period * pi;
    
    % 计算最大边长
    max_side_x = height_lh / sin(theta_ax);
    max_side_y = height_lh / sin(theta_ay);
    
    % 计算相对坐标
    x_p = max_side_x * cos(theta_ax);
    y_p = max_side_y * cos(theta_ay);
end