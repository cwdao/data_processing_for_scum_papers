% load data
clc;
clear;
% the journal paper data
raw_data = readtable("no.print.y560ms.csv");
%%
timeframe = raw_data.Time_s_;
signaldata = raw_data.IO11;

% data_p1 = timetable(timeline,signalline);
%%
% plot(timeframe,signaldata);
t1 = timeframe(5,1)- timeframe(3,1)
t11 = t1*10.0000^6
% the answer is 6.35e-5,if *10^6,it will be us.I think it is enough to
% caculate the duration

%% 本代码仅用于主循环周期的测量
% 确定第一个点（是1）后，下一个点必然是0，1-0是定位周期，再下一个点必是1，1-0-1是完整周期
jk = 1;
for i = 3:length(signaldata)-1
    if (signaldata(i,1) == 1)
        timestamp(jk,1) = timeframe(i,1);
        jk = jk+1;
    end
end
% 取出所有帧之后，开始前后相减计算周期
jk = 1;

for i = 1:length(timestamp)-1
    period(jk,1) = timestamp(i+1,1)-timestamp(i,1);
    jk = jk+1;
end

%% 子周期取出来，但不一定有用
jk = 1;
jl = 1;
for i = 3:length(signaldata)-1
    % 1 是周期开始，首先是定位，用后面的0时刻减去此时刻得到定位周期
    if (signaldata(i,1) == 1)
        period_lct(jk,1) =  timeframe(i+1,1)-timeframe(i,1);
        jk = jk+1;
    end
    % 0 是发包周期开始，用后面的1时刻减去此时刻得到发包时长
    if (signaldata(i,1) == 0)
        period_ble(jl,1) =  timeframe(i+1,1)-timeframe(i,1);
        jl = jl+1;
    end
    period_ble(jl-1,1)=[];
end

%% 画直方图

figure(101)
subplot(1,3,1)
ylabel('Counts');
xlabel('Main Loop periods (ms)');
hold on
% 放大坐标到ms
period_show = period * 1000;
h101 = histogram(period_show);
h101.EdgeColor = "black";
h101.FaceColor = "#e89776";
h101.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% figure(102)
subplot(1,3,2)
ylabel('Counts');
xlabel('Localization periods (ms)');
hold on
% 放大坐标到ms
period_show = period_lct * 1000;
h101 = histogram(period_show);
h101.EdgeColor = "black";
h101.FaceColor = "#e89776";
h101.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');

% figure(103)
subplot(1,3,3)
ylabel('Counts');
xlabel('BLE TX periods (ms)');
hold on
% 放大坐标到ms
period_show = period_ble * 1000;
h101 = histogram(period_show);
h101.EdgeColor = "black";
h101.FaceColor = "#e89776";
h101.LineWidth = 1;
set(gca,'FontName','Times New Roman','FontSize',24,'linewidth',1.5, ...
    'XMinorGrid','on','YMinorGrid','on','box','on');
