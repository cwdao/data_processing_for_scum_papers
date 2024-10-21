% load data
clc;
clear;
% raw_data = readtable("digital.csv");
% the demo paper data
% raw_data = readtable("digital_synccheck.csv");
% the journal paper data
raw_data = readtable("100ms_stable_check.csv");
%%
timeframe = raw_data.Time_s_;
signaldata_optical = raw_data.Channel4;
signaldata_sync_cal = raw_data.Channel6;

% data_p1 = timetable(timeline,signalline);
%%
% plot(timeframe,signaldata);
t1 = timeframe(46,1)- timeframe(45,1)
t11 = t1*10.0000^6
% the answer is 6.35e-5,if *10^6,it will be us.I think it is enough to
% caculate the duration
%%
% TS4231的Epin以低电平表示根据存储的格式，0表示信号现在开始为0，1表示开始为1.因此只需计算所有0和其紧跟 的1的时间间隔，就能得到所有波的时间。再删除所有小于30us(3e-5
% s)，就得到所有同步 光的时间。
% scum 则更直观，高电平表示有光，即1表示开始，0表示结束。目前这个文档解析的是scum数据

% 还得加上起始时间戳。
j = 1;
for i = 1:length(signaldata_optical)

    if (signaldata_optical(i,1) == 1) && (i ~= length(signaldata_optical))
        duration_temp = timeframe(i+1,1) - timeframe(i,1);
        if duration_temp > 3e-5
            duration(j,1) = timeframe(i+1,1) - timeframe(i,1);
            duration(j,2) = timeframe(i,1);
            j = j + 1;
        end
    end
end
%% 计算每个synclight cal的周期

% 对于synclight calibration 的间隔，代码中每次检测时都会翻转这个IO，因此要找到翻转的边缘。
k =1;
current_state = 0;
last_state = 0;
for ki = 1:length(signaldata_sync_cal)
    last_state = current_state;
    current_state= signaldata_sync_cal(ki,1);
    if (current_state ~= last_state)&&(ki ~= length(signaldata_sync_cal))
        sync_timestamp(k,1) = timeframe(ki,1);
        k = k+1;
    end
end
% 记录了每个变化时刻后，下一步就是计算间隔长度
kp = 1;
for kpi = 1:(length(sync_timestamp(:,1))-1)
    period_sync_cal(kp,1) = sync_timestamp(kpi+1,1)-sync_timestamp(kpi,1);
    kp = kp+1;
end
% 这里就是连续12个周期的周期长度计数，100ms，对应12Hz,其40ppm频率差所对应的周期差为max-min = 6.667e-6
% 0.099996666500000-0.100003333500000
count_40ppm_sync = 0;
count_80ppm_sync = 0;
count_100ppm_sync = 0;
% 0.099983350000000-0.100016650000000
count_200ppm_sync = 0;
count_300ppm_sync = 0;
% 0.099966700000000-0.100033300000000
count_400ppm_sync = 0;
for i = 1:(length(period_sync_cal))
    if (period_sync_cal(i) >= (0.1-6.667e-6/2)) && (period_sync_cal(i)<=(0.1+6.667e-6/2))
        count_40ppm_sync = count_40ppm_sync +1;
    end
    if (period_sync_cal(i) >= (0.1-1.333e-5/2)) && (period_sync_cal(i)<=(0.1+1.333e-5/2))
        count_80ppm_sync = count_80ppm_sync +1;
    end
    if (period_sync_cal(i) >= (0.1-1.667e-5/2)) && (period_sync_cal(i)<=(0.1+1.667e-5/2))
        count_100ppm_sync = count_100ppm_sync +1;
    end
    if (period_sync_cal(i) >= (0.1-3.333e-5/2)) && (period_sync_cal(i)<=(0.1+3.333e-5/2))
        count_200ppm_sync = count_200ppm_sync +1;
    end
    if (period_sync_cal(i) >= (0.1-5e-5/2)) && (period_sync_cal(i)<=(0.1+5e-5/2))
        count_300ppm_sync = count_300ppm_sync +1;
    end
    if (period_sync_cal(i) >= (0.1-6.667e-5/2)) && (period_sync_cal(i)<=(0.1+6.667e-5/2))
        count_400ppm_sync = count_400ppm_sync +1;
    end
