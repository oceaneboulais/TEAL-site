close all
clear all

addpath(genpath('/Volumes/homes/alaferriere/GIT/ThodeLab'))
addpath('EnumClass/')
addpath('functions/')

base_data_dir = '/Volumes/Shared/ONR_DRIFTER/2025_Sep_CA';
expt_name_set = {
    'Drifter5_Acoustic3_20250926T180000_20250929T200000'
    'Drifter6_Acoustic4_20250929T204500_20251003T193000'
    };

base_data_dir= '/Volumes/Shared-1/ONR_DRIFTER/2025_May_HI';



expt_name_set = {
    'Drifter5_Acoustic3_20250503T220700_20250505T220000'
   
    };



subdir = 'TIDAL';

base_savefolder = fullfile('/Volumes/Shared/Analysis',mfilename);

overwrite_avs_data = false;
do_histograms = false;
save_rotated_wav_file = false;

avs_time_avg = 0.1;
NAS_avg_time = 0.5;

%%%Frequency bands for histogram processing
fband = [
    500 1.5e3
    2.5e3 7e3;
    ];

%% plot settings

el_res_hist = 2;
az_res_hist = 2;


hist_param.az_edges = -0.5:az_res_hist:360.5;
hist_param.el_edges = -90.5:el_res_hist:91.5;
hist_param.PdB_edges = 110:0.5:160;
%% freq settings
nfft = 512; % frequency resolution of FFT in Hz
prcnt_overlap = 0.50; % percent overlap to use in spectrogram calculation, 0 - 1

for iset = 1:length(expt_name_set)
    expt_name = expt_name_set{iset};
    data_dir = fullfile(base_data_dir,expt_name,subdir);
    % assume that different tidals are located as subfolders with their unit ID
    % as the folder name
    dir_list = dir(data_dir);
    tidal_list = {dir_list.name};
    tidal_list = tidal_list([dir_list.isdir] & ~ismember(tidal_list,{'.','..'}));

    for Itidal = 1:length(tidal_list)

        savefolder = fullfile(base_savefolder,expt_name,tidal_list{Itidal});
        filelist = dir(fullfile(data_dir,tidal_list{Itidal},'*','AnalogData*.vs'));
        Nfiles = length(filelist);

        if Nfiles ==0, continue, end

        % first read in the time for each file
        % we need to do this in order to use the MatrixND functino
        good_files = true(1,Nfiles);
        for ii = 1:Nfiles
            filename = fullfile(fullfile(filelist(ii).folder,filelist(ii).name));
            try
                [~,~,header(ii)] = readTIDALData(filename,[0 0 1]);
            catch
                warning('Error reading file, skipping file %s',filelist(ii).name)
                good_files(ii) = false;
            end
        end
        %     good_files(100:end) = false;
        filelist = filelist(good_files);
        header = header(good_files);
        fs = [header.SampleRate];
        if any(fs~=fs(1)), error('sample rate mismatch!'), end;
        fs = fs(1);
        file_time = [header.CurrentTime];

        Nfiles = length(filelist);
        Spow_avg = zeros(Nfiles,nfft/2+1,4);
        Spow_med = zeros(Nfiles,nfft/2+1,4);
        F_spec = zeros(Nfiles,nfft/2+1);

        Ssavefilename = fullfile(savefolder,[expt_name '_' tidal_list{Itidal} '_spectra.mat']);
        specfile_exists = exist(Ssavefilename,'file');

        avs_hist_filename = fullfile(savefolder,[expt_name '_' tidal_list{Itidal}  '_avs_hist.mat']);

        sensor_type = ["VS-209-omni" "VS-209-X" "VS-209-Y" "VS-209-Z"];
        nas.tabs=[];nas.g=[];nas.m=[];
        % now loop through the files
        for file_idx = 1:Nfiles
            tic
            fprintf('\nProcessing file %i of %i: %s\n',file_idx,Nfiles,filelist(file_idx).name)

           % if ~isfolder(fullfile(savefolder,'avs_data'))
           %     mkdir(fullfile(savefolder,'avs_data'))
           % end

            % load the data and process
            fprintf('Loading data..\n')

            filename = fullfile(fullfile(filelist(file_idx).folder,filelist(file_idx).name));

            [filepath,stem,ext]=fileparts(filename);
            stem=sprintf('%s_VS-209sensor-rot',stem);

            vssavename = sprintf('avs_data_%s.mat',stem);
            vssavename = fullfile(savefolder,'avs_data',vssavename);
            vsfile_exists = exist(vssavename,'file');
            try
                [~,NASdata] = readTIDALData(filename,[0 1 0]);

                %%%Store orientation data
                NASdata.DigitalDataMeas=[NASdata.DigitalDataMeas(1,:); NASdata.DigitalDataMeas];
                NASdata.g=NASdata.DigitalDataMeas(:,4:6);
                NASdata.m=NASdata.DigitalDataMeas(:,7:9);
                naslen = size(NASdata.DigitalDataMeas,1);  %Sampled every 10 seconds
                NASdata.dt=1./NASdata.DigitalPar.Header.SampleRate;

                t_NAS=NASdata.dt*(0:(naslen-1));  %time axis of NAS data in seconds
                t_NAS_update=unique([0:NAS_avg_time:max(t_NAS) max(t_NAS)]);

                NASdata.tabs_start=filelist(file_idx).name(12:(end-3));
                temp.tabs=datetime(NASdata.tabs_start,'InputFormat','ddMMMyyyy-HHmm');
                nas.tabs=[nas.tabs temp.tabs+seconds(t_NAS)];
                nas.g=[nas.g; NASdata.g];
                nas.m=[nas.m; NASdata.m];
                % acoulen = size(x,1);  %%Five minute file
                %t_ac=(0:(acoulen-1))./Fs;
                % disp('Data loaded');
                %toc


                t1 = toc;
                fprintf('File took %1.2f seconds to load NAS data\n\n\n  ',t1)
            catch
                warning('Error reading file, skipping file %s',filelist(file_idx).name)
                continue
            end
        end %file_idx

      nas.g_tot=sqrt(sum(abs(nas.g.^2),2));
      nas.m_tot=sqrt(sum(abs(nas.m.^2),2));
      figure
      subplot(3,1,1);plot(nas.tabs,nas.g);title('acceleration data');legend('x','y','z');grid on
      title(sprintf('Accelerometer %s in %s/%s',tidal_list{Itidal},base_data_dir,expt_name),'Interpreter','none')
      subplot(3,1,2);plot(nas.tabs,nas.m);title('magnetometer data');legend('x','y','z');grid on
      subplot(3,1,3);yyaxis left;plot(nas.tabs,nas.g_tot);
      yyaxis right; plot(nas.tabs,nas.m_tot)
      title('Magnitudes');legend('Acceleration magnitude','Magnetometer magnitude');grid on
      xlabel('Time (Local)');
      NASsavefilename = fullfile(savefolder,[expt_name '_' tidal_list{Itidal} '_nas']);
      saveas(gcf,NASsavefilename,'fig');

    end %itidal
end %iset
