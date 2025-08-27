% 农业无人机路径规划系统
% 实现改进的区域分解、基于蚁群算法的路径优化和详细性能指标的往复覆盖
function wedo2()
close all;
clear;
clc;

% 全局变量
global params;
global obstacles;
global subregions;
global paths;
global metrics;
global entryExitPoints;

% 用户输入界面
getUserInput();

% 运行路径规划
runPathPlanning();

% 显示所有结果图形
displayAllFigures();

% 打印结果
printResults();
end

%% 显示所有结果图形
function displayAllFigures()
    % 获取屏幕尺寸
    screenSize = get(0, 'ScreenSize');
    screenWidth = screenSize(3);
    screenHeight = screenSize(4);
    
    % 计算图形位置
    figWidth = screenWidth * 0.45;
    figHeight = screenHeight * 0.45;
    
    % 创建主结果图 (2D和3D视图)
    mainFig = figure('Name', '无人机路径规划结果', 'Position', [10, screenHeight-figHeight-50, figWidth, figHeight]);
    displayMainResults(mainFig);
    
    % 创建性能指标图
    metricsFig = figure('Name', '无人机路径规划性能指标', 'Position', [figWidth+20, screenHeight-figHeight-50, figWidth, figHeight]);
    displayPerformanceMetrics(metricsFig);
    
    % 创建详细计算结果表格
    tableFig = figure('Name', '无人机路径规划详细计算结果', 'Position', [10, screenHeight-2*figHeight-70, figWidth, figHeight]);
    displayResultsTable(tableFig);
    
    % 创建单独的2D可视化图
    viz2DFig = figure('Name', '无人机路径规划 - 2D视图', 'Position', [figWidth+20, screenHeight-2*figHeight-70, figWidth, figHeight]);
    display2DVisualization(viz2DFig);
end

