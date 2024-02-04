clear all, close all

addpath(genpath('../drifter'))


% select the drifter number and the time you want to load 
drifter_num = 4;
time_utc = [datetime(2023,10,9,18,20,20) datetime(2023,10,10,12,50,00)];

% fyi - if you just give these functions the base data drive they will find 
% the log files, but they will run much faster if you
% point them directly to the deployment folder's subdirectory, rather than the base data directory.
% data_drive = '/Volumes/Shared/ONR_DRIFTER/';
data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter4_Acoustic1_20231009T021100_20231011T112900';

%% load IMU data
imu = loadIMUDataV2(time_utc,fullfile(data_drive,'IMU'),drifter_num);

%% load driftcam log
[driftcam,control_label] = loadDrifterLogDataV2(time_utc,fullfile(data_drive,'ControlSystem'),drifter_num);

%% plot both
figure
subplot(3,1,1)
plot(imu.time_utc,imu.yaw_deg,'.-')
hold on
plot(driftcam.time_utc,driftcam.yaw_deg,'.-')
grid on
ylim([-180 180])
ylabel('Yaw, deg')
legend('IMU','USBL')


subplot(3,1,2)
plot(imu.time_utc,imu.pitch_deg,'.-')
hold on
plot(driftcam.time_utc,driftcam.pitch_deg,'.-')
grid on
ylim([-90 90])
ylabel('Pitch, deg')
legend('IMU','USBL')

subplot(3,1,3)
plot(imu.time_utc,imu.roll_deg,'.-')
hold on
plot(driftcam.time_utc,driftcam.roll_deg,'.-')
grid on
ylim([-90 90])
ylabel('Roll, deg')
legend('IMU','USBL')

