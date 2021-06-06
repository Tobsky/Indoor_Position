function [pdrtime, StepLength, StepVelocity, bandPass,PositionX,PositionY] = IS_stepcount_PDR(cellresult) %cellresult


%% Load data

filename='FSD_Floorplan.xls'; % FSD floorplan
loc_data_range = 'A2:B127';
nodesP = xlsread(filename,loc_data_range);

% Sample FSD sensor readings

% load('fsd_acc_data.mat')
% load('fsd_fusedOrientation_data.mat')
% load('fsd_timestamp.mat')

% load('fsd_acc_data3.mat') % straight line walking
% load('fsd_fusedOrientation_data3.mat')
% load('fsd_timestamp3.mat')

load('fsd_acc_data7.mat')
load('fsd_fusedOrientation_data7.mat')
load('fsd_timestamp7.mat')


%% Data from Sensor fusion app
% T = 'New_app_Orientatn_data.xlsx';
% T = readtable(T);
% data = T(:,3:6);
% data2=table2array(data);
% 
% [fusedOrientation] = convert_quat2euler(data2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialise data

accl = Acc;
gyro_data = fusedOrientation; %fusedOrientation'
PDRtimestamp = timestamp;

% for i = 1:length(accl2) % Convert accelerometer data to 3 columns
% accl(i,:) = cell2mat(accl2(1,i));
% end


%% preprocessing
yaw = gyro_data(:,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% From 0-360 deg
% yaw = rad2deg(yaw);
% zoneA = find(yaw>=0 & yaw< 90); % 90
% zoneB = find(yaw>=90 & yaw< 180); % 180
% zoneC = find(yaw>= 180 & yaw< 270); % 270
% zoneD = find(yaw>= 270 & yaw< 360); % 360
% % range of sin -->(-90,+90)
% % range of cos -->(0,+180)
% yaw(zoneA,2:3) = [yaw(zoneA,1) yaw(zoneA,1)];
% yaw(zoneB,2:3) = [180-yaw(zoneB,1) yaw(zoneB,1)]; % 180
% yaw(zoneC,2:3) = [180-yaw(zoneC,1) 360-yaw(zoneC,1)]; % 360
% yaw(zoneD,2:3) = [yaw(zoneD,1)-360 360-yaw(zoneD,1)]; % 360

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% From -180 to 180
zoneA = find(yaw>=-180 & yaw< -90); % 90
zoneB = find(yaw>=-90 & yaw< 0); % 180
zoneC = find(yaw>= 0 & yaw< 90); % 270
zoneD = find(yaw>= 90 & yaw< 180); % 360

yaw(zoneA,2:3) = [yaw(zoneA,1) yaw(zoneA,1)];
yaw(zoneB,2:3) = [0-yaw(zoneB,1) yaw(zoneB,1)]; % 180
yaw(zoneC,2:3) = [0-yaw(zoneC,1) 180-yaw(zoneC,1)]; % 360
yaw(zoneD,2:3) = [yaw(zoneD,1)-180 180-yaw(zoneD,1)]; % 360

% pre_process acceleromrter values
acc = sqrt(accl(:,1).^2 + accl(:,2).^2 + accl(:,3).^2);
acc = acc-mean(acc); % remove gravity

%% BANDPASS FILTER
fs=100;
f1=0.75;               % cuttoff low frequency to get rid of baseline wander
f2=2.75;                 % cuttoff frequency to discard high frequency noise
Wn=[f1 f2]/(fs/2);    % cutt off frequency based on fs
N = 4;                % order of 3 less processing

[a,b] = butter(N,Wn); % bandpass filtering
bandPass = filtfilt(a,b,acc);
% bandPass = bandPass/ max(abs(bandPass));

%% find peaks

% Find signal peaks - peaks under a threshold value are considered as noise.
[PkValue, PeakLocation] = findpeaks(bandPass, 'MINPEAKHEIGHT',0.17 );  %0.15

% Plot peaks
time = 1:length(acc);
time = time/50; % 50 times per second (60Hz)

figure(2)
plot(time,bandPass,'LineWidth',1)
xlabel('timestamp (s)')
ylabel('Peaks (m/s^2)')
title('Detect peak/step count')
hold on
plot(PeakLocation/50,PkValue,'k^','LineWidth',1)
%% time interval (steps between 0.4s and 2s)

PkValue(:,2) = PDRtimestamp(PeakLocation,1);
PkValue(2:end,2) = PkValue(2:end,2)-PkValue(1:end-1,2); % difference in time (time interval)
index = find(PkValue(:,2)<400); % Check if the time interval is less than 0.4sec
if isempty(index) == 0
    pos_del = [];
    for k = 1:length(index)
        temp = index(k); % position of the suspicious samples
        if PkValue(temp,1) <= PkValue(temp-1,1)
            pos_del = [pos_del; temp];
        else
            pos_del = [pos_del; temp-1];
        end
    end
    PeakLocation(pos_del) = [];
    PkValue(pos_del,:) = [];
end
StepCount = length(PeakLocation); % step number
fprintf('step count is %.2f \n', StepCount);

%% position update

PositionX = zeros(StepCount, 1);
PositionY = zeros(StepCount, 1);
distance = 0;
StepLength = zeros(StepCount, 1);
StepVelocity = zeros(StepCount, 1);
for k = 1:StepCount-1
    pos_start = PeakLocation(k); % peak location index
    pos_end = PeakLocation(k+1); % next peak location index
    % orientation (yaw)
    YawSin = mean(yaw(pos_start:pos_end,2));%2
    YawCos = mean(yaw(pos_start:pos_end,3));%3
    % step length estimation
    % SL = 0.2844 + 0.2231*frequency + 0.0426*AV
    StepFreq(k) = 1000/PkValue(k+1,2); % 1000/PkValue time
    StepAV(k) = var(acc(pos_start:pos_end));
    StepLength(k) = 0.2844 + 0.2231*StepFreq(k) + 0.0426*StepAV(k);
    StepVelocity(k) = StepLength(k)*StepFreq(k);
    distance = distance + StepLength(k);
    
    % position update
    
    PositionX(1) = cellresult(1,1); % initial input from cellular
    PositionY(1) = cellresult(1,2);
    
    PositionX(k+1) = PositionX(k) + StepLength(k) * cos((YawCos)); %deg2rad
    PositionY(k+1) = PositionY(k) + StepLength(k) * sin((YawSin)); %deg2rad
end

fprintf('walking distance is %.2f m \n', distance);
%pdrtime = PDRtimestamp(PeakLocation,1);
pdrtime = (1:length(PeakLocation));
% fprintf('Step count is %d. \n', StepCount);
% fprintf('Step velocity is %d. \n', StepVelocity);

%% figures

figure(3)
plot(time,acc,'LineWidth',0.5)
xlabel('timestamp (s)')
ylabel('Filtered and unfiltered reading')
title('Bandpass filter')
hold on
plot(time,bandPass,'LineWidth',1)

figure(4)

% For straight walk
ideal_locX(:,1) = 0:63;
ideal_locX(:,2) = 4*ones(64,1);
% For rectangular walk
ideal_locY = 63:-1:0;
ideal_locY = ideal_locY';
ideal_locY(:,2) = 3.5*ones(64,1);

ideal_loc = [ideal_locX;ideal_locY];
% scatter(PositionX,PositionY,25,'filled'); grid on; % north-up
plot(PositionX,PositionY,'-ko','MarkerFaceColor',[0,0,0]); grid on;
xlabel('MEMS Trajectory X (m)');
ylabel('MEMS Trajectory Y (m)');
hold on
% scatter(ideal_loc(:,1),ideal_loc(:,2),15,'filled');
plot(ideal_loc(:,1),ideal_loc(:,2),'-bo','MarkerFaceColor',[0,0,1]);
legend('MEMS estimated trajectory (m)', 'Reference trajectory (m)');
ylim([0 10])


PDR_error = sqrt((ideal_loc(:,1) - PositionX(:,1)).^2 + (ideal_loc(:,2) - PositionY(:,2)).^2);
error_avg = mean(PDR_error);
error_std = std(PDR_error);
error_min = min(PDR_error);
error_max = max(PDR_error);
PDR_error_2 = [error_avg, error_std, error_min, error_max];

% xlswrite('PDR_error_1.xls',PDR_error_2)

end