end
performance_sync_40ppm = count_40ppm_sync/(length(period_sync_cal));
performance_sync_80ppm = count_80ppm_sync/(length(period_sync_cal));
performance_sync_100ppm = count_100ppm_sync/(length(period_sync_cal));
performance_sync_200ppm = count_200ppm_sync/(length(period_sync_cal));
performance_sync_300ppm = count_300ppm_sync/(length(period_sync_cal));
performance_sync_400ppm = count_400ppm_sync/(length(period_sync_cal));

%% 计算两波的间隔

j2 = 1;
c_good = 0;
for i = 1:(length(duration(:,1))-1)
    period_temp = duration(i+1,2)-duration(i,2);
    if period_temp < 0.01
        period(j2) = period_temp;
        j2 = j2 + 1;
        if period_temp >=0.008323 && period_temp <= 0.008343
            c_good = c_good +1;
        end
    end
end
%%
% +-10us
performance = 14147/29537
% +-5us(8.328-8.338ms)
c_5us = 0;
for i = 1:(length(period))
    if (period(i) >= 8.328e-3) && (period(i)<=8.338e-3)
        c_5us = c_5us +1;
    end
end

performance_5us = c_5us/length(period)

% +-3us(8.330-8.336ms)
c_3us = 0;
for i = 1:(length(period))
    if (period(i) >= 8.330e-3) && (period(i)<=8.336e-3)
        c_3us = c_3us +1;
    end
end

performance_3us = c_3us/length(period)

%% plot figure 原始周期图
% figure(1)
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','off','YMinorGrid','off','box','off');
figure(101)
ylabel('Counts');
xlabel('Sync light periods (ms)');
hold on
% 放大坐标到ms
period_show = period * 1000;
h101 = histogram(period_show);
h101.EdgeColor = "black";
h101.FaceColor = "#e89776";
h101.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');
% 计算 40ppm的范围,+3.33e-7s, 也就是0.33 us
origin_40ppm = 0;
% origin_40ppm_mean = mean(period);
for i = 1:(length(period))
    if (period(i) >= mean(period)-3.333e-7) && (period(i)<=mean(period)+3.333e-7)
        origin_40ppm = origin_40ppm +1;
    end
end

performance_40ppm_origin = origin_40ppm/length(period);




% figure(1)
% set(gca,'FontName','Times New Roman','FontSize',24);
% % ylabel('字体设置为宋体','FontName','宋体','FontSize',24);
% hold on
% figure(1)
% % plot([0.00833;0.00834], [1;1]*50, '-k', 'LineWidth',1); % 显著性的那条直线
% % plot(histogram(period))
% figure(1)
% hold on
% hist = histogram(period);
% hist.EdgeColor = "black";
% hist.FaceColor = "#e89776";
% hist.LineWidth = 1;


