% 仅供定位代码使用：https://github.com/atomic-hkust-gz/scum-test-code_cheng/tree/2d_localization_stable
clc;
clear;

%% 
% 设置串口
s = serialport('COM18', 19200, 'Timeout', 10); % 设置为COM18和波特率19200

% 初始化数据存储
data = [];
global currentLabel;
global stopFlag;
currentLabel = 0; % 初始标签
stopFlag = false;

% 设置键盘输入回调
figure('KeyPressFcn', @setKeyPress); % 设置回调函数

% 开始计时
tic;
while toc < 1000 && ~stopFlag  % 持续10秒或直到手动停止
    try
        line = strtrim(readline(s)); % 从串口读取一行数据并去除两端空格
        disp(['Received: ', line]); % 打印接收到的数据
        
        % 使用正则表达式提取变量
        tokens = regexp(line, 'A_X:\s*(\d+),\s*A_Y:\s*(\d+),\s*B_X:\s*(\d+),\s*B_Y:\s*(\d+)', 'tokens');
        if ~isempty(tokens)
            values = str2double(tokens{1});
            labeledValues = [values, currentLabel]; % 添加标签
            data = [data; labeledValues]; % 将数据追加到数组中
            disp('Parsed values with label:');
            disp(labeledValues); % 打印解析出的数据和标签
        else
            disp('No matches found.');
        end
    catch
        disp('未收到数据或读取发生错误');
    end
    
    pause(0.1); % 暂停以避免过多占用CPU
end

% 将数据转换为表格并设置列名
dataTable = array2table(data, 'VariableNames', {'A_X', 'A_Y', 'B_X', 'B_Y', 'Label'});

% 显示表格
disp(dataTable);

% 关闭串口
clear s;

function setKeyPress(~, event)
    global currentLabel;
    global stopFlag;
    if ismember(event.Key, {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'})
        currentLabel = str2double(event.Key); % 更新当前标签
        fprintf('标签已更改为: %d\n', currentLabel);
    elseif strcmp(event.Key, 'q')
        stopFlag = true; % 设置停止标志
        fprintf('手动终止\n');
    end
end
