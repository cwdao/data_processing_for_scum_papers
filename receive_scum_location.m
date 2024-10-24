% 仅供定位代码使用：https://github.com/atomic-hkust-gz/scum-test-code_cheng/tree/2d_localization_stable
clc;
clear;

%% 
% 设置串口
s = serialport('COM18', 19200, 'Timeout', 10); % 设置为COM18和波特率19200

% 初始化数据存储
data = [];

% 读取并解析数据
while true
    try
        line = readline(s); % 从串口读取一行数据
        disp(['Received: ', line]); % 打印接收到的数据
        
        if contains(line, 'A_X')
            % 使用正则表达式提取变量
            tokens = regexp(line, 'A_X: (\d+), A_Y: (\d+), B_X: (\d+), B_Y: (\d+)', 'tokens');
            if ~isempty(tokens)
                values = str2double(tokens{1});
                data = [data; values]; % 将数据追加到数组中
                disp('Parsed values:');
                disp(values); % 打印解析出的数据
            else
                disp('No matches found.');
            end
        end
    catch
        disp('未收到数据或读取发生错误');
    end
    pause(0.1); % 暂停以避免过多占用CPU
end

% 关闭串口（如果需要，可以手动停止）
clear s;