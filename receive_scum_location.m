% 仅供定位代码使用：https://github.com/atomic-hkust-gz/scum-test-code_cheng/tree/2d_localization_stable
clc;
clear;

%% 
% 设置串口
s = serialport('COM18', 19200, 'Timeout', 10); % 设置为COM18和波特率19200

% 初始化数据存储
data = [];

% 开始计时
tic;
while toc < 10  % 持续10秒
    try
        line = strtrim(readline(s)); % 从串口读取一行数据并去除两端空格
        disp(['Received: ', line]); % 打印接收到的数据
        
        % 使用正则表达式提取变量
        tokens = regexp(line, 'A_X:\s*(\d+),\s*A_Y:\s*(\d+),\s*B_X:\s*(\d+),\s*B_Y:\s*(\d+)', 'tokens');
        if ~isempty(tokens)
            values = str2double(tokens{1});
            data = [data; values]; % 将数据追加到数组中
            disp('Parsed values:');
            disp(values); % 打印解析出的数据
        else
            disp('No matches found.');
        end
    catch
        disp('未收到数据或读取发生错误');
    end
    pause(0.1); % 暂停以避免过多占用CPU
end

% 将数据转换为表格并设置列名
dataTable = array2table(data, 'VariableNames', {'A_X', 'A_Y', 'B_X', 'B_Y'});

% 显示表格
disp(dataTable);

% 关闭串口
clear s;