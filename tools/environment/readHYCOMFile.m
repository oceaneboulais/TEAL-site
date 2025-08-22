function hycom = readHYCOMFile(time_list,lon_list,lat_list,data_type,save_dir,forecast_days)
% reads hycom files for the times listed in time_list
% files can be downloaded with companion function downloadHYCOMFile.m
% data is itnerplated from HYCOM grid to lat_list and lon_list using interp2
%
% INPUTS:
%   time_list   matlab datetime vector of requested times
%   lat_list    latitudes at which to interpolate the data
%   lon_list    longitudes at which to itnerpolate the data
%   data_type   character designating variables to download
% (default is 'ts3z')
%               'ts3z' sound speed
%               'uv3z' current
%               'ssh' sea surface height
%   save_dir    directory to save result (default is current directory)
%   forecast    number of forecast days (default = 0)

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
    lat_list = 32.5;
    lon_list = -120;
end

[M,N] = size(lat_list);

if size(lon_list,1)~=M | size(lon_list,2)~=N
    error('Icompatible dimensions!')
end
if M>1 & N>1 
    % this is a grid not a list of points
    lats = lat_list(:); 
    lons = lon_list(:);
else
    lats = lat_list;
    lons = lon_list;
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

% times in the file are provided in hours since 2000-01-01 00:00:00
t0 = datetime(2000, 1, 1, 0, 0, 0);  

% forecasts/hindcasts are provided every 3 hours
available_hours = 0:3:21;

% this is to allow different forecast days per file
if length(forecast_days)==1
    forecast_days = repmat(forecast_days,[1 length(time_list)]);
end

%%  loop through the list of requested times
for itime = 1:length(time_list)

    time = time_list(itime);
    
     % find the closest forecast/hindcast time
    [~,closest_idx]= min(abs(hour(time) - available_hours));
    time_in_file = datetime(year(time),month(time),day(time),available_hours(closest_idx),0,0);

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

    hycom_file_path = fullfile(out_dir,hycom_file);

    % url = sprintf('http://tds.hycom.org/thredds/dodsC/%s/%s/%s/%s',hycom_model,data_set,data_type,year_subdir);

    % hycom_file_path = fullfile(url,hycom_file);
    
    fprintf('Loading %s file from %s\n',hycom_file,sub_dir)

    % Open once, reuse the handle
    % ncid = netcdf.open(url,'NOWRITE');
    % time_id   = netcdf.inqVarID(ncid,'time');
    % time_vals = netcdf.getVar(ncid,time_id,'double');  % numeric time axis
    
    % represent date as number of hours since January 1, 2000
    hycom.time(itime) = hours(ncread(hycom_file_path,'time')) + t0; 


    
    
    %% find the closest lat/lon points
    latgrid = ncread(hycom_file_path,'lat').';
    longrid = ncread(hycom_file_path,'lon');
    depth = ncread(hycom_file_path,'depth');

    if longrid(1)==0
        lons = wrapTo360(lons);
    else
        lons = wrap360(lons+180)-180;
    end
    
    % search lat lon

    lat_idx(1) = find(min(lats)>latgrid,1,'last');
    lat_idx(2) = find(max(lats)<=latgrid,1,'first');
    latidx = lat_idx(1):lat_idx(2);
    
    
    lon_idx(1) = find(min(lons)>longrid,1,'last');
    lon_idx(2) = find(max(lons)<=longrid,1,'first');
    lonidx = lon_idx(1):lon_idx(2);

    % the data in the netcdf is in dimensions 
    %  Longitude x Latitude x Depth x Time
    Ndays = 1; % how many days to load at a time 
    Nstart = [lon_idx(1) lat_idx(1) 1 1];
    Ncount = [numel(lonidx) numel(latidx) length(depth) Ndays];
    Nstride = [1 1 1 1];

    %% Read data from file 
    % temperature, salinity, or currents
    
    hycom.depth_m = depth; % [m]

    switch data_type
        case 'ts3z'
            salinity = ncread(hycom_file_path,'salinity',Nstart,Ncount,Nstride); % [psu]   (lon, lat, depth)
            water_temp = ncread(hycom_file_path,'water_temp',Nstart,Ncount,Nstride); % [degC]  (lon, lat, depth)

            % Interpolate temperature and salinity.
            for depth_idx = 1:length(hycom.depth_m)
                hycom.salt_psu(:,:,depth_idx,itime) = reshape(interp2(latgrid(latidx), longrid(lonidx), salinity(:,:,depth_idx), lats,lons),[M,N]);
                hycom.temp_degC(:,:,depth_idx,itime) = reshape(interp2(latgrid(latidx), longrid(lonidx), water_temp(:,:,depth_idx), lats,lons),[M,N]);
            end

        case 'uv3z'
            water_u = ncread(hycom_file_path,'water_u',Nstart,Ncount,Nstride); % Eastward Water Velocity [m/s]   (lon, lat, depth)
            water_v = ncread(hycom_file_path,'water_v',Nstart,Ncount,Nstride); % Northward Water Velocity [m/s]  (lon, lat, depth)

            % interpolate currents 
            for depth_idx = 1:length(hycom.depth_m)
                hycom.water_east_mps(:,:,depth_idx,itime) = reshape(interp2(latgrid(latidx), longrid(lonidx), water_u(:,:,depth_idx), lats,lons),[M,N]);
                hycom.water_north_mps(:,:,depth_idx,itime) = reshape(interp2(latgrid(latidx), longrid(lonidx), water_v(:,:,depth_idx), lats,lons),[M,N]);
            end
    end

    hycom.lat = lat_list;
    hycom.lon = lon_list;
    % hycom.time = time_in_file;

end