%% 显示主结果 (2D和3D视图)
function displayMainResults(fig)
    global params obstacles subregions entryExitPoints paths metrics;
    
    figure(fig);
    
    % 2D视图 - 只显示障碍物和子区域划分
    subplot(1, 2, 1);
    
    % 设置白色背景
    set(gca, 'Color', 'w');
    
    % 首先绘制网格线（使其显示在所有元素后面）
    gridStep = 10;
    for x = 0:gridStep:params.fieldLength
        plot([x, x], [0, params.fieldWidth], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 0.5);
    end
    for y = 0:gridStep:params.fieldWidth
        plot([0, params.fieldLength], [y, y], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 0.5);
    end
    hold on;
    
    % 绘制农田边界
    rectangle('Position', [0, 0, params.fieldLength, params.fieldWidth], ...
             'EdgeColor', 'k', 'LineWidth', 2);
    
    % 绘制障碍物
    fill([35, 45, 45, 35], [15, 15, 25, 25], [0.7, 0.3, 0.3]);
    text(40, 20, '障碍1', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % 绘制子区域边界，使用紫色虚线
    purpleColor = [0.8, 0.2, 0.8];
    
    % 水平子区域边界，y=15和y=25
    plot([0, params.fieldLength], [15, 15], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    plot([0, params.fieldLength], [25, 25], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    
    % 标记子区域，使用紫色大字体
    text(20, 7.5, 'S1', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(20, 20, 'S2', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(40, 32.5, 'S3', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(62.5, 20, 'S4', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    
    % 定义入口点（红色方块）
    entryPoints = [
        0, 15;    % S2左边缘
        0, 25;    % S3左边缘
        35, 0;    % 障碍物底部
        45, 0;    % S1右下角
        45, 15;   % S2右边缘
        45, 25    % S4右边缘
    ];
    
    % 定义出口点（黄色星形）
    exitPoints = [
        0, 40;    % 左上角
        45, 40;   % 障碍物上方
        45, 25;   % 障碍物右侧
        80, 40    % 右上角
    ];
    
    % 绘制入口点（红色方块）
    for i = 1:size(entryPoints, 1)
        plot(entryPoints(i, 1), entryPoints(i, 2), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    end
    
    % 绘制出口点（黄色星形）
    for i = 1:size(exitPoints, 1)
        plot(exitPoints(i, 1), exitPoints(i, 2), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k');
    end
    
    % 标记起点（绿色星形）
    plot(0, 0, 'p', 'MarkerSize', 20, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    text(2, 2, '起点', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'g');
    
    % 设置坐标轴属性
    axis equal;
    xlim([-5, params.fieldLength + 5]);
    ylim([-5, params.fieldWidth + 5]);
    xlabel('X (米)', 'FontSize', 12);
    ylabel('Y (米)', 'FontSize', 12);
    title('无人机路径规划 - 2D视图 (仅显示障碍物和子区域划分)', 'FontSize', 14);
    
    % 添加图例
    legend('农田边界', '障碍物', '子区域边界', '入口点', '出口点', '起点', ...
          'Location', 'eastoutside');
    
    % 3D视图
    subplot(1, 2, 2);
    
    % 绘制3D农田
    x = [0, params.fieldLength, params.fieldLength, 0];
    y = [0, 0, params.fieldWidth, params.fieldWidth];
    z = zeros(1, 4);
    
    % 绘制农田表面，使用浅绿色
    fill3(x, y, z, [0.8, 0.9, 0.8]);
    hold on;
    
    % 添加绿色点表示作物
    [X, Y] = meshgrid(5:5:params.fieldLength-5, 5:5:params.fieldWidth-5);
    Z = zeros(size(X));
    plot3(X(:), Y(:), Z(:), '.', 'Color', [0.3, 0.8, 0.3], 'MarkerSize', 8);
    
    % 绘制3D障碍物
    for i = 1:params.numObstacles
        if ~isempty(obstacles) && ~isempty(obstacles{i})
            % 绘制底面
            fill3(obstacles{i}.x, obstacles{i}.y, zeros(size(obstacles{i}.x)), [0.7, 0.3, 0.3]);
            
            % 绘制顶面
            fill3(obstacles{i}.x, obstacles{i}.y, ...
                 obstacles{i}.height * ones(size(obstacles{i}.x)), [0.7, 0.3, 0.3]);
            
            % 绘制侧面
            for j = 1:length(obstacles{i}.x)
                k = mod(j, length(obstacles{i}.x)) + 1;
                
                % 定义这个侧面的四个角
                sideX = [obstacles{i}.x(j), obstacles{i}.x(k), ...
                        obstacles{i}.x(k), obstacles{i}.x(j)];
                sideY = [obstacles{i}.y(j), obstacles{i}.y(k), ...
                        obstacles{i}.y(k), obstacles{i}.y(j)];
                sideZ = [0, 0, obstacles{i}.height, obstacles{i}.height];
                
                % 绘制侧面
                fill3(sideX, sideY, sideZ, [0.7, 0.3, 0.3]);
            end
            
            % 标记障碍物
            text(mean(obstacles{i}.x), mean(obstacles{i}.y), obstacles{i}.height, ...
                sprintf('障碍 %d', i), 'FontSize', 12, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center');
        end
    end
    
    % 绘制3D子区域边界（匹配2D）
    purpleColor = [0.8, 0.2, 0.8];
    % 水平边界，y=15和y=25，z=0.5
    plot3([0, params.fieldLength], [15, 15], [0.5, 0.5], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    plot3([0, params.fieldLength], [25, 25], [0.5, 0.5], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    
    % 标记子区域（与2D一致）
    text(20, 7.5, 0.5, 'S1', 'FontSize', 12, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(20, 20, 0.5, 'S2', 'FontSize', 12, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(40, 32.5, 0.5, 'S3', 'FontSize', 12, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(62.5, 20, 0.5, 'S4', 'FontSize', 12, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    
    % 绘制3D无人机路径
    for i = 1:length(paths)
        % 为路径创建z坐标（在50m高度）
        pathZ = 50 * ones(size(paths{i}.x));
        
        % 绘制路径
        if strcmp(paths{i}.type, 'working')
            % 工作路径用青色
            plot3(paths{i}.x, paths{i}.y, pathZ, '-', 'Color', [0, 1, 1], 'LineWidth', 2);
        else
            % 非工作路径用黄色虚线
            plot3(paths{i}.x, paths{i}.y, pathZ, '--', 'Color', [1, 0.8, 0], 'LineWidth', 1.5);
        end
        
        % 标记起点
        plot3(paths{i}.x(1), paths{i}.y(1), pathZ(1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
        
        % 标记终点
        plot3(paths{i}.x(end), paths{i}.y(end), pathZ(end), 's', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    end
    
    % 标记起点（坐标原点）
    plot3(0, 0, 0, 'p', 'MarkerSize', 15, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    text(2, 2, 2, '起点', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'g');
    
    % 设置坐标轴属性
    axis equal;
    xlim([-5, params.fieldLength + 5]);
    ylim([-5, params.fieldWidth + 5]);
    zlim([0, 60]); % 调整z范围以适应50m路径
    xlabel('X (米)');
    ylabel('Y (米)');
    zlabel('Z (米)');
    title('无人机路径规划 - 3D视图');
    grid on;
    
    % 设置视图角度以使路径显示在略高于中心
    view(45, 20); % 降低俯角，使路径看起来稍高但不过高
end

%% 显示性能指标
function displayPerformanceMetrics(fig)
    global metrics;
    
    figure(fig);
    
    % 创建子图
    subplot(1, 2, 1);
    
    % 绘制路径长度和转弯次数柱状图
    barData = [metrics.workingDistance, metrics.totalDistance - metrics.workingDistance; ...
              metrics.workingTurns, metrics.totalTurns - metrics.workingTurns];
    
    b = bar(barData, 'stacked');
    b(1).FaceColor = [0.2, 0.6, 0.2]; % 工作部分（绿色）
    b(2).FaceColor = [0.8, 0.3, 0.3]; % 非工作部分（红色）
    
    % 添加标签
    xticklabels({'路径长度 (米)', '转弯次数'});
    ylabel('数值');
    title('路径长度和转弯次数');
    
    % 添加数据标签
    for i = 1:size(barData, 1)
        text(i, sum(barData(i,:))*1.05, num2str(sum(barData(i,:)), '%.1f'), ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
    
    % 添加图例
    legend('工作部分', '非工作部分', 'Location', 'northwest');
    
    % 绘制覆盖率饼图
    subplot(1, 2, 2);
    
    pieData = [metrics.coverageRate, metrics.overlapRate, metrics.missRate];
    pieLabels = {sprintf('覆盖率 (%.1f%%)', metrics.coverageRate), ...
                sprintf('重叠率 (%.1f%%)', metrics.overlapRate), ...
                sprintf('遗漏率 (%.1f%%)', metrics.missRate)};
    
    pie(pieData, [1, 1, 1], pieLabels);
    colormap([0.2, 0.6, 0.2; 0.8, 0.8, 0.2; 0.8, 0.3, 0.3]);
    title('覆盖率分析');
end

%% 显示结果表格
function displayResultsTable(fig)
    global params obstacles metrics;
    
    figure(fig);
    
    % 创建表格数据
    metricsTable = uitable('Data', [], 'Position', [50, 50, 700, 500]);
    
    % 表格列名
    columnNames = {'指标', '数值', '单位'};
    
    % 表格数据
    tableData = {
        '总路径长度', metrics.totalDistance, '米';
        '工作路径长度', metrics.workingDistance, '米';
        '非工作路径长度', metrics.totalDistance - metrics.workingDistance, '米';
        '总转弯次数', metrics.totalTurns, '次';
        '工作转弯次数', metrics.workingTurns, '次';
        '非工作转弯次数', metrics.totalTurns - metrics.workingTurns, '次';
        '总作业时间', metrics.totalTime, '秒';
        '工作时间', metrics.workingTime, '秒';
        '非工作时间', metrics.totalTime - metrics.workingTime, '秒';
        '覆盖率', metrics.coverageRate, '%';
        '重叠率', metrics.overlapRate, '%';
        '遗漏率', metrics.missRate, '%';
        '效率', (metrics.workingDistance / metrics.totalDistance) * 100, '%';
        '子区域数量', metrics.numSubregions, '个';
        '农田面积', params.fieldLength * params.fieldWidth, '平方米';
    };
    
    % 如果有障碍物，添加障碍物相关指标
    if params.numObstacles > 0 && ~isempty(obstacles) && ~isempty(obstacles{1})
        try
            obstacleArea = polyarea(obstacles{1}.x, obstacles{1}.y);
            effectiveArea = (params.fieldLength * params.fieldWidth) - obstacleArea;
            
            additionalData = {
                '障碍物面积', obstacleArea, '平方米';
                '有效农田面积', effectiveArea, '平方米';
            };
            
            tableData = [tableData; additionalData];
        catch
            % 如果计算障碍物面积出错，跳过这些指标
        end
    end
    
    % 添加其他指标
    additionalData = {
        '覆盖宽度', params.coverageWidth, '米';
        '飞行速度', params.flightSpeed, '米/秒';
        '飞行高度', params.flightHeight, '米';
    };
    
    tableData = [tableData; additionalData];
    
    % 设置表格属性
    set(metricsTable, 'Data', tableData, 'ColumnName', columnNames, ...
        'RowName', [], 'ColumnWidth', {200, 150, 100}, ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % 添加标题
    annotation('textbox', [0.3, 0.9, 0.4, 0.05], 'String', '无人机路径规划详细计算结果', ...
        'FontSize', 16, 'FontWeight', 'bold', 'EdgeColor', 'none', ...
        'HorizontalAlignment', 'center');
end

%% 单独的2D可视化函数
function display2DVisualization(fig)
    % 农业无人机路径规划系统 - 2D可视化
    % 此函数生成与图像完全匹配的2D可视化图
    
    % 使用传入的图形句柄
    figure(fig);
    
    % 定义农田参数
    fieldLength = 80;  % X方向长度（米）
    fieldWidth = 40;   % Y方向宽度（米）
    
    % 设置白色背景
    set(gca, 'Color', 'w');
    
    % 首先绘制网格线（使其显示在所有元素后面）
    gridStep = 10;
    for x = 0:gridStep:fieldLength
        plot([x, x], [0, fieldWidth], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 0.5);
    end
    for y = 0:gridStep:fieldWidth
        plot([0, fieldLength], [y, y], 'Color', [0.9, 0.9, 0.9], 'LineWidth', 0.5);
    end
    hold on;
    
    % 绘制农田边界
    rectangle('Position', [0, 0, fieldLength, fieldWidth], ...
             'EdgeColor', 'k', 'LineWidth', 2);
    
    % 绘制障碍物
    fill([35, 45, 45, 35], [15, 15, 25, 25], [0.7, 0.3, 0.3]);
    text(40, 20, '障碍1', 'FontSize', 12, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % 绘制子区域边界，使用紫色虚线
    purpleColor = [0.8, 0.2, 0.8];
    
    % 水平子区域边界，y=15和y=25
    plot([0, fieldLength], [15, 15], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    plot([0, fieldLength], [25, 25], '--', 'Color', purpleColor, 'LineWidth', 1.5);
    
    % 标记子区域，使用紫色大字体
    text(20, 7.5, 'S1', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(20, 20, 'S2', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(40, 32.5, 'S3', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    text(62.5, 20, 'S4', 'FontSize', 16, 'FontWeight', 'bold', ...
        'Color', purpleColor, 'HorizontalAlignment', 'center');
    
    % 定义入口点（红色方块）
    entryPoints = [
        0, 15;    % S2左边缘
        0, 25;    % S3左边缘
        35, 0;    % 障碍物底部
        45, 0;    % S1右下角
        45, 15;   % S2右边缘
        45, 25    % S4右边缘
    ];
    
    % 定义出口点（黄色星形）
    exitPoints = [
        0, 40;    % 左上角
        45, 40;   % 障碍物上方
        45, 25;   % 障碍物右侧
        80, 40    % 右上角
    ];
    
    % 绘制入口点（红色方块）
    for i = 1:size(entryPoints, 1)
        plot(entryPoints(i, 1), entryPoints(i, 2), 's', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');
    end
    
    % 绘制出口点（黄色星形）
    for i = 1:size(exitPoints, 1)
        plot(exitPoints(i, 1), exitPoints(i, 2), 'p', 'MarkerSize', 10, ...
            'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k');
    end
    
    % 标记起点（绿色星形）
    plot(0, 0, 'p', 'MarkerSize', 20, 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'LineWidth', 2);
    text(2, 2, '起点', 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'g');
    
    % 设置坐标轴属性
    axis equal;
    xlim([-5, fieldLength + 5]);
    ylim([-5, fieldWidth + 5]);
    xlabel('X (米)', 'FontSize', 12);
    ylabel('Y (米)', 'FontSize', 12);
    title('无人机路径规划 - 2D视图 (仅显示障碍物和子区域划分)', 'FontSize', 14);
    
    % 添加图例
    legend('农田边界', '障碍物', '子区域边界', '入口点', '出口点', '起点', ...
          'Location', 'eastoutside');
end

%% 用户输入界面
function getUserInput()
    % 重新声明全局变量
    global params;
    global obstacles;
    
    % 创建用户界面
    fig = figure('Name', '农业无人机路径规划系统', 'Position', [100, 100, 800, 600], ...
                'NumberTitle', 'off', 'MenuBar', 'none');
    
    % 创建选项卡
    tabGroup = uitabgroup(fig, 'Position', [0.05, 0.05, 0.9, 0.9]);
    
    % 农田参数选项卡
    tabField = uitab(tabGroup, 'Title', '农田参数');
    
    % 障碍物参数选项卡
    tabObstacles = uitab(tabGroup, 'Title', '障碍物参数');
    
    % 无人机参数选项卡
    tabUAV = uitab(tabGroup, 'Title', '无人机参数');
    
    % 算法参数选项卡
    tabAlgorithm = uitab(tabGroup, 'Title', '算法参数');
    
    % 农田参数控件
    uicontrol(tabField, 'Style', 'text', 'String', '农田长度 (X方向, m):', ...
             'Position', [50, 500, 200, 20], 'HorizontalAlignment', 'left');
    fieldLengthEdit = uicontrol(tabField, 'Style', 'edit', 'String', '80', ...
                               'Position', [250, 500, 100, 20]);
    
    uicontrol(tabField, 'Style', 'text', 'String', '农田宽度 (Y方向, m):', ...
             'Position', [50, 460, 200, 20], 'HorizontalAlignment', 'left');
    fieldWidthEdit = uicontrol(tabField, 'Style', 'edit', 'String', '40', ...
                              'Position', [250, 460, 100, 20]);
    
    % 障碍物参数控件
    uicontrol(tabObstacles, 'Style', 'text', 'String', '障碍物数量:', ...
             'Position', [50, 500, 200, 20], 'HorizontalAlignment', 'left');
    numObstaclesEdit = uicontrol(tabObstacles, 'Style', 'edit', 'String', '1', ...
                                'Position', [250, 500, 100, 20]);
    
    uicontrol(tabObstacles, 'Style', 'text', 'String', '使用默认障碍物:', ...
             'Position', [50, 460, 200, 20], 'HorizontalAlignment', 'left');
    useDefaultObstacles = uicontrol(tabObstacles, 'Style', 'checkbox', 'Value', 1, ...
                                   'Position', [250, 460, 20, 20]);
    
    % 无人机参数控件
    uicontrol(tabUAV, 'Style', 'text', 'String', '覆盖宽度 (m):', ...
             'Position', [50, 500, 200, 20], 'HorizontalAlignment', 'left');
    coverageWidthEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '2', ...
                                 'Position', [250, 500, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '飞行速度 (m/s):', ...
             'Position', [50, 460, 200, 20], 'HorizontalAlignment', 'left');
    flightSpeedEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '5', ...
                               'Position', [250, 460, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '飞行高度 (m):', ...
             'Position', [50, 420, 200, 20], 'HorizontalAlignment', 'left');
    flightHeightEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '50', ...
                                'Position', [250, 420, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '水平安全距离 (m):', ...
             'Position', [50, 380, 200, 20], 'HorizontalAlignment', 'left');
    horizontalSafetyDistanceEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '1.5', ...
                                            'Position', [250, 380, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '垂直安全距离 (m):', ...
             'Position', [50, 340, 200, 20], 'HorizontalAlignment', 'left');
    verticalSafetyDistanceEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '1.0', ...
                                          'Position', [250, 340, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '转弯半径 (m):', ...
             'Position', [50, 300, 200, 20], 'HorizontalAlignment', 'left');
    turningRadiusEdit = uicontrol(tabUAV, 'Style', 'edit', 'String', '2', ...
                                 'Position', [250, 300, 100, 20]);
    
    uicontrol(tabUAV, 'Style', 'text', 'String', '任务完成后返回起点:', ...
             'Position', [50, 260, 200, 20], 'HorizontalAlignment', 'left');
    returnToStartCheck = uicontrol(tabUAV, 'Style', 'checkbox', 'Value', 1, ...
                                  'Position', [250, 260, 20, 20]);
    
    % 算法参数控件
    uicontrol(tabAlgorithm, 'Style', 'text', 'String', '蚂蚁数量:', ...
             'Position', [50, 500, 200, 20], 'HorizontalAlignment', 'left');
    antCountEdit = uicontrol(tabAlgorithm, 'Style', 'edit', 'String', '30', ...
                            'Position', [250, 500, 100, 20]);
    
    uicontrol(tabAlgorithm, 'Style', 'text', 'String', '迭代次数:', ...
             'Position', [50, 460, 200, 20], 'HorizontalAlignment', 'left');
    iterationsEdit = uicontrol(tabAlgorithm, 'Style', 'edit', 'String', '50', ...
                              'Position', [250, 460, 100, 20]);
    
    uicontrol(tabAlgorithm, 'Style', 'text', 'String', 'Alpha (信息素重要程度):', ...
             'Position', [50, 420, 200, 20], 'HorizontalAlignment', 'left');
    alphaEdit = uicontrol(tabAlgorithm, 'Style', 'edit', 'String', '1.0', ...
                         'Position', [250, 420, 100, 20]);
    
    uicontrol(tabAlgorithm, 'Style', 'text', 'String', 'Beta (启发式因子重要程度):', ...
             'Position', [50, 380, 200, 20], 'HorizontalAlignment', 'left');
    betaEdit = uicontrol(tabAlgorithm, 'Style', 'edit', 'String', '2.0', ...
                        'Position', [250, 380, 100, 20]);
    
    uicontrol(tabAlgorithm, 'Style', 'text', 'String', 'Rho (信息素蒸发率):', ...
             'Position', [50, 340, 200, 20], 'HorizontalAlignment', 'left');
    rhoEdit = uicontrol(tabAlgorithm, 'Style', 'edit', 'String', '0.5', ...
                       'Position', [250, 340, 100, 20]);
    
    % 确认按钮
    uicontrol(fig, 'Style', 'pushbutton', 'String', '确认参数', ...
             'Position', [350, 20, 100, 30], 'Callback', @confirmCallback);
    
    % 等待用户确认
    uiwait(fig);
    
    % 回调函数
    function confirmCallback(~, ~)
        % 读取用户输入
        params.fieldLength = str2double(get(fieldLengthEdit, 'String'));
        params.fieldWidth = str2double(get(fieldWidthEdit, 'String'));
        
        params.numObstacles = str2double(get(numObstaclesEdit, 'String'));
        params.useDefaultObstacles = get(useDefaultObstacles, 'Value');
        
        params.coverageWidth = str2double(get(coverageWidthEdit, 'String'));
        params.flightSpeed = str2double(get(flightSpeedEdit, 'String'));
        params.flightHeight = str2double(get(flightHeightEdit, 'String'));
        params.horizontalSafetyDistance = str2double(get(horizontalSafetyDistanceEdit, 'String'));
        params.verticalSafetyDistance = str2double(get(verticalSafetyDistanceEdit, 'String'));
        params.turningRadius = str2double(get(turningRadiusEdit, 'String'));
        params.returnToStart = get(returnToStartCheck, 'Value');
        
        params.aco.antCount = str2double(get(antCountEdit, 'String'));
        params.aco.iterations = str2double(get(iterationsEdit, 'String'));
        params.aco.alpha = str2double(get(alphaEdit, 'String'));
        params.aco.beta = str2double(get(betaEdit, 'String'));
        params.aco.rho = str2double(get(rhoEdit, 'String'));
        params.aco.q0 = 0.9;
        params.aco.initialPheromone = 0.1;
        
        % 初始化障碍物
        initializeObstacles();
        
        % 关闭界面
        uiresume(fig);
        close(fig);
    end
end

%% 初始化障碍物
function initializeObstacles()
    global params obstacles;
    
    obstacles = cell(1, params.numObstacles);
    
    if params.useDefaultObstacles && params.numObstacles > 0
        obstacles{1} = struct('type', 'rectangle', ...
                             'x', [35, 45, 45, 35], ...
                             'y', [15, 15, 25, 25], ...
                             'height', 15);
        
        if params.numObstacles > 1
            obstacles{2} = struct('type', 'rectangle', ...
                                 'x', [20, 30, 30, 20], ...
                                 'y', [35, 35, 45, 45], ...
                                 'height', 10);
        end
        
        if params.numObstacles > 2
            obstacles{3} = struct('type', 'circle', ...
                                 'x', 75 + 5*cos(linspace(0, 2*pi, 20)), ...
                                 'y', 35 + 5*sin(linspace(0, 2*pi, 20)), ...
                                 'height', 12);
        end
    else
        for i = 1:params.numObstacles
            prompt = {sprintf('障碍物 %d 类型 (rectangle/circle):', i), ...
                     sprintf('障碍物 %d X坐标 (逗号分隔):', i), ...
                     sprintf('障碍物 %d Y坐标 (逗号分隔):', i), ...
                     sprintf('障碍物 %d 高度 (m):', i)};
            dlgtitle = sprintf('障碍物 %d 参数', i);
            dims = [1 50];
            
            if i == 1
                definput = {'rectangle', '35,45,45,35', '15,15,25,25', '15'};
            elseif i == 2
                definput = {'rectangle', '20,30,30,20', '35,35,45,45', '10'};
            else
                definput = {'circle', num2str(75 + 5*cos(linspace(0, 2*pi, 20))), ...
                           num2str(35 + 5*sin(linspace(0, 2*pi, 20))), '12'};
            end
            
            answer = inputdlg(prompt, dlgtitle, dims, definput);
            
            if ~isempty(answer)
                obstType = answer{1};
                xStr = strrep(answer{2}, ' ', '');
                xValues = str2num(xStr);
                yStr = strrep(answer{3}, ' ', '');
                yValues = str2num(yStr);
                height = str2double(answer{4});
                
                obstacles{i} = struct('type', obstType, 'x', xValues, 'y', yValues, 'height', height);
            end
        end
    end
end

%% 运行路径规划
function runPathPlanning()
    global params obstacles subregions entryExitPoints paths metrics;
    
    % 基于障碍物创建子区域
    subregions = createSubregionsBasedOnObstacles();
    
    % 计算子区域的入口/出口点
    entryExitPoints = calculateEntryExitPoints(subregions);
    
    % 使用ACO优化子区域遍历顺序
    [optimizedOrder, ~] = optimizeSubregionOrderACO(entryExitPoints);
    
    % 重新排序子区域
    subregions = subregions(optimizedOrder);
    entryExitPoints = entryExitPoints(optimizedOrder);
    
    % 生成覆盖路径
    paths = generateCoveragePaths(subregions, entryExitPoints);
    
    % 计算性能指标
    metrics = calculateMetrics(paths);
end

%% 基于障碍物创建子区域
function regions = createSubregionsBasedOnObstacles()
    global params obstacles;
    
    % 定义四个子区域，匹配2D可视化
    regions = cell(1, 4);
    
    % S1: 下部区域 (y=0 到 y=15)
    regions{1} = struct('id', 1, ...
                       'x', [0, params.fieldLength, params.fieldLength, 0], ...
                       'y', [0, 0, 15, 15]);
    
    % S2: 中部区域 (y=15 到 y=25, x=0 到 x=35)
    regions{2} = struct('id', 2, ...
                       'x', [0, 35, 35, 0], ...
                       'y', [15, 15, 25, 25]);
    
    % S3: 上部区域 (y=25 到 y=40)
    regions{3} = struct('id', 3, ...
                       'x', [0, params.fieldLength, params.fieldLength, 0], ...
                       'y', [25, 25, params.fieldWidth, params.fieldWidth]);
    
    % S4: 右部区域 (y=15 到 y=25, x=45 到 x=80)
    regions{4} = struct('id', 4, ...
                       'x', [45, params.fieldLength, params.fieldLength, 45], ...
                       'y', [15, 15, 25, 25]);
    
    % 验证区域不与障碍物重叠
    for i = 1:length(regions)
        centerX = mean(regions{i}.x);
        centerY = mean(regions{i}.y);
        for j = 1:length(obstacles)
            if ~isempty(obstacles{j}) && inpolygon(centerX, centerY, obstacles{j}.x, obstacles{j}.y)
                error('子区域 S%d 与障碍物重叠', i);
            end
        end
    end
end

%% 计算子区域的入口/出口点
function entryExitPoints = calculateEntryExitPoints(regions)
    global params;
    entryExitPoints = cell(size(regions));
    
    for i = 1:length(regions)
        vertices = [regions{i}.x', regions{i}.y'];
        minX = min(regions{i}.x);
        maxX = max(regions{i}.x);
        minY = min(regions{i}.y);
        maxY = max(regions{i}.y);
        
        coverageWidth = params.coverageWidth;
        turningRadius = params.turningRadius;
        
        % 为每个子区域定义入口和出口点
        switch i
            case 1 % S1
                entryPoint = [minX + coverageWidth/2, minY + turningRadius];
                exitPoint = [maxX - coverageWidth/2, minY + turningRadius];
            case 2 % S2
                entryPoint = [minX + coverageWidth/2, minY + turningRadius];
                exitPoint = [maxX - coverageWidth/2, maxY - turningRadius];
            case 3 % S3
                entryPoint = [minX + coverageWidth/2, minY + turningRadius];
                exitPoint = [maxX - coverageWidth/2, maxY - turningRadius];
            case 4 % S4
                entryPoint = [minX + coverageWidth/2, minY + turningRadius];
                exitPoint = [maxX - coverageWidth/2, maxY - turningRadius];
        end
        
        entryExitPoints{i} = struct('entry', entryPoint, 'exit', exitPoint, 'vertices', vertices);
    end
end

%% 使用ACO优化子区域遍历顺序
function [optimizedOrder, bestLength] = optimizeSubregionOrderACO(entryExitPoints)
    global params;
    n = length(entryExitPoints);
    
    if n <= 1
        optimizedOrder = 1:n;
        bestLength = 0;
        return;
    end
    
    distMatrix = zeros(n, n);
    for i = 1:n
        for j = 1:n
            if i == j
                distMatrix(i, j) = inf;
            else
                exitI = entryExitPoints{i}.exit;
                entryJ = entryExitPoints{j}.entry;
                distMatrix(i, j) = calculateAStarDistance(exitI, entryJ);
            end
        end
    end
    
    startDist = zeros(1, n);
    for i = 1:n
        entryI = entryExitPoints{i}.entry;
        startDist(i) = calculateAStarDistance([0, 0], entryI);
    end
    
    endDist = zeros(1, n);
    if params.returnToStart
        for i = 1:n
            exitI = entryExitPoints{i}.exit;
            endDist(i) = calculateAStarDistance(exitI, [0, 0]);
        end
    end
    
    antCount = params.aco.antCount;
    iterations = params.aco.iterations;
    alpha = params.aco.alpha;
    beta = params.aco.beta;
    rho = params.aco.rho;
    q0 = params.aco.q0;
    initialPheromone = params.aco.initialPheromone;
    
    pheromone = ones(n, n) * initialPheromone;
    bestOrder = 1:n;
    bestLength = calculateTourLength(bestOrder, distMatrix, startDist, endDist);
    
    for iter = 1:iterations
        antOrders = zeros(antCount, n);
        antLengths = zeros(antCount, 1);
        
        for ant = 1:antCount
            start = randi(n);
            visited = false(1, n);
            visited(start) = true;
            order = zeros(1, n);
            order(1) = start;
            current = start;
            
            for step = 2:n
                unvisited = find(~visited);
                if isempty(unvisited)
                    break;
                end
                probs = zeros(1, length(unvisited));
                for i = 1:length(unvisited)
                    next = unvisited(i);
                    heuristic = 1 / distMatrix(current, next);
                    probs(i) = pheromone(current, next)^alpha * heuristic^beta;
                end
                if sum(probs) > 0
                    probs = probs / sum(probs);
                else
                    probs = ones(1, length(unvisited)) / length(unvisited);
                end
                if rand < q0
                    [~, idx] = max(probs);
                    next = unvisited(idx);
                else
                    cumProbs = cumsum(probs);
                    r = rand;
                    idx = find(cumProbs >= r, 1);
                    if isempty(idx)
                        idx = length(unvisited);
                    end
                    next = unvisited(idx);
                end
                order(step) = next;
                visited(next) = true;
                current = next;
            end
            tourLength = calculateTourLength(order, distMatrix, startDist, endDist);
            antOrders(ant, :) = order;
            antLengths(ant) = tourLength;
            if tourLength < bestLength
                bestLength = tourLength;
                bestOrder = order;
            end
        end
        pheromone = (1 - rho) * pheromone;
        for ant = 1:antCount
            order = antOrders(ant, :);
            tourLength = antLengths(ant);
            deposit = 1 / tourLength;
            for i = 1:n-1
                from = order(i);
                to = order(i+1);
                pheromone(from, to) = pheromone(from, to) + deposit;
            end
        end
    end
    optimizedOrder = bestOrder;
end

%% 计算A*距离
function distance = calculateAStarDistance(start, goal)
    global obstacles params;
    gridResolution = 1.0;
    gridSizeX = ceil(params.fieldLength / gridResolution);
    gridSizeY = ceil(params.fieldWidth / gridResolution);
    occupancyGrid = zeros(gridSizeX, gridSizeY);
    
    for i = 1:length(obstacles)
        if ~isempty(obstacles{i})
            minX = max(1, floor(min(obstacles{i}.x) / gridResolution));
            maxX = min(gridSizeX, ceil(max(obstacles{i}.x) / gridResolution));
            minY = max(1, floor(min(obstacles{i}.y) / gridResolution));
            maxY = min(gridSizeY, ceil(max(obstacles{i}.y) / gridResolution));
            for x = minX:maxX
                for y = minY:maxY
                    cellCenterX = (x - 0.5) * gridResolution;
                    cellCenterY = (y - 0.5) * gridResolution;
                    if inpolygon(cellCenterX, cellCenterY, obstacles{i}.x, obstacles{i}.y)
                        occupancyGrid(x, y) = 1;
                    end
                end
            end
        end
    end
    
    startX = max(1, min(gridSizeX, round(start(1) / gridResolution)));
    startY = max(1, min(gridSizeY, round(start(2) / gridResolution)));
    goalX = max(1, min(gridSizeX, round(goal(1) / gridResolution)));
    goalY = max(1, min(gridSizeY, round(goal(2) / gridResolution)));
    
    if occupancyGrid(startX, startY) == 1 || occupancyGrid(goalX, goalY) == 1
        distance = norm(goal - start);
        return;
    end
    
    openList = [];
    closedList = zeros(gridSizeX, gridSizeY);
    g = inf(gridSizeX, gridSizeY);
    f = inf(gridSizeX, gridSizeY);
    g(startX, startY) = 0;
    f(startX, startY) = norm([startX, startY] - [goalX, goalY]);
    openList = [openList; startX, startY, f(startX, startY)];
    directions = [-1, -1; -1, 0; -1, 1; 0, -1; 0, 1; 1, -1; 1, 0; 1, 1];
    
    while ~isempty(openList)
        [~, idx] = min(openList(:, 3));
        currentX = openList(idx, 1);
        currentY = openList(idx, 2);
        openList(idx, :) = [];
        if currentX == goalX && currentY == goalY
            distance = g(goalX, goalY) * gridResolution;
            return;
        end
        closedList(currentX, currentY) = 1;
        for i = 1:size(directions, 1)
            neighborX = currentX + directions(i, 1);
            neighborY = currentY + directions(i, 2);
            if neighborX < 1 || neighborX > gridSizeX || ...
               neighborY < 1 || neighborY > gridSizeY
                continue;
            end
            if occupancyGrid(neighborX, neighborY) == 1
                continue;
            end
            if closedList(neighborX, neighborY) == 1
                continue;
            end
            tentativeG = g(currentX, currentY) + norm([directions(i, 1), directions(i, 2)]);
            inOpenList = false;
            for j = 1:size(openList, 1)
                if openList(j, 1) == neighborX && openList(j, 2) == neighborY
                    inOpenList = true;
                    break;
                end
            end
            if ~inOpenList || tentativeG < g(neighborX, neighborY)
                g(neighborX, neighborY) = tentativeG;
                f(neighborX, neighborY) = g(neighborX, neighborY) + norm([neighborX, neighborY] - [goalX, goalY]);
                if ~inOpenList
                    openList = [openList; neighborX, neighborY, f(neighborX, neighborY)];
                end
            end
        end
    end
    distance = norm(goal - start);
end

%% 计算遍历路径长度
function tourLength = calculateTourLength(order, distMatrix, startDist, endDist)
    tourLength = 0;
    tourLength = tourLength + startDist(order(1));
    for i = 1:length(order)-1
        tourLength = tourLength + distMatrix(order(i), order(i+1));
    end
    if ~isempty(endDist) && any(endDist > 0)
        tourLength = tourLength + endDist(order(end));
    end
end

%% 生成覆盖路径
function paths = generateCoveragePaths(regions, entryExitPoints)
    global params;
    paths = cell(1, length(regions));
    
    for i = 1:length(regions)
        minX = min(regions{i}.x);
        maxX = max(regions{i}.x);
        minY = min(regions{i}.y);
        maxY = max(regions{i}.y);
        width = maxX - minX;
        height = maxY - minY;
        coverageWidth = params.coverageWidth;
        turningRadius = params.turningRadius;
        
        if width <= height
            coverageDirection = 'vertical';
        else
            coverageDirection = 'horizontal';
        end
        
        if strcmp(coverageDirection, 'vertical')
            numSweeps = ceil(width / coverageWidth);
            pathX = [];
            pathY = [];
            entryX = entryExitPoints{i}.entry(1);
            entryY = entryExitPoints{i}.entry(2);
            pathX(end+1) = entryX;
            pathY(end+1) = entryY;
            for j = 1:numSweeps
                x = minX + (j - 0.5) * coverageWidth;
                x = min(x, maxX - 0.1);
                if mod(j, 2) == 1
                    pathX = [pathX, x, x];
                    pathY = [pathY, minY + turningRadius, maxY - turningRadius];
                    if j < numSweeps
                        pathX = [pathX, x + coverageWidth];
                        pathY = [pathY, maxY - turningRadius];
                    end
                else
                    pathX = [pathX, x, x];
                    pathY = [pathY, maxY - turningRadius, minY + turningRadius];
                    if j < numSweeps
                        pathX = [pathX, x + coverageWidth];
                        pathY = [pathY, minY + turningRadius];
                    end
                end
            end
            exitX = entryExitPoints{i}.exit(1);
            exitY = entryExitPoints{i}.exit(2);
            pathX(end+1) = exitX;
            pathY(end+1) = exitY;
        else
            numSweeps = ceil(height / coverageWidth);
            pathX = [];
            pathY = [];
            entryX = entryExitPoints{i}.entry(1);
            entryY = entryExitPoints{i}.entry(2);
            pathX(end+1) = entryX;
            pathY(end+1) = entryY;
            for j = 1:numSweeps
                y = minY + (j - 0.5) * coverageWidth;
                y = min(y, maxY - 0.1);
                if mod(j, 2) == 1
                    pathX = [pathX, minX + turningRadius, maxX - turningRadius];
                    pathY = [pathY, y, y];
                    if j < numSweeps
                        pathX = [pathX, maxX - turningRadius];
                        pathY = [pathY, y + coverageWidth];
                    end
                else
                    pathX = [pathX, maxX - turningRadius, minX + turningRadius];
                    pathY = [pathY, y, y];
                    if j < numSweeps
                        pathX = [pathX, minX + turningRadius];
                        pathY = [pathY, y + coverageWidth];
                    end
                end
            end
            exitX = entryExitPoints{i}.exit(1);
            exitY = entryExitPoints{i}.exit(2);
            pathX(end+1) = exitX;
            pathY(end+1) = exitY;
        end
        paths{i} = struct('subregionId', regions{i}.id, 'x', pathX, 'y', pathY, 'type', 'working');
    end
    
    connectPaths = cell(1, length(paths)-1);
    for i = 1:length(paths)-1
        currentExitX = paths{i}.x(end);
        currentExitY = paths{i}.y(end);
        nextEntryX = paths{i+1}.x(1);
        nextEntryY = paths{i+1}.y(1);
        connectX = [currentExitX, nextEntryX];
        connectY = [currentExitY, nextEntryY];
        connectPaths{i} = struct('subregionId', -i, 'x', connectX, 'y', connectY, 'type', 'non-working');
    end
    
    allPaths = cell(1, 2*length(paths)-1);
    for i = 1:length(paths)
        allPaths{2*i-1} = paths{i};
        if i < length(paths)
            allPaths{2*i} = connectPaths{i};
        end
    end
    
    if params.returnToStart && ~isempty(allPaths)
        lastPath = allPaths{end};
        lastX = lastPath.x(end);
        lastY = lastPath.y(end);
        returnX = [lastX, 0];
        returnY = [lastY, 0];
        allPaths{end+1} = struct('subregionId', 0, 'x', returnX, 'y', returnY, 'type', 'non-working');
    end
    paths = allPaths;
end

%% 计算性能指标
function metrics = calculateMetrics(paths)
    global params obstacles subregions;
    
    totalDistance = 0;
    workingDistance = 0;
    totalTurns = 0;
    workingTurns = 0;
    
    for i = 1:length(paths)
        pathX = paths{i}.x;
        pathY = paths{i}.y;
        for j = 2:length(pathX)
            dx = pathX(j) - pathX(j-1);
            dy = pathY(j) - pathY(j-1);
            segmentLength = sqrt(dx^2 + dy^2);
            totalDistance = totalDistance + segmentLength;
            if strcmp(paths{i}.type, 'working')
                workingDistance = workingDistance + segmentLength;
            end
            if j > 2
                prevDx = pathX(j-1) - pathX(j-2);
                prevDy = pathY(j-1) - pathY(j-2);
                dot = dx * prevDx + dy * prevDy;
                mag1 = sqrt(dx^2 + dy^2);
                mag2 = sqrt(prevDx^2 + prevDy^2);
                if mag1 > 0 && mag2 > 0
                    cosAngle = dot / (mag1 * mag2);
                    cosAngle = min(1, max(-1, cosAngle));
                    angle = acos(cosAngle) * 180 / pi;
                    if abs(angle - 90) < 5
                        totalTurns = totalTurns + 1;
                        if strcmp(paths{i}.type, 'working')
                            workingTurns = workingTurns + 1;
                        end
                    end
                end
            end
        end
    end
    
    fieldArea = params.fieldLength * params.fieldWidth;
    obstacleArea = 0;
    for i = 1:params.numObstacles
        if ~isempty(obstacles) && ~isempty(obstacles{i})
            try
                obstacleArea = obstacleArea + polyarea(obstacles{i}.x, obstacles{i}.y);
            catch
                warning('无法计算障碍物 %d 的面积，使用近似值', i);
                k = convhull(obstacles{i}.x, obstacles{i}.y);
                obstacleArea = obstacleArea + polyarea(obstacles{i}.x(k), obstacles{i}.y(k));
            end
        end
    end
    effectiveArea = fieldArea - obstacleArea;
    coveredArea = workingDistance * params.coverageWidth;
    coverageRate = min(100, (coveredArea / effectiveArea) * 100);
    overlapRate = max(0, (coveredArea - effectiveArea) / effectiveArea * 100);
    missRate = max(0, 100 - coverageRate);
    workingTime = workingDistance / params.flightSpeed;
    totalTime = totalDistance / params.flightSpeed;
    
    metrics = struct();
    metrics.totalDistance = totalDistance;
    metrics.workingDistance = workingDistance;
    metrics.totalTurns = totalTurns;
    metrics.workingTurns = workingTurns;
    metrics.coverageRate = coverageRate;
    metrics.overlapRate = overlapRate;
    metrics.missRate = missRate;
    metrics.workingTime = workingTime;
    metrics.totalTime = totalTime;
    metrics.numSubregions = length(subregions);
end

%% 打印结果
function printResults()
    global params obstacles subregions entryExitPoints metrics;
    
    fprintf('\n===== 农田信息 =====\n');
    fprintf('农田长度: %.2f 米\n', params.fieldLength);
    fprintf('农田宽度: %.2f 米\n', params.fieldWidth);
    fprintf('农田面积: %.2f 平方米\n', params.fieldLength * params.fieldWidth);
    
    fprintf('\n===== 障碍物信息 =====\n');
    fprintf('障碍物数量: %d\n', params.numObstacles);
    for i = 1:params.numObstacles
        if ~isempty(obstacles) && ~isempty(obstacles{i})
            fprintf('障碍物 %d:\n', i);
            fprintf('  类型: %s\n', obstacles{i}.type);
            fprintf('  高度: %.2f 米\n', obstacles{i}.height);
            area = polyarea(obstacles{i}.x, obstacles{i}.y);
            fprintf('  面积: %.2f 平方米\n', area);
            centerX = mean(obstacles{i}.x);
            centerY = mean(obstacles{i}.y);
            fprintf('  中心位置: (%.2f, %.2f)\n', centerX, centerY);
        end
    end
    
    fprintf('\n===== 无人机参数 =====\n');
    fprintf('覆盖宽度: %.2f 米\n', params.coverageWidth);
    fprintf('飞行速度: %.2f 米/秒\n', params.flightSpeed);
    fprintf('飞行高度: %.2f 米\n', params.flightHeight);
    fprintf('水平安全距离: %.2f 米\n', params.horizontalSafetyDistance);
    fprintf('垂直安全距离: %.2f 米\n', params.verticalSafetyDistance);
    fprintf('转弯半径: %.2f 米\n', params.turningRadius);
    fprintf('返回起点: %s\n', iif(params.returnToStart, '是', '否'));
    
    fprintf('\n===== 子区域遍历顺序与出入点 =====\n');
    fprintf('子区域总数: %d\n', length(subregions));
    fprintf('最佳无人机遍历顺序: ');
    for i = 1:length(subregions)
        if i > 1
            fprintf(' -> ');
        end
        fprintf('S%d', i);
    end
    fprintf('\n\n');
    for i = 1:length(subregions)
        fprintf('子区域 S%d:\n', i);
        fprintf('  入口点: (%.2f, %.2f)\n', entryExitPoints{i}.entry(1), entryExitPoints{i}.entry(2));
        fprintf('  出口点: (%.2f, %.2f)\n', entryExitPoints{i}.exit(1), entryExitPoints{i}.exit(2));
        area = polyarea(subregions{i}.x, subregions{i}.y);
        fprintf('  面积: %.2f 平方米\n', area);
    end
    
    fprintf('\n===== 路径规划结果 =====\n');
    fprintf('覆盖率: %.2f%%\n', metrics.coverageRate);
    fprintf('重叠率: %.2f%%\n', metrics.overlapRate);
    fprintf('遗漏率: %.2f%%\n', metrics.missRate);
    fprintf('\n路径长度:\n');
    fprintf('  工作路径长度: %.2f 米\n', metrics.workingDistance);
    fprintf('  总路径长度: %.2f 米\n', metrics.totalDistance);
    fprintf('  非工作路径长度: %.2f 米\n', metrics.totalDistance - metrics.workingDistance);
    fprintf('\n转弯次数:\n');
    fprintf('  工作转弯次数: %d\n', metrics.workingTurns);
    fprintf('  总转弯次数: %d\n', metrics.totalTurns);
    fprintf('  非工作转弯次数: %d\n', metrics.totalTurns - metrics.workingTurns);
    fprintf('\n作业时间:\n');
    fprintf('  工作时间: %.2f 秒\n', metrics.workingTime);
    fprintf('  总作业时间: %.2f 秒\n', metrics.totalTime);
    fprintf('  非工作时间: %.2f 秒\n', metrics.totalTime - metrics.workingTime);
    fprintf('\n===== ACO算法参数 =====\n');
    fprintf('蚂蚁数量: %d\n', params.aco.antCount);
    fprintf('迭代次数: %d\n', params.aco.iterations);
    fprintf('信息素重要程度 (alpha): %.2f\n', params.aco.alpha);
    fprintf('启发式因子重要程度 (beta): %.2f\n', params.aco.beta);
    fprintf('信息素蒸发率 (rho): %.2f\n', params.aco.rho);
    fprintf('状态转移规则参数 (q0): %.2f\n', params.aco.q0);
    fprintf('初始信息素浓度: %.2f\n', params.aco.initialPheromone);
    fprintf('==============================\n\n');
end

%% 辅助函数 - 条件表达式
function result = iif(condition, trueVal, falseVal)
    if condition
        result = trueVal;
    else
        result = falseVal;
    end
end