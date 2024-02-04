clear all, close all

addpath(genpath('../drifter'))
data_drive = '/Volumes/Shared/ONR_DRIFTER/';

% select the drifter number and the time you want to load 
drifter_num = 4;
time_utc = [datetime(2023,10,9,18,20,20) datetime(2023,10,10,12,50,00)];

% fyi - these functions to load in the IMU and driftlog will run faster if you
% point them directly to the deployment folder, rather than the base data directory.

%% load IMU data
imu = loadIMUDataV2(time_utc,data_drive,drifter_num);

%% load driftcam log
[driftcam,control_label] = loadDrifterLogDataV2(time_utc,data_drive,drifter_num);

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

