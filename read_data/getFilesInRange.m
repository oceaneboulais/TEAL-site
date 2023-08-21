function [filelist,file_time_utc,filenames] = getFilesInRange(data_dir,time_start_utc,time_stop_utc,ext)

if ~exist('ext','var')
    ext = '.wav';
end

filelist = dir(fullfile(data_dir,['*' ext]));
if isempty(filelist)
    error('No files found!')
end

filenames = vertcat(filelist.name);

% get the date and time in UTC from the filenames, sort them
file_time_utc = timeFromFilename(filenames);
% years = filenames(:,12:15);
% days = filenames(:,17:19);
% months = repmat('0101',[size(years,1) 1]);
% times = filenames(:,21:26);
% 
% 
% file_time_utc = datetime([years months times],'InputFormat','yyyyMMddHHmmss') + str2num(days)-1;

[file_time_utc,sortidx] = sort(file_time_utc);

% file_time_posix = convertTo(file_time_utc,'posixtime');


filelist = filelist(sortidx);
filenames = filenames(sortidx,:);



% find the start and stop files 
% file_idx1 = find(file_time_utc <= time_start_utc,1,'last');
file_idx1 = find(file_time_utc > time_start_utc,1,'first')-1;
file_idx2 = find(file_time_utc > time_stop_utc,1,'first')-1;

filelist = filelist(file_idx1:file_idx2);
filenames = filenames(file_idx1:file_idx2,:);
% file_time_posix = file_time_posix(file_idx1:file_idx2);

%%

% % search recursively in the data directory for all wav files
% filelist = dir(fullfile(drivename,datadir,'**','*.wav'));
% 
% filenames = vertcat(filelist.name);
% 
% % get the date and time in UTC from the filenames, sort them
% years = filenames(:,12:15);
% days = filenames(:,17:19);
% months = repmat('0101',[size(years,1) 1]);
% times = filenames(:,21:26);
% 
% 
% file_time_utc = datetime([years months times],'InputFormat','yyyyMMddHHmmss') + str2num(days)-1;
% [file_time_utc,sortidx] = sort(file_time_utc);
% 
% filelist = filelist(sortidx);
% 
% file_idx1 = find(file_time_utc > t0,1,'first')-1;
% file_idx2 = find(file_time_utc > tend,1,'first')-1;
% 
% Nfiles = file_idx2 - file_idx1;