close all
clear all

addpath(genpath('/Volumes/homes/alaferriere/GIT/ThodeLab'))
addpath('EnumClass/')
addpath('functions/')

global avs_hist

base_data_dir = '/Volumes/Shared/TIDAL/';
% expt_name = 'TiDAL_Deployment_Maui_2025';
% subdir = 'Acoustic_Data';

expt_name_set = {
    'TiDAL March 2025 Pier Calib'
    };
subdir = [];


base_savefolder = fullfile('/Volumes/Shared/Analysis',mfilename);

overwrite_avs_data = false;
do_histograms = true;
save_rotated_wav_file = true;

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



for itidal = 1:length(tidal_list)
    
    savefolder = fullfile(base_savefolder,expt_name,tidal_list{itidal});
    filelist = dir(fullfile(data_dir,tidal_list{itidal},'*','AnalogData*.vs'));
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

    Ssavefilename = fullfile(savefolder,[expt_name '_' tidal_list{itidal} '_spectra.mat']);
    specfile_exists = exist(Ssavefilename,'file');

    avs_hist_filename = fullfile(savefolder,[expt_name '_' tidal_list{itidal}  '_avs_hist.mat']);

    sensor_type = ["VS-209-omni" "VS-209-X" "VS-209-Y" "VS-209-Z"];

    % now loop through the files
    for file_idx = 1:Nfiles
        tic
        fprintf('\nProcessing file %i of %i: %s\n',file_idx,Nfiles,filelist(file_idx).name)

        if ~isfolder(fullfile(savefolder,'avs_data'))
            mkdir(fullfile(savefolder,'avs_data'))
        end

        % load the data and process
        fprintf('Loading data..\n')

        filename = fullfile(fullfile(filelist(file_idx).folder,filelist(file_idx).name));

        [filepath,stem,ext]=fileparts(filename);
        stem=sprintf('%s_VS-209sensor-rot',stem);

        vssavename = sprintf('avs_data_%s.mat',stem);
        vssavename = fullfile(savefolder,'avs_data',vssavename);
        vsfile_exists = exist(vssavename,'file');

        

        if ~vsfile_exists || ~specfile_exists || overwrite_avs_data
            try 
    
                [y,nas] = readTIDALData(filename,[1 1 0]);
      
                disp('Data loaded');
                toc
    
                %%%%Rotate the data
                %%%%%%%%%%Rotating processes%%%%%%
                disp('Performing rotation...');
                y = rotateTIDALData(y,nas,NAS_avg_time,fs);
                disp('Rotation complete')
                toc
    
                % save the rotated wav file 
                if save_rotated_wav_file
                    disp('Saving wav file...')
    
                    audiowrite([filepath filesep stem '.wav'],y,fs,'BitsPerSample',32);
                    disp('Save complete')
                    toc
                end
    
            catch
                warning('Error reading file, skipping file %s',filelist(file_idx).name)
                continue
            end
        
        

            % compute the spectrogram of each channel
            disp('compute FFT...')
            noverlp = floor(nfft*prcnt_overlap);
            win = hamming(nfft);

            
            
            for ich = 1:size(y,2)    
                [S(:,:,ich),F,T] = spectrogram(y(:,ich),win,noverlp,nfft,fs);
    
    
                H = getSensitivity(F,sensor_type{ich},'units','uPa/V');
    
                S(:,:,ich) = S(:,:,ich).*H.';
    
            end
		    disp('FFT done')

            clear y
    
            % average power over time for each channel
            winPow = win'*win;
            Spow = S.*conj(S)/(winPow*fs);
            Spow_avg(file_idx,:,:) = squeeze(mean(Spow,2));
            Spow_med(file_idx,:,:) = squeeze(median(Spow,2));
    
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%vector_sensor_processing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if ~vsfile_exists || overwrite_avs_data
                fprintf('Computing Azigram and Elegram: %s\n',vssavename)
    
                disp('Start AVS processing')
    
    
    %           TODO:  correct for magnetic declination
    %             [~, ~, declination] = wrldmagm(0, dlat, dlon, dyear);
                declination = 0;
    
                opts.do_3D_metrics = true;
                opts.compass_offset = declination;
                opts.elevation_offset = 0;
                opts.time_avg = avs_time_avg;
                avsdata = computeDirectionalMetrics(S(:,:,1),S(:,:,2:4),opts,T);
    
                toc
                disp('AVS processing completed')
    
                avsdata.declination = declination;
                avsdata.F = F;
                avsdata.T = T;
    
                clear S
    
    
                disp('Saving avs file...')
                save(vssavename,'avsdata')
                disp('Save complete.')
                toc
            else
                disp('Loading avs data...')
                load(vssavename,'avsdata')
                disp('Load complete.')  
                toc
            end
        elseif vsfile_exists && specfile_exists
            disp('Loading avs data...')
            load(vssavename,'avsdata')
            disp('Load complete.')
            toc
        end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%Accumlated statistics from raw metrics%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            
            if do_histograms
                disp('Starting avs histogram processing')
                if file_idx==1
                    avs_hist=[];
                end
    %                     computeVSHistogramMatrixND(avsdata,hist_param,tabs_files,file_idx);
                computeVSHistogramMatrixND(avsdata,hist_param,file_time,file_idx);
                disp('Finished processing.')
                toc
    
                clear avsdata
            end %do stats
            t1 = toc;
            fprintf('File took %1.2f seconds\n\n\n  ',t1)
        end %file_idx

        if specfile_exists
            load(Ssavefilename, 'Spow_avg','Spow_med','F','fband','file_time')
        else
            save(Ssavefilename, 'Spow_avg','Spow_med','F','fband','file_time')
        end
        %%%%Save statistical data and generate histograms
        

        if do_histograms

            disp('Saving avs histogram data...')
            save(avs_hist_filename,'file_time','avs_hist','-v7.3')
            disp('Save complete.')
            toc

            t_label = {datestr(file_time(1),'yyyymmddTHHMMSS') datestr(file_time(end),'yyyymmddTHHMMSS')};


            for iband = 1:size(fband,1)

                f1 = fband(iband,1);
                f2 = fband(iband,2);
                
		        ax = [];

                % azimuth histogram
   
 		        ax = [];
                title_str = {sprintf('TiDAL %s',tidal_list{itidal}), sprintf('Histogram Freq Band %1.2fkhz-%1.2fkHz',f1/1e3,f2/1e3)};
