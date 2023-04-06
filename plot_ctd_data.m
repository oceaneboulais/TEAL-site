% plot CTD data
close all, clear all
do_plots = true;
addpath(genpath('C:\Users\alaferri\OneDrive - Raytheon\SIO\sio_code\sio_research'))

datadrive = 'E:\Sep_2022';

filelist = {
    '1st_Deployment\aml_log_2022-09-14_18-15-06.aml'
    '2nd_Deployment\aml_log_2022-09-15_13-11-46.aml'
    '3rd_Deployment\aml_log_2022-09-18_01-41-59.aml'
    '4th_Deployment\aml_log_2022-09-18_21-13-05.aml'
    '5th_Deployment\aml_log_2022-09-19_19-31-46.aml'
    };

savefolder = fullfile(pwd,'CTD_Data');

for fileidx = 1:length(filelist)
    filename = fullfile(datadrive,filelist{fileidx});

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
        xlim([9 25])

        subplot(1,4,2)
        plot(salinity,-depth,'.-','linewidth',2)
        xlabel('Salinity')
        ylabel('Depth (m)')
        grid on
        legend('CT','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([30 40])

        subplot(1,4,3)
        plot(density,-depth,'.-','linewidth',2)
        xlabel('Density (kg/m^3)')
        ylabel('Depth (m)')
        grid on
        legend('CT','SVT')
        set(gca,'FontSize',14,'FontWeight','bold')
        xlim([1020 1029])

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


        f2 = figure; clf
        plot(X.Columns_Date + X.Time,-depth,'.')
        xlabel('Time')
        ylabel('Depth, m')
        title(sprintf('Max Depth %1.2f',max(depth)))
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


end