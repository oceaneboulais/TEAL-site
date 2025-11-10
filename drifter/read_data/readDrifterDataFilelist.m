function [y,t,fs,file_time_utc,filename,cfg_file] = readDrifterDataFilelist(drifter_num,time_start_utc,time_stop_utc,filelist,calibration)
% reads drifter .wav files and applies calibration 
% INPUTS:
%   drifter_num:    drifter number to load for this time
%   time_start_utc  datetime for start time to read
%   time_stop_utc:  datetime for end time to read
%   datadir:        main directory where data is located
%   calibration:    type of calibration to apply (0-no calibration, 1-freq
%                           indep calibratoin)
% OUTPUTS: 
%   y: time series data Ntimes x Nchannels
%   t: datetime vector for time series 
%   fs: sample rate of data 
%   file_time_utc:  list of available file times

% Alison B. Laferriere

% if isfolder(fullfile(datadir,'AcousticData'))
%     filelist = dir(fullfile(datadir,'AcousticData','drifter-5V*.wav*'));
% elseif iscell
%     filelist = dir(fullfile(datadir,'**',sprintf('Drifter%i*',drifter_num),'AcousticData','drifter-5V*.wav*'));
% end
if isempty(filelist)
    error('No files specified!')
end

% if not specified, do not calibrate
if ~exist('calibration','var')
    calibration = 0;
end

basedatadir = unique({filelist.folder});
for ii = 1:length(basedatadir)
    cfg_file_tmp = dir(fullfile(basedatadir{ii},'acoustic_*.txt'));
    cfg_file{ii} = fullfile(cfg_file_tmp.folder,cfg_file_tmp.name);
end

[filelist,file_time_utc,filenames] = getFilesInRange(filelist,time_start_utc,time_stop_utc);

% filenames = vertcat(filelist.name);
% 
% 
% 
% % get the date and time in UTC from the filenames, sort them
% 
% years = filenames(:,12:15);
% days = filenames(:,17:19);
% months = repmat('0101',[size(years,1) 1]);
% times = filenames(:,21:26);
% 
% 
% 
% 
% file_time_utc = datetime([years months times],'InputFormat','yyyyMMddHHmmss') + str2num(days)-1;
% 
% % i think they should be in order already, but just in case
% [file_time_utc,sortidx] = sort(file_time_utc);
% filelist = filelist(sortidx);
% filenames = filenames(sortidx,:);

file_time_diff = diff(file_time_utc);

% % we are going to set the time of the file based on n=0 files to avoid
% % jumps in time because of bad time stamps 
% % find any times the file counter restarted 
% filenum = str2num(filenames(:,33:37));
% file00 = find(filenum==0);
% 
% for zero_idx = file00
%     % base all the times for files from this file up to the next 0 file 
%     % on the file size
% end


file_time_posix = convertTo(file_time_utc,'posixtime');





% find the start and stop files 
file_idx1 = 1;
file_idx2 = length(file_time_utc);
% file_idx1 = find(file_time_utc <= time_start_utc,1,'last');
% file_idx1 = find(file_time_utc > time_start_utc,1,'first')-1;
% file_idx2 = find(file_time_utc > time_stop_utc,1,'first')-1;
% if isempty(file_idx2)
%     file_idx2 = length(file_time_utc);
% end
% check for continuity in the current selection
% file_time_diff = diff(file_time_utc(file_idx1:file_idx2));
% if ~all(file_time_diff == minutes(1))
%     warning('Time gap, adjusting file times!')
%     % several files have 1 second jumps in the timestamp
%     % if time gap is less than 2 seconds, 
%     % adjust the time stamps so there is no time gap, assume continuity 
%     if max(file_time_diff)<minutes(1)+seconds(2)
%         file_time_utc_tmp = file_time_utc(file_idx1) + (0:(total_samples-1))*minutes(1);
%     else
%         error('Time gap too large!')
%     end
% 
% end

if isempty(file_time_utc)||isempty(file_idx1)||isempty(file_idx2)
    warning('Requested time out of available timerange')
    y = [];
    t = [];
    fs = [];
    filename = [];
    return
end