%                 title_str = cat(2,{sprintf('%s to %s',datestr(time_start_utc),datestr(time_stop_utc))},title_str);
    
                figure('Renderer','zbuffer');
                ssize = get(groot, 'ScreenSize');
                set(gcf, 'Position', ssize);
                tiledlayout(5,1)

                ax(end+1)=nexttile([4 1]);

                avs_hist.AziVsEl.extract_slice('Frequency',fband(iband,:)).sum_slice({'Elevation','Frequency'}).image_2D_slice('MaxnormPerY',true,'pcolor');
                shading flat
%                 clim([-1 0])    
    
                linkaxes(ax,'x'); 
                xlim(ax(1),[min(file_time) max(file_time)])

                title('')
                sgtitle(title_str,'fontsize',14,'fontweight','bold')

                png_savename = fullfile(sprintf('TiDAL%s-%1.2fkHz-%1.2fkHz-az_hist-%s-%s',tidal_list{itidal},f1/1e3,f2/1e3,t_label{1},t_label{2}));
                saveas(gcf,fullfile(savefolder,[png_savename '.png']))
                saveas(gcf,fullfile(savefolder,[png_savename '.fig']))


                figure('Renderer','zbuffer');
                ssize = get(groot, 'ScreenSize');
                set(gcf, 'Position', ssize);
                tiledlayout(5,1)

                ax(end+1)=nexttile([4 1]);

                avs_hist.AziVsEl.extract_slice('Frequency',fband(iband,:)).sum_slice({'Azimuth','Frequency'}).image_2D_slice('MaxnormPerY',true,'pcolor');
                shading flat
                    
    
                linkaxes(ax,'x'); 
                xlim(ax(1),[min(file_time) max(file_time)])

                title('')
                sgtitle(title_str,'fontsize',14,'fontweight','bold')

                png_savename = fullfile(sprintf('%1.2fkHz-%1.2fkHz-el-hist-%s-%s',f1/1e3,f2/1e3,t_label{1},t_label{2}));
                saveas(gcf,fullfile(savefolder,[png_savename '.png']))
                saveas(gcf,fullfile(savefolder,[png_savename '.fig']))

            end
            avs_hist = [];



            
        end

        %% plot long term spectrogram
        avg_type = 'Median';
        switch avg_type
            case 'Median'
                Spowplot = Spow_med;
            case 'Mean'
                Spowplot = Spow_avg;
        end
   
        for ch = 1:size(Spowplot,3)
    
            max_F = min(max(F/1e3),15);
    
            figure('Renderer','zbuffer');
            ssize = get(groot, 'ScreenSize');
            set(gcf, 'Position', ssize);
            pcolor(file_time,F/1e3,10*log10(Spowplot(1:length(file_time),:,ch)).'); shading flat
            colormap jet
            colorbar
            ylim([0 max_F])
            clim([20 90])
            set(gca,'fontweight','bold','fontsize',14);
            set(gca,'XTickLabelRotation',90)
            tax = file_time([1 end]);
            tax = dateshift(tax, 'start', 'minute', 5*round(minute(tax)/5));
            ax2 = gca; ax2.XTick = tax(1):minutes(120):tax(end);
            datetick('x','mm-dd, HH:MM','keepticks')
            
            sgtitle({sprintf('TiDAL %s',tidal_list{itidal}),sprintf('%s: One Minute %s Spectrogram',sensor_type(ch),avg_type)},'fontweight','bold','fontsize',18)
       
            png_savename = sprintf('TiDAL%s-%s-%s-%s',...
                tidal_list{itidal},sensor_type(ch),...
                datetime(file_time(1),'format','yyyyMMdd''T''HHmmSS'),...
                datetime(file_time(end),'format','yyyyMMdd''T''HHmmSS'));

            saveas(gcf,fullfile(savefolder,[png_savename '.png']))
            saveas(gcf,fullfile(savefolder,[png_savename '.fig']))
        end
close all
end
end
