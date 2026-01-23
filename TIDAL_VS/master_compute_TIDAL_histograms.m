%%%master_compute_TIDAL_histograms.m%%%%%%

close all
clear all

addpath ../drifter/helper_fcns/
global avs_hist

avs_hist=[];

avs_data_folder='~/Projects/ONR_drifter/Deployments/Hawai_2025/Drifter5_Deployment1/Bulk_Analysis/avs_data/';
tabs_range=[datetime(2025,5,3,19,2,0) datetime(2025,5,3,19,45,0)];

avs_data_folder='/Volumes/Shared-1/Analysis/run_tidal_processing/Drifter5_Acoustic3_20250503T220700_20250505T220000/Unit001_VS107/avs_data/';
%tabs_range=[datetime(2025,5,3,12,0,0) datetime(2025,5,4,9,0,0)];

tabs_inc=(1);   %Increment in desired histogram in minutes.
params.az_edges=4:4:360;
params.el_edges=-90:2:90;
params.PdB_edges=100:2:140;



mydir=pwd;

fnames=dir([avs_data_folder filesep 'avs_data_*mat']);
for I=1:length(fnames)
    tabs_index(I)=datetime(fnames(I).name(21:34),'InputFormat','ddMMMyyyy-HHmm');
end

Ifile_begin=find(tabs_index<tabs_range(1), 1, 'last' );
Ifile_end=find(tabs_index>tabs_range(2), 1, 'first' )-1;

%%%Define time index of final histogram object--will need to check
tabs_output=tabs_index(Ifile_begin):minutes(tabs_inc):tabs_index(Ifile_end);

Icount=1;
for Ifile=Ifile_begin:Ifile_end
    fprintf('Loading %s ...\n',fnames(Ifile).name);
    data=load([avs_data_folder filesep fnames(Ifile).name]);
    %%%Assign a datetime to every time column.
    
    file_duration_seconds=seconds(max(data.avsdata.T));
    tabs_file=linspace(tabs_index(Ifile),tabs_index(Ifile)+file_duration_seconds,size(data.avsdata.PdB,2));
    dT=tabs_file(2)-tabs_file(1);
    Nsamples=floor(minutes(tabs_inc)/dT);
    Nchunks=ceil(minutes(tabs_file(end)-tabs_file(1))/tabs_inc);
    indexx=1;
    for Ichunk=1:Nchunks
        fprintf('Chunk %i of %i ...\n',Ichunk,Nchunks)
        indexx=(Ichunk-1)*Nsamples+(1:Nsamples);

        temp.azigram=data.avsdata.azigram(:,indexx);
        temp.elegram=data.avsdata.elegram(:,indexx);
        temp.PdB=data.avsdata.PdB(:,indexx);
        temp.normalized_transport_velocity=data.avsdata.normalized_transport_velocity(:,indexx);
        temp.F=data.avsdata.F;
        computeVSHistogramMatrixND(temp,params,tabs_output,Icount);
        tabs_output(Icount)=tabs_file(median(indexx));
        Icount=Icount+1;
    end
    
end
Icount=Icount-1;
tabs_output=tabs_output(1:Icount);

%%%Correct time dimension
%%%  Note that tabs_output is not evenly spaced in time, at the end of each
%%%  file there is is little jump (0.25 seconds for May 2025 data).
Itime=find(contains(avs_hist.AziVsEl.labels,'Time'));
avs_hist.AziVsEl.bin_grid{Itime}=tabs_output;
avs_hist.AziVsPdB.bin_grid{Itime}=tabs_output;
avs_hist.AziVsItoE.bin_grid{Itime}=tabs_output;

save_name=sprintf('avs_hist_%s_%s.mat',datestr(tabs_output(1),30),datestr(tabs_output(end),30));
save(save_name,'-v7.3','avs_hist')


frange=[1500 3000];
figure(1);
subplot(2,1,1);avs_hist.AziVsPdB.sum_slice('Azimuth').extract_slice('Frequency',frange).sum_slice('Frequency').image_2D_slice;
subplot(2,1,2);avs_hist.AziVsPdB.sum_slice('PSD').extract_slice('Frequency',frange).sum_slice('Frequency').image_2D_slice;