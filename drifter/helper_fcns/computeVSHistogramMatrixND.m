% function [vs_hist] = computeVSHistogram_Thode(vsdata,params,tabs)
%
%azi_param.az_edges = -0.5:2:360.5;
%azi_param.el_edges = -90.5:2:91.5;
%
%
%%%%Parameters
% params:  a structure of parameters arranged as follows:
%%
% %%%%%%How much time to make original distributions?
%
% %%Frequency range to review
% params.frange=[25 475];
% params.params_chc='AziVsAll2D_Time';  %%%What 3-D matricies to generate
%
%
% params.debug.image=false;

function computeVSHistogramMatrixND(avsdata,params,tabs,Ifile)
% Compute histograms using entire contents of vsdata (1 minute for drifter)
%persistent Ifile

global avs_hist

params.params_chc='AziVsSome2D_Time';
%params.grid.azi=4:4:360;  %Dominant azimuth grid
%params.grid.el=-90:2:90;

params.grid.azi=params.az_edges;
params.grid.el=params.el_edges;

params.grid.ItoE=0:0.02:1;  %Transport velocity
params.grid.KEtoPE=-6:1:6;
% params.grid.PdB=50:2:176;  %Standard power spectral density, dB re 1uPa^2/Hz
params.grid.PdB=130:0.5:150;  %Standard power spectral density, dB re 1uPa^2/Hz
params.grid.IntensityPhase=0:2:90;  %arctangent of reactive to active intensity



FF=avsdata.F;

if Ifile==1 || isempty(avs_hist) %Initialize ouputs, now that we have FF

    disp('Creating New Histogram Object');
    mid_grid.azi=0.5*(params.grid.azi(1:(end-1))+params.grid.azi(2:end));
    mid_grid.el=0.5*(params.grid.el(1:(end-1))+params.grid.el(2:end));
    mid_grid.PdB=0.5*(params.grid.PdB(1:(end-1))+params.grid.PdB(2:end));
    mid_grid.ItoE=0.5*(params.grid.ItoE(1:(end-1))+params.grid.ItoE(2:end));
    mid_grid.Phase=0.5*(params.grid.IntensityPhase(1:(end-1))+params.grid.IntensityPhase(2:end));
    switch params.params_chc
        case 'AziVsSome2D_Time'

            mid_grid.KEtoPE=0.5*(params.grid.KEtoPE(1:(end-1))+params.grid.KEtoPE(2:end));
            mid_grid.IntensityPhase=0.5*(params.grid.IntensityPhase(1:(end-1))+params.grid.IntensityPhase(2:end));

            avs_hist.AziVsEl=MatrixND([],{mid_grid.azi,mid_grid.el,FF,tabs},{'Azimuth','Elevation','Frequency','Time'});
            avs_hist.AziVsPdB=MatrixND([],{mid_grid.azi,mid_grid.PdB,FF,tabs},{'Azimuth','PSD','Frequency','Time'});
            avs_hist.AziVsItoE=MatrixND([],{mid_grid.azi,mid_grid.ItoE,FF,tabs},{'Azimuth','ItoE','Frequency','Time'});
        case 'AziVsAll2D_Time'

            mid_grid.KEtoPE=0.5*(params.grid.KEtoPE(1:(end-1))+params.grid.KEtoPE(2:end));
            mid_grid.IntensityPhase=0.5*(params.grid.IntensityPhase(1:(end-1))+params.grid.IntensityPhase(2:end));

            avs_hist.AziVsEl=MatrixND([],{mid_grid.azi,mid_grid.el,FF,tabs},{'Azimuth','Elevation','Frequency','Time'});
            avs_hist.AziVsPdB=MatrixND([],{mid_grid.azi,mid_grid.PdB,FF,tabs},{'Azimuth','PSD','Frequency','Time'});
            avs_hist.AziVsItoE=MatrixND([],{mid_grid.azi,mid_grid.ItoE,FF,tabs},{'Azimuth','ItoE','Frequency','Time'});
            avs_hist.AziVsKEtoPE=MatrixND([],{mid_grid.azi,mid_grid.KEtoPE,FF,tabs},{'Azimuth','KEtoPE','Frequency','Time'});
            avs_hist.AziVsIntensityPhase=MatrixND([],{mid_grid.azi,mid_grid.IntensityPhase,FF,tabs},{'Azimuth','IntensityPhase','Frequency','Time'});
            avs_hist.PdBVsItoE=MatrixND([],{mid_grid.PdB,mid_grid.ItoE,FF,tabs},{'PSD','ItoE','Frequency','Time'});
        case 'AziVsPdBVsItoE'
            avs_hist.AziVsPdBVsItoE=MatrixND([],{mid_grid.azi,mid_grid.PdB,mid_grid.ItoE,FF},{'Azimuth','PSD','ItoE','Frequency'});
        case 'AziVsPdBVsItoEVsPhase'
            avs_hist.AVTP=MatrixND([],{mid_grid.azi,mid_grid.PdB,mid_grid.ItoE,mid_grid.Phase,FF},{'Azimuth','PSD','ItoE','IntensityPhase','Frequency'});

    end

