function downloadHYCOMFile(time_list,data_type,save_dir,forecast_days)
% downloads hycom files for the times listed in time_list
% INPUTS:
%   time_list   matlab datetime vector of requested times
%   data_type   character designating variables to download
% (default is 'ts3z')
%               'ts3z' sound speed
%               'uv3z' current
%               'ssh' sea surface height
%   save_dir    directory to save result (default is current directory)
%   forecast    number of forecast days (default = 0)
%               a forecast can be up to 7 days ahead
                

if nargin < 3 || isempty(forecast_days)
    forecast_days = 0;
end
if nargin<3 || isempty(save_dir)
    save_dir = pwd;
end
if nargin < 2 || isempty(data_type)
    data_type = 'ts3z';
end
if nargin==0 || isempty(time_list)
    time_list = datetime(2023,06,02,12,0,0);
end

% for now, hardcode the model selection
hycom_model = 'GLBy0.08';
data_set = 'expt_93.0';
hycom_file_identifier = 'glby_930';

if forecast_days>0
    sub_dir = 'forecasts';
else
    sub_dir = 'hindcasts';
end

% define the expected file size
% we will check this to make sure the whole file was downloaded last time
switch data_type
    case 'ts3z'
        file_size = 3137311344;
    case 'uv3z'
        file_size = 3137311328;
    case 'ssh'
        file_size = 38330768;
end

% forecasts/hindcasts are provided every 3 hours
available_hours = 0:3:21;

if length(forecast_days)==1
    forecast_days = repmat(forecast_days,[1 length(time_list)]);
end

% loop through the list of requested times
for itime = 1:length(time_list)

    time = time_list(itime);

    % find the closest forecast/hindcast time
    [~,closest_idx]= min(abs(hour(time) - available_hours));
    time_in_file = datetime(year(time),month(time),day(time),available_hours(closest_idx),0,0);

    %% get the download URL

    % hycom files start at 12:00
    if hour(time_in_file)<12
        % if the time is before 12:00, it will be in previous day's file
        file_start_time = datetime(year(time_in_file),month(time_in_file),day(time_in_file)-1-forecast_days(itime),12,0,0);
    else
        % if the time is after 12:00, it will be in that days file
        file_start_time = datetime(year(time_in_file),month(time_in_file),day(time_in_file)-forecast_days(itime),12,0,0);
    end

    hours_in_file = hours(time_in_file - file_start_time);

    % hindcasts are stored in a "year" subdirectory, while forecasts are not
    if forecast_days(itime) == 0
        year_subdir = num2str(year(time));
    else
        year_subdir = '';
    end

    hycom_file = sprintf('hycom_%s_%s_t%.3d_%s.nc', hycom_file_identifier,...
        datestr(file_start_time, 'yyyymmddHH'), hours_in_file, data_type);
    out_dir = fullfile(save_dir,hycom_model,data_set,'data',sub_dir,year_subdir);

   
    fprintf('Downloading %s file from %s\n',hycom_file,sub_dir)
    
    url_str = sprintf('https://tds.hycom.org/thredds/fileServer/datasets/%s/%s/data/%s/%s/%s', ...
        hycom_model, data_set, sub_dir, year_subdir, hycom_file);


    if ~isfolder(out_dir)
        mkdir(out_dir)
    end
    savefile = fullfile(out_dir,hycom_file);
    
    if exist(savefile,'file')
        info = dir(savefile);
        % check the size to make sure it was fully downloaded
        if info.bytes < file_size
            tic
            file_out = websave(savefile, url_str);
            toc
        else
            fprintf('File exists. Skipping download.\n')
        end
    else
        tic
        file_out = websave(savefile, url_str);
        toc
    end
    file_list{itime} = savefile;
end


end