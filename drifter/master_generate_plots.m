%%%do_plots%%%

if save_to_ppt
    title_slide = sprintf('Drifter #%i, Acoustic Sphere %i: %s',...
        driftlog.DrifterNumber(didx),driftlog.AcousticSphere(didx), driftlog.VectorSensor{didx});
    subtitle_slide = sprintf('%s - %s',t0_utc,tend_utc);

    pptx.addSlide('Master',1,'Layout','Title Slide');
    pptx.addTextbox(title_slide,'Position','Title');
    pptx.addTextbox(subtitle_slide,'Position','Subtitle');

    pptx_bf.addSlide('Master',1,'Layout','Title Slide');
    pptx_bf.addTextbox(title_slide,'Position','Title');
    pptx_bf.addTextbox(subtitle_slide,'Position','Subtitle');
end
% plot Wentz curve
figure
plot(freq/1e3,NL_dB_0,'linewidth',2)
hold on
plot(freq/1e3,NL_dB_3,'linewidth',2)
grid on
xlabel('Freq, kHz')
ylabel('Noise Level, dB re 1\muPa^2/Hz')
legend('Sea State 0','Sea State 3')
set(gca,'fontweight','bold','fontsize',14);
title('Wentz Noise')


% load in the saved results
if do_raw_data
    ssave = load(Ssavefilename,'Spow_avg','Spow_med','Tfile','F');
    Tfile = ssave.Tfile; F_spec_plot=ssave.F;
    Spow_avg = ssave.Spow_avg; Spow_med = ssave.Spow_med;
end
if do_bf_data
    bsave = load(Bsavefilename,'Bpow_avg','Bpow_med','b_incoh_dB','Tfile','fband','elev_deg','F');
    Bpow_avg = bsave.Bpow_avg; Bpow_med = bsave.Bpow_med;
    Tfile = bsave.Tfile; elev_deg = bsave.elev_deg; F_bf=bsave.F;
end

%%
% compute the in-band noise levels for wentz
legend_str = cell(size(fband,1),1);
for iband = 1:size(fband,1)
    fidx = freq>=fband(iband,1) & freq<=fband(iband,2);
    dfNL = median(diff(freq));
    NL0_band(iband) = 10*log10(sum(10.^(NL_dB_0(fidx)/10)));
    NL3_band(iband) =  10*log10(sum(10.^(NL_dB_3(fidx)/10)));
    NL6_band(iband) =  10*log10(sum(10.^(NL_dB_6(fidx)/10)));
    %
    legend_str{iband} = sprintf('%1.2fkHz-%1.2fkHz',fband(iband,1)/1e3,fband(iband,2)/1e3);
end


% load the drifter ctd info
% ctd = loadCTDData(Tfile,data_basedir);

% load the IMU data
% imu = loadIMUData(Tfile,data_dir);

% load the USBL data

[driftcam,control_label] = loadDrifterLogDataV2(Tfile,logdir,driftlog.DrifterNumber(didx));
% temporary hack to add ship distance ****
try
    drift_track = load('/Volumes/homes/alaferriere/Analysis/drift_track.mat');
catch
    disp('Drifter track not loaded');
