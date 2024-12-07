% load data
clc;
clear;
% raw_data = readtable("digital.csv");
% the demo paper data
% raw_data = readtable("digital_synccheck.csv");
% the journal paper data

% https://hkustgz-my.sharepoint.com/:x:/g/personal/cwang199_connect_hkust-gz_edu_cn/EQVVZgqEBYRImXM12cCwJ2YBOYxfVcBiJayqquoesH6F6g?e=QqKJKs
raw_data = readtable("new_counter_read_acc_check_5min.csv");
%% 加载变量
% 时间戳
timeframe = raw_data.Time_s_;
% 原始同步光信号
signaldata_optical = raw_data.dataRawIo3;
% signaldata_sync_cal = raw_data.Channel6;
% while循环读取到的信号
signaldata_sync_read = raw_data.IO10;

% data_p1 = timetable(timeline,signalline);

%%小小测一下数据，看看单位
% plot(timeframe,signaldata);
t1 = timeframe(8,1)- timeframe(7,1)
t11 = t1*10.0000^6
% the answer is 6.35e-5,if *10^6,it will be us.I think it is enough to
% caculate the duration
%% test
% threshold = 3e-5;
%     % 计算信号的差分，检测上升沿和下降沿
%     signal_diff = diff(signaldata_optical);
%
%     % 找到上升沿和下降沿的索引
%     rising_edges = find(signal_diff == 1);   % 上升沿（从 0 到 1）
%     falling_edges = find(signal_diff == -1); % 下降沿（从 1 到 0）
%
%     % 确保每个上升沿都有对应的下降沿（避免未闭合的高电平）
%     num_edges = min(length(rising_edges), length(falling_edges));
%     rising_edges = rising_edges(1:num_edges);
%     falling_edges = falling_edges(1:num_edges);
%
%     % 计算高电平持续时间
%     high_durations = timeframe(falling_edges) - timeframe(rising_edges);
%
%     % 筛选高电平持续时间大于阈值的记录
%     valid_indices = find(high_durations > threshold);
%
%     % 输出结果矩阵：每行是 [高电平持续时间, 起始时间]
%     duration = [high_durations(valid_indices), timeframe(rising_edges(valid_indices))];
%% 计算光的持续时间
% TS4231的Epin以低电平表示根据存储的格式，0表示信号现在开始为0，1表示开始为1.因此只需计算所有0和其紧跟 的1的时间间隔，就能得到所有波的时间。再删除所有小于30us(3e-5
% s)，就得到所有同步 光的时间。
% scum 则更直观，高电平表示有光，即1表示开始，0表示结束。目前这个文档解析的是scum数据


% 设置时间间隔阈值，区分扫描和同步光
threshold = 3e-5;  % 30us

% 计算 optical 信号的时间间隔
duration_optical = calculate_high_level_duration(signaldata_optical, timeframe, threshold);

% 计算 sync_read 信号的时间间隔
% 现在想看看读完counter再翻转IO后得到的波形，可以认为是实际读出来的时间
duration_sync_read = calculate_high_level_duration(signaldata_sync_read, timeframe, threshold);

%% 计算每个synclight cal的周期

% % 对于synclight calibration 的间隔，代码中每次检测时都会翻转这个IO，因此要找到翻转的边缘。
% k =1;
% current_state = 0;
% last_state = 0;
% for ki = 1:length(signaldata_sync_cal)
%     last_state = current_state;
%     current_state= signaldata_sync_cal(ki,1);
%     if (current_state ~= last_state)&&(ki ~= length(signaldata_sync_cal))
%         sync_timestamp(k,1) = timeframe(ki,1);
%         k = k+1;
%     end
% end
% % 记录了每个变化时刻后，下一步就是计算间隔长度
% kp = 1;
% for kpi = 1:(length(sync_timestamp(:,1))-1)
%     period_sync_cal(kp,1) = sync_timestamp(kpi+1,1)-sync_timestamp(kpi,1);
%     kp = kp+1;
% end


%% 计算两波的间隔