% box off;
%
% % find the start poiont of line 5us
% h_edge = hist.BinEdges;
% h_count = hist.BinCounts;
% line1_count_start = 15;
% line1_count_end = 15 + 10;
% line1_y_max = max(h_count)+50;
% xs1 = h_edge(line1_count_start);
% xe1 = h_edge(line1_count_end);
% plot([xs1;xe1], [1;1]*line1_y_max, '-k', 'LineWidth',1); % 显著性的那条直线
% plot([1;1]*xs1, [(h_count(line1_count_start)+ 100), line1_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% plot([1;1]*xe1, [(h_count(line1_count_end)+ 100), line1_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% % set(gca,'FontName','Times New Roman','FontSize',24);
% txt1 = {'\pm 5 us: 95.06 %',''};
%
% t1 = text(mean([xs1,xe1]),line1_y_max,txt1)
% t1.FontSize = 24;
% t1.FontName = 'Times New Roman';
%
% % find the start poiont of line 10us
% h_edge = hist.BinEdges;
% h_count = hist.BinCounts;
% line2_count_start = 10;
% line2_count_end = 10 + 20;
% line2_y_max = max(h_count)+90;
% xs2 = h_edge(line2_count_start);
% xe2 = h_edge(line2_count_end);
% plot([xs2;xe2], [1;1]*line2_y_max, '-k', 'LineWidth',1); % 显著性的那条直线
% plot([1;1]*xs2, [(h_count(line2_count_start)+ 100), line2_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% plot([1;1]*xe2, [(h_count(line2_count_end)+ 100), line2_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% % set(gca,'FontName','Times New Roman','FontSize',24);
% txt2 = {'\pm 10 us: 98.70 %',''};
%
% t2 = text(mean([xs2,xe2]),line2_y_max,txt2)
% t2.FontSize = 24;
% t2.FontName = 'Times New Roman';
%
% % find the start poiont of line 3us
% h_edge = hist.BinEdges;
% h_count = hist.BinCounts;
% line3_count_start = 17;
% line3_count_end = 17 + 6;
% line3_y_max = max(h_count)+10;
% xs3 = h_edge(line3_count_start);
% xe3 = h_edge(line3_count_end);
% plot([xs3;xe3], [1;1]*line3_y_max, '-k', 'LineWidth',1); % 显著性的那条直线
% plot([1;1]*xs3, [(h_count(line3_count_start)+ 100), line3_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% plot([1;1]*xe3, [(h_count(line3_count_end)+ 100), line3_y_max*1], '-k', 'LineWidth', 1); % 显著性的那条直线的左方下直线
% % set(gca,'FontName','Times New Roman','FontSize',24);
% txt3 = {'\pm 3 us: 82.57 %',''};
%
% t3 = text(mean([xs3,xe3]),line3_y_max,txt3)
% t3.FontSize = 24;
% t3.FontName = 'Times New Roman';
%
% ylabel('Counts');
% xlabel('Sync light period (ms)');
% set(gca,'linewidth',1.5);
% plot([1;1]*x(2), [y*1.05, y*1.1], '-k', 'LineWidth', 1); % 显著性的那条直线的右方下直线

%%
mean_data = mean(period);
var_data = var(period);
% sigline()

pd = fitdist(transpose(period),'Normal')
% y_pdf = normpdf(period,pd.mu,pd.sigma);
% 考虑绘制拟合分布，但APP里就有分布拟合
% x = [8.13e-3,.01e-3,8.53e-3];
% y_pdf = normpdf(x,pd.mu,pd.sigma);
% plot(x,y_pdf)
%%
% 考虑绘制体现误差的Y轴的图
% figure(2)
period_diff = period - pd.mu;
% plot(period_diff);
period_diff_us = period_diff * 120.;
%%  累计误差会如何？
cumu_timewin = 12;
cumu_timestep = 1;
j = 1;
for i = 1:cumu_timestep:length(period)-cumu_timewin
    cumu_t1(j) = mean(period(i:i+cumu_timewin));
    j = j + 1;
end
% figure(1)

figure(1)
ylabel('Counts');
xlabel('Average of 12 sync light periods (ms)');
hold on
% 放大坐标到ms
cumu_t1_show = cumu_t1 * 1000.
h2 = histogram(cumu_t1_show);
h2.EdgeColor = "black";
h2.FaceColor = "#e89776";
h2.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% 计算 40ppm的范围,+3.33e-7s, 也就是0.33 us
cumu_40ppm = 0;
cumu_40ppm_mean = mean(cumu_t1);
for i = 1:(length(cumu_t1))
    if (cumu_t1(i) >= mean(cumu_t1)-3.333e-7) && (cumu_t1(i)<=mean(cumu_t1)+3.333e-7)
        cumu_40ppm = cumu_40ppm +1;
    end
end

performance_40ppm = cumu_40ppm/length(cumu_t1)

% 换一个时间窗
% cumu_timewin = 20;
% % cumu_timestep = 1;
% j = 1;
% for i = 1:cumu_timestep:length(period)-cumu_timewin
%     cumu_t2(j) = mean(period(i:i+cumu_timewin));
%     j = j + 1;
% end
% hold on
% figure(1)
% h3 = histogram(cumu_t2);
% set(gca, 'XMinorGrid','on');
% set(gca, 'YMinorGrid','on');
% legend( 'single period', 'average of 10 periods', 'average of 20 periods');
%% 绘制sync cal period 图
% figure(3)

figure(3)
ylabel('Counts');
xlabel('sync light calibration periods (ms)');
hold on
% 放大坐标到ms
period_sync_cal_show = period_sync_cal * 1000.
h5 = histogram(period_sync_cal_show);
h5.EdgeColor = "black";
h5.FaceColor = "0.93,0.69,0.13";
h5.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

%% 绘制周期波动图

% figure(2)
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','on','YMinorGrid','on','box','on');
figure(2)
ylabel('Duration (ms)');
xlabel('Periods');
hold on
% 放大坐标到ms
period_show = period * 1000.
h2 = plot(period_show);
% h2.EdgeColor = "black";
% h2.FaceColor = "#e89776";
h2.LineWidth = 1;
% set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
%     'XMinorGrid','off','YMinorGrid','off','box','off');
% 这是对前文起效？
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');