% Author: Tsai Syun
% Update: 2020.10.28
data = [];
%% Load Data
path = 'C:\DATA\NLSC_20201005-7\20201006A\';
% data{1} = load([path '20201006B_IMU.txt']);
% data{2} = load([path '20201006B_IMU_imu.txt']);
data{1} = load([path '20201006A_R1_SNR_30_GivenLLH_NEU.txt']);
data{2} = load([path '20201006_A_RQH_NLSCgps_TC_toNLSCimu.txt']);
data{1} = data{1}(:, 1:7);
data{2} = data{2}(:, 1:7);


%% Find Data Frequency
fs{1} = round(length(data{1})/(data{1}(end,1) - data{1}(1,1)));
fs{2} = round(length(data{2})/(data{2}(end,1) - data{2}(1,1)));

%% Interpolation According to Low fs Data
if fs{1} < fs{2}
    lFsId = 1;
    hFsId = 2;
else
    lFsId = 2;
    hFsId = 1;    
end
[row, col] = size(data{lFsId}(:, 2:end));
% Check Time Coverage
t_start = data{hFsId}(1,1);
t_end = data{hFsId}(end,1);
data{lFsId} = data{lFsId}(find((data{lFsId}(:,1) > t_start) & (data{lFsId}(:,1) < t_end)),:);

% Smooth data
data{lFsId}(:, 2:end) = smoothdata(data{lFsId}(:, 2:end), 1, 'movmean', fs{lFsId}*0.2);
data{hFsId}(:, 2:end) = smoothdata(data{hFsId}(:, 2:end), 1, 'movmean', fs{hFsId}*0.2);

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
fprintf('STD Ratio & Correlation:\n')
for i = 1:col
    ratio = std(data{1}(:,i+1))/std(data{2}(:,I(i)+1));
    fprintf(['\tData1-' num2str(i) ' / ' 'Data2-' num2str(I(i)) ': %.4f\t%.4f\n'], ratio, cVal(i, col+I(i)))
end
fprintf(['\nReference constant:\n'...
    '\trad/deg %f\n'...
    '\tdeg/rad %f\n'...
    '\t1/Fs2 %f\n'...
    '\t1/Fs1 %f\n'],...
    RadpDeg, 1/RadpDeg, 1/fs{2}, 1/fs{1})