% 设置时间间隔阈值和范围
threshold = 0.01;  % 时间间隔小于 0.01 秒筛选
range = [0.008323, 0.008343];  % 计数范围
% optical_data_raw的
[period_optical, c_good_optical] = calculate_period_vectorized(duration_optical, threshold, range);
% while读出来的
[period_sync_read, c_good_sync_read] = calculate_period_vectorized(duration_sync_read, threshold, range);
%% 计算各ppm值
% +-10us
performance = 14147/29537
% +-5us(8.328-8.338ms)
mean_period = mean(period_optical);
theoretical_period = 1/120;
range = [0.008328, 0.008338];  % 计数范围
c_opt_5us = count_within_range(period_optical, range);  % 可直接统计符合范围的值
c_read_5us = count_within_range(period_sync_read, range);  % 可直接统计符合范围的值
performance_opt_5us = c_opt_5us/length(period_optical);
performance_read_5us = c_read_5us/length(period_sync_read);
% 计算 40ppm的范围,+3.33e-7s, 也就是0.33 us
range = [theoretical_period-3.33e-7, theoretical_period+3.33e-7];  % 计数范围
c_opt_40ppm = count_within_range(period_optical, range);  % 可直接统计符合范围的值
c_read_40ppm = count_within_range(period_sync_read, range);  % 可直接统计符合范围的值
performance_opt_40ppm = c_opt_40ppm/length(period_optical);
performance_read_40ppm = c_read_40ppm/length(period_sync_read);

%% plot figure 原始周期图
% figure(1)
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','off','YMinorGrid','off','box','off');
figure(101)
% subplot(1,2,1)
ylabel('Counts');
xlabel('Sync light periods read by SCUM optical receiver (ms)');
hold on
% 放大坐标到ms
period_show = period_optical * 1000;
h101 = histogram(period_show);
h101.EdgeColor = "black";
h101.FaceColor = "#e89776";
h101.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% 由IO读取的原始周期
figure(102)
% subplot(1,2,2)
ylabel('Counts');
xlabel('Sync light periods read by SCUM IO (ms)');
hold on
% 放大坐标到ms
period_show_read = period_sync_read * 1000;
h102 = histogram(period_show_read);
h102.EdgeColor = "black";
h102.FaceColor = "#e89776";
h102.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');
%%  累计误差会如何？
cumu_timewin = 12;
cumu_timestep = 1;
% 首先是optical receiver的累计误差
j = 1;
for i = 1:cumu_timestep:length(period_optical)-cumu_timewin
    cumu_t1(j) = mean(period_optical(i:i+cumu_timewin));
    j = j + 1;
end

figure(201)
ylabel('Counts');
xlabel('Average of 12 sync light periods read by SCUM optical receiver (ms)');
hold on
% 放大坐标到ms
cumu_t1_show = cumu_t1 * 1000;
h201 = histogram(cumu_t1_show);
h201.EdgeColor = "black";
h201.FaceColor = "#e89776";
h201.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% 计算 40ppm的范围,+3.33e-7s, 也就是0.33 us
range = [theoretical_period-3.33e-7, theoretical_period+3.33e-7];  % 计数范围
cu_opt_40ppm = count_within_range(cumu_t1, range);  % 可直接统计符合范围的值
performance_cu_opt_40ppm = cu_opt_40ppm/length(period_optical);

%% 再看看IO读到的累计误差
cumu_timewin = 12;
cumu_timestep = 1;
j = 1;
for i = 1:cumu_timestep:length(period_sync_read)-cumu_timewin
    cumu_t2(j) = mean(period_sync_read(i:i+cumu_timewin));
    j = j + 1;
end

figure(202)
ylabel('Counts');
xlabel('Average of 12 sync light periods read by SCUM IO (ms)');
hold on
% 放大坐标到ms
cumu_t2_show = cumu_t2 * 1000;
h202 = histogram(cumu_t2_show);
h202.EdgeColor = "black";
h202.FaceColor = "#e89776";
h202.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% 计算 40ppm的范围,+3.33e-7s, 也就是0.33 us
range = [theoretical_period-3.33e-7, theoretical_period+3.33e-7];  % 计数范围
cu_read_40ppm = count_within_range(cumu_t2, range);  % 可直接统计符合范围的值
performance_cu_read_40ppm = cu_read_40ppm/length(period_sync_read);