end


for If=1:length(FF)
    %if rem(If,20),  disp(If/length(FF));end
    %Iwant=Isort(If,Iper(Ipp):Iper(Ipp+1));
    switch params.params_chc
        case 'AziVsSome2D_Time'
            if ~isempty(avsdata.elegram)
                avs_hist.AziVsEl.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.elegram(If,:),params.grid.azi,params.grid.el));
            end
            avs_hist.AziVsPdB.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.PdB(If,:),params.grid.azi,params.grid.PdB));
            avs_hist.AziVsItoE.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.normalized_transport_velocity(If,:),params.grid.azi,params.grid.ItoE));

        case 'AziVsAll2D_Time'
            if ~isempty(avsdata.elegram)
                avs_hist.AziVsEl.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.elegram(If,:),params.grid.azi,params.grid.el));
            end
            avs_hist.AziVsPdB.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.PdB(If,:),params.grid.azi,params.grid.PdB));
            avs_hist.AziVsItoE.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.normalized_transport_velocity(If,:),params.grid.azi,params.grid.ItoE));
            avs_hist.AziVsKEtoPE.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.KEtoPEratio(If,:),params.grid.azi,params.grid.KEtoPE));
            avs_hist.AziVsIntensityPhase.N(:,:,If,Ifile)=single(histcounts2(avsdata.azigram(If,:),avsdata.intensity_phase(If,:),params.grid.azi,params.grid.IntensityPhase));
            avs_hist.PdBVsItoE.N(:,:,If,Ifile)=single(histcounts2(avsdata.PdB(If,:),avsdata.normalized_transport_velocity(If,:),params.grid.PdB,params.grid.ItoE));
        case 'AziVsPdBVsItoE'
            avs_hist.AziVsPdBVsItoE.N(:,:,:,If)=avs_hist.AziVsPdBVsItoE.N(:,:,:,If)+single(histcounts3(avsdata.azigram(If,:),avsdata.PdB(If,:),avsdata.normalized_transport_velocity(If,:), ...
                params.grid.azi,params.grid.PdB,params.grid.ItoE));
        case 'AziVsPdBVsItoEVsPhase'
            avs_hist.AVTP.N(:,:,:,:,If)=avs_hist.AVTP.N(:,:,:,:,If)+single(histcounts4(avsdata.azigram(If,:),avsdata.PdB(If,:),avsdata.normalized_transport_velocity(If,:), avsdata.intensity_phase(If,:), ...
                params.grid.azi,params.grid.PdB,params.grid.ItoE,params.grid.IntensityPhase));
    end
end

if 1==0
    %fidx = (vsdata.F>=fband(Iband,1))&(vsdata.F<=fband(Iband,2));

    %%%Create matricies
    azi_all= wrapTo360(vsdata.azigram(fidx,:));
    [azi_hist(Iband,:)] = histcounts(azi_all(:),azi_param.az_edges,'Normalization','count');



    bin_width = median(diff(azi_param.az_edges));
    %az_centers = azi_param.az_edges(1:end-1)+bin_width/2;

end