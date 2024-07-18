function updateSpecPlot(app)
if isempty(app.S)
    return
end
selectedButton = app.PlotTypeButtonGroup.SelectedObject;


ch_idx = str2double(app.Channel.Value);
PdB = 20*log10(abs(app.S(:,:,ch_idx)));

med_level_dB = medfilt2(PdB,[30 30]);
SNR_dB = PdB - med_level_dB;

if app.TransparencyCheckBox.Value
    transp = app.metrics.normalized_transport_velocity;
else
    transp = ones(size(app.metrics.normalized_transport_velocity));
end

reject_data = SNR_dB<app.SNRThresholdEditField.Value ...
    | app.metrics.normalized_transport_velocity < app.NTVThresholdEditField.Value;

transp(reject_data) = 0;

current_axes = app.UIAxes;

Tvar = app.T;
Tlabel = 'Time, sec';

switch selectedButton.Text
    case 'Spectrogram'
        p=pcolor(current_axes,Tvar,app.F/1e3,PdB);
        p.ZData = p.CData;
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        shading(current_axes,'flat');% 
        colorbar(current_axes)
        colormap(current_axes,'jet')
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = sprintf('PSD, Channel %i: %s',app.ch_select(ch_idx),app.ch_type(ch_idx));
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
        
    case 'AVS Azigram'
        p=pcolor(current_axes,Tvar,app.F/1e3,wrapTo180(app.metrics.azigram)); 
        shading(current_axes,'flat');% 
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        p.ZData = p.CData;
        colorbar(current_axes)
        colormap(current_axes,'hsv')
        
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = 'AVS Azigram';
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
    case 'AVS Elegram'
        p=pcolor(current_axes,Tvar,app.F/1e3,wrapTo180(app.metrics.elegram)); 
        shading(current_axes,'flat');% 
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        p.ZData = p.CData;
        colorbar(current_axes)
        colormap(current_axes,'jet')
        
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = 'AVS Elegram';
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
    case 'NTV'
        p=pcolor(current_axes,Tvar,app.F/1e3,...
            app.metrics.normalized_transport_velocity); 
        p.ZData = p.CData;
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        shading(current_axes,'flat');% 
        colorbar(current_axes)
        colormap(current_axes,'jet')
        
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = 'Normalized Transport Velocity';
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
    case 'KE to PE Ratio'
        p=pcolor(current_axes,Tvar,app.F/1e3,...
        app.metrics.KEtoPEratio); 
        p.ZData = p.CData;
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        shading(current_axes,'flat');% 
        colorbar(current_axes)
        colormap(current_axes,'jet')
        
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = 'KE to PE Ratio';
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
    case 'Beamformer Power'

        updateBFData(app)
        
        el_index = app.PlotElev.Value;
        p=pcolor(current_axes,Tvar,app.B_F/1e3,10*log10(squeeze(app.bf_data.B_pow(:,:,:,el_index==app.elev_deg))));
        p.ZData = p.CData;
        p.AlphaData = transp; 
        p.FaceAlpha = 'flat';
        p.AlphaDataMapping = 'none';
        shading(current_axes,'flat');% 
        colorbar(current_axes)
        colormap(current_axes,'jet')
        set(current_axes,'FontSize',14,'FontWeight','bold')
        title_str = sprintf('Beamformer Power, Elev = %1.2fdeg',app.PlotElev.Value);
        xlabel(current_axes,Tlabel)
        ylabel(current_axes,'Freq, kHz')
end
% keep the limits the same as I switch back and forth
% xa = xlim(current_axes);
% ya = ylim(current_axes);
ya = [app.YlimLower.Value app.YlimUpper.Value];
% xa = [Tvar(1) Tvar(end)]; 
xa = [app.XlimLower.Value app.XlimUpper.Value];
ca = [app.ClimLower.Value app.ClimUpper.Value];

% keep the limits the same as I switch back and forth
% if ~app.KeepLimitsCheckBox.Value
%     ya = [0 app.YlimUpper.Value/1e3];
%     xa = [app.metrics.T_utc(1) app.metrics.T_utc(end)]; 
% end
xlim(current_axes,xa); ylim(current_axes,ya); clim(current_axes,ca);
second_duration = 0:app.SelectDuration.Value;
set(current_axes,'fontweight','bold','fontsize',12);
set(current_axes,'XTickLabelRotation',90)
current_axes.XTick = linspace(xa(1),xa(2),min(length(second_duration),10));
if isdatetime(Tvar)
    datetick(current_axes,'x','HH:MM:SS.FFF','keepticks')
end

title(current_axes,{title_str,...
    sprintf('%s to %s',datestr(app.T_utc(1)),datestr(app.T_utc(end)))})



% app.YlimLower.Value = ya(1);
% app.YlimUpper.Value = ya(2);