%% 绘制sync cal period 图
% figure(3)

% figure(3)
% ylabel('Counts');
% xlabel('sync light calibration periods (ms)');
% hold on
% % 放大坐标到ms
% period_sync_cal_show = period_sync_cal * 1000.
% h5 = histogram(period_sync_cal_show);
% h5.EdgeColor = "black";
% h5.FaceColor = "0.93,0.69,0.13";
% h5.LineWidth = 1;
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','on','YMinorGrid','on','box','on');

%% 绘制周期波动图(read)

% figure(2)
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','on','YMinorGrid','on','box','on');
figure(301)
ylabel('Duration (ms)');
xlabel('Periods');
hold on
% 放大坐标到ms
period_show = period_sync_read * 1000.
h301 = plot(period_show);
% h2.EdgeColor = "black";
% h2.FaceColor = "#e89776";
h301.LineWidth = 1;
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','off','YMinorGrid','off','box','off');
% 这是对前文起效？
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');
%%


function duration = calculate_high_level_duration(signaldata, timeframe, threshold)
% calculate_high_level_duration: 计算信号高电平的持续时间
% 输入参数：
%   - signaldata: 信号数据 (列向量)
%   - timeframe: 时间戳数据 (列向量)
%   - threshold: 时间间隔的最小阈值（用于剔除短暂的高电平）
%
% 输出参数：
%   - duration: Nx2 矩阵，每行包含 [高电平持续时间, 起始时间]

% 计算信号的差分，检测上升沿和下降沿
signal_diff = diff(signaldata);

% 找到上升沿和下降沿的索引（+1 修正为原始信号的时刻）
rising_edges = find(signal_diff == 1) + 1;   % 上升沿（从 0 到 1）
falling_edges = find(signal_diff == -1) + 1; % 下降沿（从 1 到 0）

% 确保每个上升沿都有对应的下降沿（避免未闭合的高电平）
num_edges = min(length(rising_edges), length(falling_edges));
rising_edges = rising_edges(1:num_edges);
falling_edges = falling_edges(1:num_edges);

% 计算高电平持续时间
high_durations = timeframe(falling_edges) - timeframe(rising_edges);

% 筛选高电平持续时间大于阈值的记录
valid_indices = find(high_durations > threshold);

% 输出结果矩阵：每行是 [高电平持续时间, 起始时间]
duration = [high_durations(valid_indices), timeframe(rising_edges(valid_indices))];
end

function [period, c_good] = calculate_period_vectorized(duration, threshold, range)
% calculate_period_vectorized: 矢量化计算波之间的时间间隔并统计满足条件的间隔个数
% 输入参数：
%   - duration: Nx2 矩阵，每行包含 [时间间隔, 起始时间] 信息
%   - threshold: 一个标量，筛选条件为时间间隔小于 threshold
%   - range: 1x2 向量，计数条件范围 [min, max]
%
% 输出参数：
%   - period: 存储满足条件的时间间隔数组
%   - c_good: 满足范围条件的时间间隔个数

% 计算相邻两波的时间间隔
period_temp = duration(2:end, 2) - duration(1:end-1, 2);

% 筛选时间间隔小于阈值的值
period = period_temp(period_temp < threshold);

% 统计满足范围条件的时间间隔个数
c_good = count_within_range(period, range);
end

function c_good = count_within_range(period, range)
% count_within_range: 统计时间间隔中符合范围的个数
% 输入参数：
%   - period: 1xN 数组，存储时间间隔
%   - range: 1x2 向量，计数条件范围 [min, max]
%
% 输出参数：
%   - c_good: 满足范围条件的时间间隔个数

% 使用逻辑索引统计符合范围的个数
c_good = sum(period >= range(1) & period <= range(2));
end