% convert everything to posix, find the start and stop samples
file1_time = file_time_posix(file_idx1);
file2_time = file_time_posix(file_idx2);
start_time = convertTo(time_start_utc,'posixtime');
stop_time = convertTo(time_stop_utc,'posixtime');

% get the start and stop sample number for the first and last file
info = audioinfo(fullfile(filelist(file_idx1).folder,filelist(file_idx1).name));
start_sample = round((start_time - file1_time)*info.SampleRate)+1;
stop_sample = round((stop_time - file2_time)*info.SampleRate)+1;



y = [];
t = [];
t_tmp = [];
k = 0;
for idx = file_idx1:file_idx2
    k = k+1;
    info = audioinfo(fullfile(filelist(idx).folder,filelist(idx).name));
%     if idx ==file_idx1
%         fs = info.SampleRate;
%         samples = info.TotalSamples;
%     else
%         if fsread~=fs
%             error('Different sample rates!')
%         end
%         if samples~=info.TotalSamples
%             warning('Different number of samples in this file')
%         end
%     end
    if idx == file_idx1 && idx == file_idx2
        % there is only one file in the selection
        start_idx = start_sample;
        stop_idx = min(stop_sample,info.TotalSamples);
    elseif idx == file_idx1
        % this is the first file in the selection
        start_idx = start_sample;
        stop_idx = info.TotalSamples;
    elseif idx == file_idx2
        % this is the last file in the selection
        start_idx = 1;
        stop_idx = min(stop_sample,info.TotalSamples);
    else
        % this is a file in between, use all samples
        start_idx = 1;
        stop_idx = info.TotalSamples;
    end

    if start_idx>info.TotalSamples
        warning('Start sample larger than total samples in file!')
        y_tmp = [];
        t_tmp = [];
        fs = [];
        filename{k} = [];
       continue 
    end
    filename{k} = fullfile(filelist(idx).folder,filelist(idx).name);
    fprintf('Loading file %s\n',filelist(idx).name)
    thisfile_time = file_time_posix(idx);

    tic
    [y_tmp,fs] = audioread(filename{k},[start_idx stop_idx]);
    toc

    [Nsamples,Nch] = size(y_tmp);

    if ~isempty(t_tmp)
        tend_lastfile = t_tmp(end);
        t_tmp = thisfile_time:(1/fs):(thisfile_time + (info.TotalSamples-1)/fs);
        t_tmp = t_tmp(start_idx:stop_idx);
%         t_tmp = datetime(t_tmp,'ConvertFrom','posixtime');
        
        tdiff = t_tmp(1)-tend_lastfile;
        if tdiff>=2*(1/fs)
            warning('Time gap detected')
%             keyboard
        end
    else
        t_tmp = thisfile_time:(1/fs):(thisfile_time + (info.TotalSamples-1)/fs);
        t_tmp = t_tmp(start_idx:stop_idx);
%         t_tmp = datetime(t_tmp,'ConvertFrom','posixtime');
    end

    % channels are hydrophones 1-8, vec sens 9-11, nothing 12-16
    switch calibration
        case 0
            % no calibration
        case 1
            % freq indep calibration
            sens_dB = [-145*ones(1,8) -163 -160*ones(1,2) zeros(1,5)];
            y_tmp = y_tmp.* (10.^(-sens_dB/20));
%         case 2
%             % freq dep calibration
%             % this will be very slow, replace with a filter or STFT
%           nfft = 2^nextpow2(size(y_tmp,1));
%           Yf = fft(y_tmp,nfft,1);
%           f = fs*(0:(nfft-1))/nfft;
%           hydro_sens = getSensitivity(f,'HTI-92WB');
%           omni_sens = getSensitivity(f,'GTI-M35-300-omni');
%           directional_sens = getSensitivity(f,'GTI-M35-300-directional');
% 
%           
%           sens_dB = [hydro_sens(:).*ones(1,8) omni_sens(:) directional_sens(:).*ones(1,2) zeros(nfft,5)];
%           Yf = Yf.* (10.^(-sens_dB/20));
%           y_ifft = ifft(Yf,nfft,'symmetric');
%           y_tmp = y_ifft(1:size(y_tmp,1),:);
    end

    y = [y; y_tmp];
    t = [t; t_tmp(:)];
end
t = datetime(t,'ConvertFrom','posixtime');
