% plot CTD data
close all, clear all
do_plots = true;
addpath(genpath('/Users/alaferri/GIT/sio_research'))

use_remote_path = true;

[data_basedir,procdata_basedir,gitpath] = setUpDrifterPaths(use_remote_path,1);

expt = '2024_Jan_CA';
drifter_num = 6;

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
figure
plot(ctd.Time_UTC,-ctd.Depth,'.','linewidth',2)

f1 = figure; clf;
subplot(1,4,1)
plot(ctd.TempCT,-ctd.Depth,'.k','linewidth',2)
xlabel('Temp (deg C)')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([0 25])
ylim([-max(ctd.Depth) 0])

subplot(1,4,2)
plot(ctd.SalinityCT,-ctd.Depth,'.k','linewidth',2)
xlabel('Salinity')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([30 40])
ylim([-max(ctd.Depth) 0])

subplot(1,4,3)
plot(ctd.DensityCT,-ctd.Depth,'.k','linewidth',2)
xlabel('Density (kg/m^3)')
ylabel('Depth (m)')
grid on
legend('CT','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([1020 1035])
ylim([-max(ctd.Depth) 0])

subplot(1,4,4)
plot(ctd.SoundSpeedCT,-ctd.Depth,'.k','linewidth',2)
xlabel('Sound Speed (m/s)')
ylabel('Depth (m)')
grid on
legend('CT-derived','SVT-derived','SVT')
set(gca,'FontSize',14,'FontWeight','bold')
xlim([1460 1550])
ylim([-max(ctd.Depth) 0])


f2 = figure; clf
plot(ctd.Time_UTC,-ctd.Depth,'.')
xlabel('Time')
ylabel('Depth, m')
grid on; grid minor
set(gca,'XTickLabelRotation',90)
xticks(ctd.Time_UTC(1):hours(2):ctd.Time_UTC(end))
xtickformat('HH:mm:ss')
set(gca,'fontweight','bold','fontsize',10);
