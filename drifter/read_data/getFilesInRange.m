function [filelist,file_time_utc,filenames] = getFilesInRange(data_dir,time_start_utc,time_stop_utc,ext)

if ~exist('ext','var')
    ext = '.wav';
end

% allow "data_dir" variable to be either a directory name or a list of
% files
if ischar(data_dir)||isstring(data_dir)
    if isfolder(fullfile(data_dir,'AcousticData'))
        filelist = dir(fullfile(data_dir,'AcousticData',['drifter*' ext]));
    else
        filelist = dir(fullfile(data_dir,['drifter*' ext]));
    end
else
    filelist = data_dir;
end

if isempty(filelist)
    warning('No files found!')
    file_time_utc = [];
    filenames = [];
    return
end


filenames = vertcat(filelist.name);

% check file size and remove any zero byte files 
filesize = vertcat(filelist.bytes);
badfiles = filesize==0;
warning('Removing %i bad files:',sum(badfiles))
display(filenames(filesize==0,:))
filenames(filesize==0,:) = [];
filelist(filesize==0) = [];

[~,~,ext] = fileparts(filenames(1,:));


% get the date and time in UTC from the filenames, sort them
switch ext
    case '.wav'
        file_time_utc = timeFromFilename(filenames);
    case '.mat'
        file_time_utc = datetime(filenames(:,end-16:end-4),'InputFormat','yyMMdd''T''HHmmSS');
end
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

file_duration_sec = 60;

% find the start and stop files 
% file_idx1 = find(file_time_utc <= time_start_utc,1,'last');
% file_idx1 = find(time_start_utc>=file_time_utc & time_start_utc<(file_time_utc+seconds(file_duration_sec)),1,'first');
% file_idx2 = find(time_stop_utc>=file_time_utc & time_stop_utc<(file_time_utc+seconds(file_duration_sec)),1,'first');

file_idx1 = find(file_time_utc+seconds(file_duration_sec)>=time_start_utc&file_time_utc<=time_stop_utc,1,'first');
file_idx2 = find(file_time_utc<=time_stop_utc&file_time_utc+seconds(file_duration_sec)>=time_start_utc,1,'last');

if isempty(file_idx2)
    file_idx2 = length(file_time_utc);
end


filelist = filelist(file_idx1:file_idx2);
filenames = filenames(file_idx1:file_idx2,:);

switch ext
    case '.wav'
        file_time_utc = timeFromFilename(filenames);
    case '.mat'
        file_time_utc = datetime(filenames(:,end-16:end-4),'InputFormat','yyMMdd''T''HHmmSS');
end

% file_time_utc = timeFromFilename(filenames);
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