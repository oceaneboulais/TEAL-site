clear all, close all

addpath(genpath('H:\My Drive\GIT\sio_research'))
addpath('H:\My Drive\SIO_DATA\Databases')

% datadrive = 'E:\';
datadrive = 'E:\Sep_2022'
%% load IMU data
imu_filelist =  {
    fullfile(datadrive,'1st_Deployment\*.mtb.mat');
    fullfile(datadrive,'2nd_Deployment\*.mtb.mat');
    fullfile(datadrive,'3rd_Deployment\*.mtb.mat');
    fullfile(datadrive,'4th_Deployment\*.mtb.mat');
    fullfile(datadrive,'5th_Deployment\*.mtb.mat');
    };
   
idx = 5;

imu_files = dir(imu_filelist{idx});
imu_time = [];
imu_pitch = [];
imu_yaw = [];
imu_roll = [];
for ii = 1:length(imu_files)
    imudata = load(fullfile(imu_files(ii).folder,imu_files(ii).name));
    imu_sec = (imudata.Time - imudata.Time(1))/1e4;
    this_time = datetime(imu_files(ii).name(9:27),'Inputformat','dd_MM_yyyy_HH_mm_SS') + seconds(imu_sec)+hours(7);
    imu_time = cat(1,imu_time,this_time);
    imu_pitch = cat(1,imu_pitch,imudata.euler(:,2));
    imu_yaw = cat(1,imu_yaw,imudata.euler(:,3));
    imu_roll = cat(1,imu_roll,imudata.euler(:,1));
end

%% load driftcam data and interp to gps time
ssr_file = dir(fullfile(datadrive,'220914 SSR TFO Cruise Data',sprintf('Deployment %i',idx),sprintf('* Dive %i.txt',idx)));
ssr_data = load_Driftcam_data_Ver3(fullfile(ssr_file.folder,ssr_file.name));

ssr_time = datetime(ssr_data.Timestamp,'ConvertFrom','posixtime');

%% plot both
figure
plot(imu_time,imu_yaw,'.')
hold on
plot(ssr_time,ssr_data.Yaw,'.')
grid on

imu_interp = interp1(imu_time,imu_yaw,ssr_time);
figure
plot(ssr_time,imu_interp,'-.')
hold on
plot(ssr_time,ssr_data.Yaw,'-.')
% figure
% plot(imu_time,imu_pitch,'.')
% hold on
% plot(ssr_time,ssr_data.Pitch,'.')
% 
% figure
% plot(ssr_time,-ssr_data.Depth)