end
%%
ax = [];
if do_raw_data
    switch avg_type
        case 'Median'
            Spowplot = Spow_med;
        case 'Mean'
            Spowplot = Spow_avg;
    end

    sensor_to_plot = 1:size(Spowplot,3);

    rawdata_legend_str = {};
    for sensID = sensor_to_plot

        max_F = min(max(F_spec_plot/1e3),15);

        figure('Renderer','zbuffer');
        ssize = get(groot, 'ScreenSize');
        set(gcf, 'Position', ssize);

        tiledlayout(6,1);
        ax(end+1) = nexttile([1 1]);

        driftcamStatusPlot(driftcam,driftlog.SunsetUTC(didx),driftlog.SunriseUTC(didx));

        %%%Plot ship position, if available
        if exist('drift_track','var')
            di = drift_track.deployment == deployment;
            if any(di)
                ax(end+1) = nexttile;
                hold on
                for kk = 1:size(drift_track.drift_time,2)
                    if isempty(drift_track.drift_time{di,kk})
                        continue
                    end
                    plot([drift_track.drift_time{di,kk}],[drift_track.ship_dist_m{di}(kk,:)]/1e3,'k','linewidth',2);
                end
                ylabel('Distance, km')
                title('Drifter-Ship Distance')
                set(gca,'fontweight','bold','fontsize',14);
                set(gca,'XTickLabel','')
                grid on
                ax(end+1) = nexttile([4 1]);
            else
                ax(end+1) = nexttile([5 1]);
            end
        else
            ax(end+1) = nexttile([5 1]);
        end

        pcolor(Tfile,F_spec_plot/1e3,10*log10(Spowplot(:,:,sensID)).'); shading flat
        colormap jet
        colorbar
        ylim([0 max_F])
        clim([20 90])
        set(gca,'fontweight','bold','fontsize',14);
        set(gca,'XTickLabelRotation',90)
        ax2 = gca; ax2.XTick = linspace(Tfile(1),Tfile(end),80);
        %             ax(end+1) = ax2;
        datetick('x','mm-dd, HH:MM:SS','keepticks')

        ch_str = sprintf('CH%i %s',ch_select(sensID),acoustic_config.sensor_type{ch_select(sensID)});
        rawdata_legend_str = cat(2,rawdata_legend_str,ch_str);
        sgtitle(sprintf('%s: One Minute %s Spectrogram',ch_str,avg_type),'fontweight','bold','fontsize',18)


        ax2.YTick = 0:0.1*max_F:max_F;
        ylabel('Freq, kHz')

        linkaxes(ax,'x')
        xlim([min(Tfile) max(Tfile)])

        if save_to_ppt

            slideId = pptx.addSlide();
            fprintf('Added slide %d\n',slideId);
            pptx.addTextbox([title_slide ' ' subtitle_slide ch_str]);
            pptx.addPicture(gcf);
        end
        if save_plots
            png_savename = sprintf('Drifter_%i_Acoustic%i_CH%i_%s_%s_%s',...
                driftlog.DrifterNumber(didx),driftlog.AcousticSphere(didx), ...
                ch_select(sensID),acoustic_config.sensor_type{ch_select(sensID)},...
                datetime(t0_utc,'format','yyyyMMdd''T''HHmmSS'),...
                datetime(tend_utc,'format','yyyyMMdd''T''HHmmSS'));

            saveas(gcf,fullfile(thissavefolder,[png_savename '.png']))
            saveas(gcf,fullfile(thissavefolder,[png_savename '.fig']))
        end
    end %sensID

    % make line plots of in-band noise levels
    figure('Renderer','zbuffer');
    ssize = get(groot, 'ScreenSize');
    set(gcf, 'Position', ssize);
    tiledlayout(size(fband,1),1)

    for iband = 1:size(fband,1)
        fidx = F_spec_plot>=fband(iband,1) & F_spec_plot<=fband(iband,2);
        Spow_incoh_dB = squeeze(10*log10(trapz(F_spec_plot(fidx),Spowplot(:,fidx,:),2)));
        % ax(end+1)=subplot(size(fband,1),1,iband);
        ax(end+1) = nexttile;
        h1=plot(Tfile,Spow_incoh_dB,'linewidth',2);
        hold on
        % hp=plot(Tfile,Spow_incoh_dB(:,9),'--','linewidth',2);
        % hx=plot(Tfile,Spow_incoh_dB(:,10),'--','linewidth',2);
        % hy=plot(Tfile,Spow_incoh_dB(:,11),'--','linewidth',2);
        % hz=plot(Tfile,Spow_incoh_dB(:,12),'--','linewidth',2);
        plot(Tfile,NL0_band(iband).*ones(length(Tfile),1),'-.k')
        plot(Tfile,NL3_band(iband).*ones(length(Tfile),1),'-.k')
        grid on
        ylim([60 100])

        set(gca,'fontweight','bold','fontsize',14);
        ylabel('NL, dB re 1\muPa')
        title( legend_str{iband})
        ax2 = gca(); ax2.XTick = linspace(Tfile(1),Tfile(end),80);
        ax2.XTickLabel = '';
        %             ax(end+1) = ax2;
    end
    set(gca,'XTickLabelRotation',90)
    ax2 = gca; ax2.XTick = linspace(Tfile(1),Tfile(end),80);
    %         ax(end+1) = ax2;
    datetick('x','mm-dd, HH:MM:SS','keepticks')

    linkaxes(ax,'x')
    legend(nexttile(1),h1,rawdata_legend_str,'location','northeastoutside ')

    sgtitle('Single Channel Noise Levels','fontweight','bold','fontsize',18)

    if save_plots
        saveas(gcf,fullfile(Ssavefilename),'fig')
        saveas(gcf,fullfile(Ssavefilename),'png')
    end

    if save_to_ppt

        slideId = pptx.addSlide();
        fprintf('Added slide %d\n',slideId);
        pptx.addTextbox([title_slide ' ' subtitle_slide]);
        pptx.addPicture(gcf);
    end

end %do_raw_data
linkaxes(ax,'x')
xlim([min(Tfile) max(Tfile)])
if do_bf_data
    switch avg_type
        case 'Median'
            Bpow = Bpow_med;
        case 'Mean'
            Bpow = Bpow_avg;
    end

    % make color plots for select elevations

    for iel = el_plot
        figure('Renderer','zbuffer');
        ssize = get(groot, 'ScreenSize');
        set(gcf, 'Position', ssize);

        tiledlayout(6,1);

        ax(end+1) = nexttile;

        driftcamStatusPlot(driftcam,sunset_app_utc,sunrise_app_utc);

        ax(end+1) = nexttile;


        ax(end+1) = nexttile([4 1]);

        elidx = elev_deg==iel;
        pcolor(Tfile,F_bf/1e3,10*log10(Bpow(:,:,elidx)).'); shading flat
        colormap jet
        colorbar
        ylim([0 max(F_bf/1e3)])
        caxis([30 90])
        set(gca,'fontweight','bold','fontsize',14);

        set(gca,'XTickLabelRotation',90)
        ax2 = gca(); ax2.XTick = linspace(Tfile(1),Tfile(end),80);
        ax(end+1) = ax2;

        max_F = min(max(F_bf/1e3),15);
        ax2.YTick = 0:0.1*max_F:max_F;
        ylabel('Freq, kHz')


        sgtitle(sprintf('One Minute %s Beamformer Output: El=%1.2f deg',...
            avg_type,elev_deg(elidx)),'fontsize',18,'fontweight','bold')

        if save_to_ppt
            linkaxes(ax,'x')
            xlim([min(Tfile) max(Tfile)])
            slideId = pptx_bf.addSlide();
            fprintf('Added slide %d\n',slideId);
            pptx_bf.addPicture(gcf);
            pptx_bf.addTextbox([title_slide ' ' subtitle_slide sprintf(' Elev %1.0f',elev_deg(elidx))]);

        end

        figure('Renderer','zbuffer');
        ssize = get(groot, 'ScreenSize');
        set(gcf, 'Position', ssize);

        tiledlayout(5,1);

        ax(end+1) = nexttile;

        driftcamStatusPlot(driftcam,sunset_app_utc,sunrise_app_utc);

        ax(end+1) = nexttile([4 1]); B_incoh_dB = [];
        for iband = 1:size(fband,1)
            fidx = F_bf>=fband(iband,1) & F_bf<=fband(iband,2);
            B_incoh_dB(:,:,iband) = squeeze(10*log10(trapz(F_bf(fidx),Bpow(:,fidx,:),2)));
        end
        h=plot(Tfile,squeeze(B_incoh_dB(:,elev_deg==0,:)),'linewidth',2);
        hold on
        set(gca,'ColorOrderIndex',1)
        plot(Tfile,NL0_band.*ones(length(Tfile),1),'--')
        set(gca,'ColorOrderIndex',1)
        plot(Tfile,NL3_band.*ones(length(Tfile),1),'-.')
        grid on
        legend(h,legend_str)
        set(gca,'fontweight','bold','fontsize',14);
        ylabel('NL, dB re 1\muPa')
        ylim([60 100])
        ax2 = gca(); ax2.XTick = linspace(Tfile(1),Tfile(end),80);
        ax2.XLabel.Visible = 'off';
        datetick('x','mm-dd, HH:MM:SS','keepticks')
        ax2.XTickLabelRotation = 90;

        sgtitle(sprintf('Beamformed Output, Elev = %1.2f deg',iel),'fontweight','bold','fontsize',18)



    end
    linkaxes(ax,'x')
    xlim([min(Tfile) max(Tfile)])
    % saveas(gcf,fullfile(Bsavefilename),'fig')
    % saveas(gcf,fullfile(Bsavefilename),'png')
    %%
    figure('Renderer','zbuffer');
    ssize = get(groot, 'ScreenSize');
    set(gcf, 'Position', ssize);

    tiledlayout(2*size(fband,1)+1,1)

    ax(end+1) = nexttile;

    driftcamStatusPlot(driftcam,driftlog.SunsetUTC(didx),driftlog.SunriseUTC(didx));



    for iband = 1:size(fband,1)

        % ax2=subplot(size(fband,1),1,iband);
        ax(end+1) = nexttile([2,1]);
        pcolor(Tfile,elev_deg,B_incoh_dB(:,:,iband).'); shading flat
        colormap jet
        cb = colorbar;
        clim([70 90])
        set(gca,'fontweight','bold','fontsize',14);
        cb.Label.String = 'NL, dB re 1\muPa';
        title( legend_str{iband})
        ylabel('Elevation, deg')
        ax2 = gca; ax2.XTick = linspace(Tfile(1),Tfile(end),80);
        ax2.XTickLabel = '';



    end
    ax2.XTick = linspace(Tfile(1),Tfile(end),80);
    datetick('x','mm-dd, HH:MM:SS','keepticks')
    ax2.XTickLabelRotation = 90;

    sgtitle( sprintf('Beamformer Output, One Minute %s', avg_type),'fontweight','bold','fontsize',18)

    linkaxes(ax,'x')
    xlim([min(Tfile) max(Tfile)])

    if save_to_ppt
        linkaxes(ax,'x')
        xlim([min(Tfile) max(Tfile)])
        slideId = pptx_bf.addSlide();
        fprintf('Added slide %d\n',slideId);
        pptx_bf.addPicture(gcf);
        pptx_bf.addTextbox([title_slide ' ' subtitle_slide ch_str]);

    end
end  %do_bf_data



