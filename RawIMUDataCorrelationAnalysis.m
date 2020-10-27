data = [];
%% Load Data
data{1} = load('IMUdata1.txt');
data{2} = load('IMUdata2.txt');

%% Find Data Frequency
fs1 = round(length(data{1})/(data{1}(end,1) - data{1}(1,1)));
fs2 = round(length(data{2})/(data{2}(end,1) - data{2}(1,1)));

%% Interpolation According to Low fs Data
if fs1 < fs2
    lFsId = 1;
    hFsId = 2;
else
    lFsId = 2;
    hFsId = 1;    
end
[row, col] = size(data{lFsId}(:, 2:end));
% Smooth data
data{lFsId}(:, 2:end) = smoothdata(data{lFsId}(:, 2:end), 1);
data{hFsId}(:, 2:end) = smoothdata(data{hFsId}(:, 2:end), 1);

dataMerged = [data{lFsId}(:, 2:end), ...
    interp1(data{hFsId}(:,1), data{hFsId}(:, 2:end), data{lFsId}(:, 1),...
    'linear')];

%% Plot Data Correlation
fig0 = figure;
[S,AX,BigAx,H,HAx] = plotmatrix(dataMerged);
cVal = corrcoef(dataMerged);

fig = figure;
for i = 1:col
    for j = 1:col
        subplot(col, col, i+col*(j-1))
        plot(get(S(i, col+j),'XData'), get(S(i, col+j),'YData'), '.', 'Color',...
            [1-abs(cVal(i, col+j)) 0 abs(cVal(i, col+j))])
    end
end
han=axes(fig,'visible','off'); 
han.Title.Visible='on';
han.XLabel.Visible='on';
han.YLabel.Visible='on';
ylabel(han,'Data 1');
xlabel(han,'Data 2');
title(han,'Raw Data Correlation Analysis');
close(fig0);

%% Print imformation
[M, I] = max(abs(cVal(1:6,7:12)));
RadpDeg = pi/180;
fprintf('STD Ratio:')
for i = 1:col
    ratio = std(data{1}(:,i+1))/std(data{2}(:,I(i)+1));
    fprintf(['\tData1-' num2str(i) ' / ' 'Data2-' num2str(I(i)) ': %f\n'], ratio)
end
fprintf(['\nReference constant:\n'...
    '\trad/deg %f\n'...
    '\tdeg/rad %f\n'],...
    RadpDeg, 1/RadpDeg)