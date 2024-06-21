%%%%%%%compare_imu_and_usbl.m%%%%%
%  Compare two orientation data streams from ONR opto-acoustic drifter.
%  Alison Laferriere (with notes by Aaron Thode)
clear all, close all

print_results=true;

addpath(genpath('../drifter'))


% select the drifter number and the time you want to load
drifter_num_all = 7 %5:5;
time_utc = [datetime(2023,10,9,18,20,20) datetime(2023,10,10,12,50,00)];
%time_utc = [datetime(2023,10,11,15,20,20) datetime(2023,10,13,18,0,00)];

% fyi - if you just give these functions the base data drive they will find
% the log files, but they will run much faster if you
% point them directly to the deployment folder's subdirectory, rather than the base data directory.
% data_drive = '/Volumes/Shared/ONR_DRIFTER/';
%

for Inum=1:length(drifter_num_all)
    drifter_num=drifter_num_all(Inum);
    switch drifter_num
        case 4
            data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter4_Acoustic1_20231009T021100_20231011T112900';
            %data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter4_Acoustic1_20231012T183000_20231013T170000';
            time_offset=duration(0,6,21-53+23);
            yaw_offset=+232-9;
        case 5
            data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231009T182000_20231010T125000';
            %data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231011T153600_20231013T182600';
            time_offset=duration(0,6,21-53+23);
            yaw_offset=+232-9;
        case 6
            time_offset=duration(0,6,21-53+23);
            yaw_offset=+232-9;
            data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter6_Acoustic4_20231009T020700_20231011T134500';
            %data_drive = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter6_Acoustic4_20231012T183500_20231013T170000';

        case 7 
            data_drive = '/Volumes/Shared/ONR_DRIFTER/2024_Jan_CA/Drifter5_Acoustic3_20240126T201400_20240129T214500';
            yaw_offset = 0;
            time_offset = 0;
            drifter_num = 5;
            time_utc = [datetime(2024,1,26,20,14,0) datetime(2024,1,29,21,45,00)];
    end
    %% load IMU data
    disp('loading IMU data');
    imu = loadIMUDataV2(time_utc,fullfile(data_drive,'IMU'),drifter_num);

    %% load driftcam log
    disp('loading USBL data');
    [driftcam,control_label] = loadDrifterLogDataV2(time_utc,fullfile(data_drive,'ControlSystem'),drifter_num);

    %% plot both
    figure
    ax(1)=subplot(4,1,1);
    plot(driftcam.time_utc,driftcam.control_state,'o');grid on
    ylabel('Control State');
    title(data_drive,'Interpreter','none')

    ax(2)=subplot(4,1,2);
    plot(imu.time_utc,imu.yaw_deg,'.-')
    hold on
    plot(driftcam.time_utc-time_offset,wrapTo180(driftcam.yaw_deg+yaw_offset),'.-');
    grid on
    %ylim([-180 180])
    ylabel('Yaw, deg')
    legend('IMU','USBL')
    %imu_yaw_interp=interp1(imu.time_utc,imu.yaw_deg,driftcam.time_utc);

    ax(3)=subplot(4,1,3);
    plot(imu.time_utc,imu.pitch_deg,'.-')
    hold on
    plot(driftcam.time_utc-time_offset,driftcam.pitch_deg,'.-')
    grid on
    ylim([-30 30])
    ylabel('Pitch, deg')
    legend('IMU','USBL')

    ax(4)=subplot(4,1,4);
    plot(imu.time_utc,imu.roll_deg,'.-')
    hold on
    plot(driftcam.time_utc-time_offset,driftcam.roll_deg,'.-')
    grid on
    ylim([-30 30])
    ylabel('Roll, deg')
    legend('IMU','USBL')

    linkaxes(ax,'x');

    if print_results
        [a,print_name]=fileparts(data_drive);
        orient landscape
        set(gcf,'Position',[ 73          60        1792        1068])
        print('-djpeg','-r300',sprintf('%s.jpg',print_name));
        saveas(gcf,sprintf('%s.fig',print_name),'fig');
    end
end
