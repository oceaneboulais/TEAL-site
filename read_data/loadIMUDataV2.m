function imu = loadIMUDataV2(time_utc_in,datadrive,drifter_num)

% if the time zone property is empty, we will assume it is in UTC time
if isempty(time_utc_in.TimeZone)
    time_utc_in.TimeZone = 'UTC';
end

% find the IMU files
[~,D] = fileparts(datadrive);
if ~strcmp(D,'IMU')
    imu_files = dir(fullfile(datadrive,'**',sprintf('Drifter%i*',drifter_num),'IMU','*.mtb.mat'));
else
    % if you provide the directory of the IMU files directly, this function
    % will be faster..
    log_filelist = dir(fullfile(datadrive,'*.mtb.mat'));
end

% note that the IMU filenames are saved in WHATEVER TIME ZONE THE ACOUSTIC
% COMPUTER IS SET TO.  As of now (2/3/2024) this has been in PACIFIC TIME
% which is either UTC-7 or UTC-8 depending on if we are in Daylight Savings
% Time or not
% we will probably change this to UTC in the future, and this function will
% need to be updated.

file_names = vertcat(imu_files.name);
file_times = datetime(file_names(:,9:27),'Inputformat','dd_MM_yyyy_HH_mm_SS',...
    'TimeZone','America/Los_Angeles'); 

% convert to UTC
file_times.TimeZone = 'UTC';

% if time_utc_in is a 1x2 vector, these are interpreted as the limits of
% the times to get and the result is given in the native sampling times of the 
% IMU, if it is a longer vector or a 2x1 vector, it is
% interpreted as the times you would like to interpolate to

% get the files that are in this time range
include_files = file_times >= min(time_utc_in) & file_times <= max(time_utc_in);

imu_files = imu_files(include_files);
file_names = file_names(include_files);
file_times = file_times(include_files);


imu_time = [];
imu_pitch = [];
imu_yaw = [];
imu_roll = [];
for ii = 1:length(imu_files)
    imudata = load(fullfile(imu_files(ii).folder,imu_files(ii).name));
    imu_sec = (imudata.TimeFine - imudata.TimeFine(1))/1e4;
    this_time = file_times(ii) + seconds(imu_sec);
    imu_time = cat(1,imu_time,this_time);
    imu_pitch = cat(1,imu_pitch,imudata.euler(:,2));
    imu_yaw = cat(1,imu_yaw,imudata.euler(:,3));
    imu_roll = cat(1,imu_roll,imudata.euler(:,1));
end

time_utc = imu_time;
time_utc.TimeZone = ''; % remove time zone info, this can cause issues in a lot of the other code
yaw_deg = wrapTo180(90-imu_yaw);
pitch_deg = imu_pitch;
roll_deg = imu_roll;
imu = table(time_utc,yaw_deg,roll_deg,pitch_deg);

end

% end



function t = convertLogTime(filelist)

t=datetime(filelist(end-16:end-11),'InputFormat','yyMMdd');

end