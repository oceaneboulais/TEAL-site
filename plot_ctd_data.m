% plot CTD data
close all, clear all
do_plots = true;
addpath(genpath('C:\Users\alaferri\OneDrive - Raytheon\SIO\sio_code\sio_research'))
datadrive = 'E:\';
expt = 'Sep_2022';

switch expt
    case 'Sep_2022'
        filelist = {
            '1st_Deployment\aml_log_2022-09-14_18-15-06.aml'
            '2nd_Deployment\aml_log_2022-09-15_13-11-46.aml'
            '3rd_Deployment\aml_log_2022-09-18_01-41-59.aml'
            '4th_Deployment\aml_log_2022-09-18_21-13-05.aml'
            '5th_Deployment\aml_log_2022-09-19_19-31-46.aml'
            };
         savefolder = fullfile('H:\My Drive\SIO_DATA\Drifter\TFO_Cruise_092022\Test_Info','CTD_Data');
        
    case 'Feb_2023'
        filelist = {
            '\Acoustic1_Feb28\aml_log_2023-02-26_20-46-39.aml'
            '\Acoustic3_Feb28\aml_log_2023-02-26_20-36-03.aml'
            '\Acoustic3_Feb28\aml_log_2023-02-27_17-41-06.aml'
            '\Acoustic4_Feb28\aml_log_2023-02-28_16-52-24.aml'
            '\Deployment1_Feb21\aml_log_2023-02-21_18-42-54.aml'
            };
       savefolder = fullfile('H:\My Drive\SIO_DATA\Drifter\Feb2023_Cruise','CTD_Data');
end



for fileidx = 1:length(filelist)
    filename = fullfile(datadrive,expt,filelist{fileidx});

    X = readtable(filename,'NumHeaderLines',117,'FileType','delimitedtext','VariableNamesLine',114,'VariableUnitsLine',115);

    lat = degminsec2deg(38,54.58,0);
    % get conductivity ratio, conductivity in units mS/cm
    CR = X.Cond/sw_c3515;
    pressure = X.Pressure; % pressure in dBar
    temp = [X.TempCT X.TempSVT]; % temp in C
    salinity = sw_salt(CR,temp,pressure);
    depth = sw_dpth(pressure,lat);
    sound_speed = sw_svel(salinity,temp,pressure);
    sound_speed = [sound_speed X.SV];
    density = sw_dens(salinity,temp,pressure);

    if do_plots
        f1 = figure; clf;
        subplot(1,4,1)
        plot(temp,-depth,'.-','linewidth',2)
        xlabel('Temp (deg C)')
        ylabel('Depth (m)')
        grid on
        legend('CT','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([8 25])
        ylim([-max(depth) 0])

        subplot(1,4,2)
        plot(salinity,-depth,'.-','linewidth',2)
        xlabel('Salinity')
        ylabel('Depth (m)')
        grid on
        legend('CT','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([30 40])
        ylim([-max(depth) 0])

        subplot(1,4,3)
        plot(density,-depth,'.-','linewidth',2)
        xlabel('Density (kg/m^3)')
        ylabel('Depth (m)')
        grid on
        legend('CT','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([1020 1029])
        ylim([-max(depth) 0])

        subplot(1,4,4)
        plot(sound_speed,-depth,'.-','linewidth',2)
%         hold on
%         plot(X.SV,-depth,'.-','linewidth',2)
        xlabel('Sound Speed (m/s)')
        ylabel('Depth (m)')
        grid on
        legend('CT-derived','SVT-derived','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([1480 1550])
        ylim([-max(depth) 0])
        
        sgtitle(filelist{fileidx},'interpreter','none')

        timevec = datetime(X.Columns_Date + X.Time,'format','yyyy-MM-dd HH:mm:ss');
        f2 = figure; clf
        plot(timevec,-depth,'.')
        xlabel('Time')
        ylabel('Depth, m')
        grid on; grid minor
        set(gca,'XTickLabelRotation',90)
        xticks(timevec(1):hours(2):timevec(end))
        xtickformat('HH:mm:ss')
        set(gca,'fontweight','bold','fontsize',10);
        title({filelist{fileidx},sprintf('Max Depth %1.2f',max(depth))},'interpreter','none')
        
    end

    if ~isfolder(savefolder)
        mkdir(savefolder)
    end
    [filepath,name,ext] = fileparts(filename);
    copyfile(filename,fullfile(savefolder,[name ext]));
    set(f1,'WindowState','maximize')
    saveas(f1,fullfile(savefolder,name),'png')
    saveas(f1,fullfile(savefolder,name),'fig')
    save(fullfile(savefolder,name),'depth','salinity','temp','density','sound_speed','pressure')

    saveas(f2,fullfile(savefolder,[name '_depth_vs_time']),'png')
    saveas(f2,fullfile(savefolder,[name '_depth_vs_time']),'fig')

end