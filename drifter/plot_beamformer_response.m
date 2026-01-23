close all, clear all
% data_path = '/Volumes/Shared/Analysis/run_vla_processing_v4/line_1_1_128_fs25000_nfft256_noverlp0_dEL1_snippet1/NESMA24/RAVA13_D1_sio/beamformer_data';
% data_path = '/Volumes/Shared/Analysis/run_vla_processing_v4/line_60_1_65_fs25000_nfft256_noverlp0_dEL1_snippet1/NESMA24/RAVA13_D1_sio/beamformer_data';
% data_path = '/Volumes/Shared/Analysis/run_drifter_processing_v4/line_fs51200_nfft512_noverlp256_dEL1/2023_Fall_Kelvin_Seamount/Drifter6_Acoustic4_20231004T111700_20231006T123000/beamformer_data';

% data_path = '/Volumes/Shared/Analysis/run_drifter_processing_v4/line_fs51200_nfft512_noverlp256_dEL1/2024_Jun_Seamounts/Drifter6_Acoustic4_20240619T190000_20240624T010000/beamformer_data';

% data_path = '/Volumes/Shared/Analysis/run_drifter_processing_v4/line_fs51200_nfft512_noverlp256_dEL1/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231011T153600_20231013T182600/beamformer_data';
% data_path = '/Volumes/Shared/Analysis/run_drifter_processing_v4/line_fs51200_nfft512_noverlp256_dEL1/2023_Fall_Kelvin_Seamount/Drifter6_Acoustic4_20231004T111700_20231006T123000/beamformer_data'

data_path = '/Volumes/Shared/Analysis/run_drifter_processing_v4/line_fs51200_nfft512_noverlp256_dEL1/2023_Fall_Kelvin_Seamount/Drifter6_Acoustic4_20231004T111700_20231006T123000/beamformer_data';
fband = [
    2.5e3 7e3;
  ];
iband = 1;

el_res = 1;

el_edges = -90.5:el_res:91.5;

do_plot = false;

% filelist = dir(fullfile(data_path, '*.mat'));
% time_start_utc = datetime(2023,10,12,14,50,0);
% time_stop_utc = datetime(2023,10,12,21,0,0);
% time_start_utc = datetime(2023,10,5,14,0,0);
% time_stop_utc = datetime(2023,10,5,16,0,0);
% time_start_utc = datetime(2023,10,5,21,30,0);
% time_stop_utc = datetime(2023,10,6,1,00,0);
time_start_utc = datetime(2023,10,4,4,49,0,0);
time_stop_utc = datetime(2023,10,5,17,0,0);
% filelist = dir(fullfile(data_path, '*.mat'));
[filelist,file_time_utc,filenames] = getFilesInRange(data_path,time_start_utc,time_stop_utc,'.mat');

for ifile = 1:length(filelist) %3250:4250
    fprintf('loading file %i of %i\n',ifile,length(filelist))
    load(fullfile(filelist(ifile).folder, ...
        filelist(ifile).name),'beamdata')

    if ~isfield(beamdata,'kscale')
        kscale = 1;
    else
        kscale = beamdata.kscale;
    end

    B_pow = squeeze(10.^(double(beamdata.B_pow_dB)/(10*kscale)));
    B_pow_med = squeeze(median(B_pow,2));





    f1 = fband(iband,1);
    f2 = fband(iband,2);

    fidx = (beamdata.F>=fband(iband,1))&(beamdata.F<=fband(iband,2));
    B_incoh = squeeze(mean(B_pow(fidx,:,:)));

    B_incoh_med(ifile,:) = median(B_incoh);
%     B_incoh_avg(ifile,:) = mean(B_incoh);

    [B_ele_max,max_idx] = max(B_incoh,[],2);
    elev_est= beamdata.elev_deg(max_idx);
    
    elev_hist(ifile,:,iband) = histcounts(elev_est,el_edges,'Normalization','count'); 

    T_file(ifile) = beamdata.T_utc(1);
    if do_plot
        figure(1)
        pcolor(beamdata.F/1e3,beamdata.elev_deg,10*log10(B_pow_med.'))
        shading flat
        colormap default
        xlim([0 7])
        ylim([-90 90])
        set(gca,'fontweight','bold','fontsize',14);
        xlabel('Freq, kHz')
        ylabel('Elevation, deg')

    end
end
%%
figure
set(gcf,'Position',[150         185        1447         822])
tiledlayout(2,1)
ax(1) = nexttile;
pcolor(T_file(1:ifile),beamdata.elev_deg,10*log10(B_incoh_med.'))
shading flat
colormap jet
xlabel('Time, UTC')
ylabel('Elevation, deg')
set(gca,'fontweight','bold','fontsize',18);
colorbar
title(sprintf('Median Beam Response, %1.1f kHz to %1.2f kHz',fband(1)/1e3,fband(2)/1e3))

ax(2) = nexttile;
bin_width = median(diff(el_edges));
el_centers = el_edges(1:end-1)+bin_width/2;
pcolor(T_file(1:ifile),el_centers,squeeze(elev_hist./max(elev_hist,[],2)).');axis('xy')

shading flat
ylabel('Elevation, deg')
xlabel('Time')
set(gca,'fontweight','bold','fontsize',18);
ylim([-90 90])
clim([0 1])
colorbar
title('Elevation Histogram')

linkaxes(ax,'x');

savefile = fullfile(data_path,'..','beam_response');
saveas(gcf,savefile,'fig')
saveas(gcf,savefile,'png')