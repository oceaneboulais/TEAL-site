% plot CTD data
close all, clear all
do_plots = true;
addpath(genpath('/Users/alaferri/GIT/sio_research'))

use_remote_path = true;

[data_basedir,procdata_basedir,gitpath] = setUpDrifterPaths(use_remote_path,1);

expt = '2023_Fall_Kelvin_Seamount';
drifter_num = 5;

plot_times_utc = [];% 
plot_times_utc = [datetime(2023,10,09,19,24,35) datetime(2023,10,09,20,02,0)];
plot_times_utc = [datetime(2023,10,09,19,24,35) datetime(2023,10,15,20,02,0)];

lat = 38.826843; % need to provide the latitude to convert depth to pressure

if isempty(drifter_num)
    filelist = dir(fullfile(data_basedir,expt,'*','CTD','*.aml'));
else
    filelist = dir(fullfile(data_basedir,expt,sprintf('Drifter%i*',drifter_num),'CTD','*.aml'));
end



ctd = [];
for fileidx = 1:length(filelist)

    filename = fullfile(filelist(fileidx).folder,filelist(fileidx).name);

    ctd_tmp = readCTD(filename,lat);
    ctd = vertcat(ctd,ctd_tmp);
end


%%
if ~isempty(plot_times_utc)
    tidx = find(ctd.Time_UTC >= plot_times_utc(1) & ctd.Time_UTC <= plot_times_utc(2)) ;
else
    tidx = true(height(ctd),1);
end
f1 = figure; clf;
subplot(1,4,1)
plot(ctd.TempCT(tidx),-ctd.Depth(tidx),'.k','linewidth',2)
xlabel('Temp (deg C)')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([0 25])
ylim([-max(ctd.Depth(tidx)) 0])

subplot(1,4,2)
plot(ctd.SalinityCT(tidx),-ctd.Depth(tidx),'.k','linewidth',2)
xlabel('Salinity')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([30 40])
ylim([-max(ctd.Depth(tidx)) 0])

subplot(1,4,3)
plot(ctd.DensityCT(tidx),-ctd.Depth(tidx),'.k','linewidth',2)
xlabel('Density (kg/m^3)')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([1020 1035])
ylim([-max(ctd.Depth(tidx)) 0])

subplot(1,4,4)
plot(ctd.SoundSpeedCT(tidx),-ctd.Depth(tidx),'.k','linewidth',2)
xlabel('Sound Speed (m/s)')
ylabel('Depth (m)')
grid on
legend('CT-derived','SVT-derived','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([1460 1550])
ylim([-max(ctd.Depth(tidx)) 0])

%%
f2 = figure; clf
ax(1) = subplot(4,1,1);
plot(ctd.Time_UTC,-ctd.Depth,'.');
xlabel('Time')
ylabel('Depth, m')
grid on; grid minor
set(gca,'XTickLabelRotation',90)
xticks(ctd.Time_UTC(1):hours(2):ctd.Time_UTC(end))
xtickformat('HH:mm:ss')
set(gca,'fontweight','bold','fontsize',10);

ax(2)=subplot(4,1,2);
plot(ctd.Time_UTC,-ctd.TempCT,'.');
xlabel('Time')
ylabel('Temperature, deg C')
grid on; grid minor
set(gca,'XTickLabelRotation',90)
xticks(ctd.Time_UTC(1):hours(2):ctd.Time_UTC(end))
xtickformat('HH:mm:ss')
set(gca,'fontweight','bold','fontsize',10);

ax(3)=subplot(4,1,3);
plot(ctd.Time_UTC,-ctd.SalinityCT,'.');
xlabel('Time')
ylabel('Salinity, psu')
grid on; grid minor
set(gca,'XTickLabelRotation',90)
xticks(ctd.Time_UTC(1):hours(2):ctd.Time_UTC(end))
xtickformat('HH:mm:ss')
set(gca,'fontweight','bold','fontsize',10);

ax(4)=subplot(4,1,4);
plot(ctd.Time_UTC,-ctd.DensityCT,'.');
xlabel('Time')
ylabel('Density')
grid on; grid minor
set(gca,'XTickLabelRotation',90)
xticks(ctd.Time_UTC(1):hours(2):ctd.Time_UTC(end))
xtickformat('HH:mm:ss')
set(gca,'fontweight','bold','fontsize',10);

linkaxes(ax,'x')

