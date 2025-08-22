function model = readWCOFSFile(model_version,time_list,lats,lons,depth,save_dir)
% downloads and reads files for the times listed in time_list
% INPUTS:
%   time_list   matlab datetime vector of requested times

                
if ~exist('save_dir','var')||isempty(save_dir)
    % we will attemp to just read this file diretly from the thredds server
    download_file = false;
else
    download_file = true;
end

% forecasts/hindcasts are provided every 3 hours
available_hours = 0:3:21;

% loop through the list of requested times
for itime = 1:length(time_list)

    % look at the requested time 
    time_requested = time_list(itime);

    % find the closest forecast/hindcast time
    % which are only in 3 hour intervals - pick the closest one 
    [~,closest_idx]= min(abs(hour(time_requested) - available_hours));
    time_in_file = datetime(year(time_requested),month(time_requested),day(time_requested),...
        available_hours(closest_idx),0,0);

    % except wcofs forecast file indices start at n003 which correspond to 0600 of that day and go
    % to n024 which correspond to 0300 of the following day
    % so lets figure out which file we want 
    index = hour(time_in_file) - 3;
    if index >0
        % the file to pull is from the same day
        file_start_time = time_in_file;
    else
        % the file to pull is from the previous day
        file_start_time = datetime(year(time_in_file),month(time_in_file),day(time_in_file)-1);
        index = 24 + index;
    end

    %% get the file download URL

    % hours_in_file = hour(time_in_file);

    % hawaii info 
    % rom_file = 'ROMS_Hawaii_Regional_Ocean_Model_Assimilation_best.ncd';
     % url_str = sprintf('https://pae-paha.pacioos.hawaii.edu/thredds/catalog/roms_hiig_assim/catalog.html?dataset=roms_hiig_assim/%s',rom_file);

    rom_filename = sprintf('%s.t03z.%s.regulargrid.f%03d.nc', model_version,...
        datestr(file_start_time, 'yyyymmdd'), index);
    % rom_file = sprintf('%s.t03z.%s.2ds.n%03d.nc', model_version,...
    %     datestr(time_in_file, 'yyyymmdd'), hours_in_file);
    % url_str = sprintf('https://opendap.co-ops.nos.noaa.gov/thredds/catalog/NOAA/WCOFS/MODELS/%d/%02d/%02d/catalog.html?dataset=NOAA/WCOFS/MODELS/%d/%02d/%02d/%s',...
    %     year(time),month(time),day(time),year(time),month(time),day(time),rom_file);
    
    if download_file
        url_str = sprintf('https://opendap.co-ops.nos.noaa.gov/thredds/fileServer/NOAA/WCOFS/MODELS/%d/%02d/%02d/%s',...
            year(file_start_time),month(file_start_time),day(file_start_time),rom_filename);

        out_dir = fullfile(save_dir,model_version);
        if ~isfolder(out_dir)
            mkdir(out_dir)
        end
        rom_file = fullfile(out_dir,rom_filename);

        if exist(rom_file,'file')
        %     info = dir(savefile);
        %     % check the size to make sure it was fully downloaded
        %     if info.bytes < file_size
        %         tic
        %         file_out = websave(savefile, url_str);
        %         toc
        %     else
                fprintf('File exists. Skipping download.\n')
            % end
        else
            fprintf('Downloading %s file %s\n',rom_filename)
            tic
            websave(rom_file, url_str);
            toc
        end
    else
        % otherwise we will use opendap to just get the requested lat/lon
        rom_file = sprintf('https://opendap.co-ops.nos.noaa.gov/thredds/dodsC/NOAA/WCOFS/MODELS/%d/%02d/%02d/%s',...
            year(file_start_time),month(file_start_time),day(file_start_time),rom_filename);
    end
        
    % uncomment to display info about the file:
    %ncdisp(rom_file)
    % Read grid and metadata

    time = ncread(rom_file, 'time');
    time_ref = datetime(2016,1,1,0,0,0);  % 'seconds since 2016-01-01 00:00:00'
    % t_units = ncreadatt(rom_file, 'time', 'units');  
    time_grid = time_ref + seconds(time);
   
    % lets make sure we've made all the right assumptions about time 
    if (time_grid ~= time_in_file) || hours(time_requested - time_in_file)>3
        error('Time assumptions are not valid')
    end

    lat_grid = ncread(rom_file, 'Latitude');
    lon_grid = ncread(rom_file, 'Longitude');
    depth_grid = ncread(rom_file,'Depth');

    % find the minimum and maximum lat/lon that i requested 

    % assume lat -90 to 90, and lon is -180 to 180 as convention 
    % but note that because this is SoCal I dont' have to worry about 0/360
    % crossing 
    lat_ends = [min(lats) max(lats)];
    lon_ends = [min(lons) max(lons)];

    % find box 
    IN = (lon_grid >= lon_ends(1)) & (lon_grid <= lon_ends(2)) & ...
     (lat_grid >= lat_ends(1)) & (lat_grid <= lat_ends(2));

    % find the smallest and largest indices for the box
    [iy, ix] = find(IN);
    iy0 = min(iy);  iy1 = max(iy);
    ix0 = min(ix);  ix1 = max(ix);

    if isempty(depth)
        depth = depth_grid;
        iz0 = 1; iz1 = length(depth_grid);
    else
        [~,iz0] = min(abs(depth_grid - min(depth)));
        [~,iz1] = min(abs(depth_grid - max(depth)));
    end
    % find the size of each slice
    ny = iy1 - iy0 + 1; 
    nx = ix1 - ix0 + 1;
    nz = iz1 - iz0 + 1;

    tidx = 1;

    model.time = time_grid;
    model.depth = depth_grid(iz0:iz1);
    model.temp = ncread(rom_file, 'temp', ...
              [iy0  ix0  iz0   tidx], ...   % [start_y  start_x  start_depth  start_time]
              [ny   nx   nz  1   ]);     % [count_y  count_x  all_depths   1 time]
    model.salt = ncread(rom_file, 'salt', ...
              [iy0  ix0  iz0   tidx], ...   % [start_y  start_x  start_depth  start_time]
              [ny   nx   nz  1   ]);     % [count_y  count_x  all_depths   1 time]
    model.u_eastward = ncread(rom_file, 'u_eastward', ...
              [iy0  ix0  iz0   tidx], ...   % [start_y  start_x  start_depth  start_time]
              [ny   nx   nz  1   ]);     % [count_y  count_x  all_depths   1 time]
    model.v_northward = ncread(rom_file, 'v_northward', ...
              [iy0  ix0  iz0   tidx], ...   % [start_y  start_x  start_depth  start_time]
              [ny   nx   nz  1   ]);     % [count_y  count_x  all_depths   1 time]
    model.lat = lat_grid(iy0:iy1,ix0:ix1);
    model.lon = lon_grid(iy0:iy1,ix0:ix1);
    % bathy  = ncread(rom_file, 'h', ...
    %           [iy0  ix0  iz0   tidx], ...   % [start_y  start_x  start_depth  start_time]
    %           [ny   nx   nz  1   ]);     % [count_y  count_x  all_depths   1 time]
    % ssh = ncread(rom_file, 'zeta', ...
    %   [iy0  ix0  1   tidx], ...   % [start_y  start_x  start_depth  start_time]
    %   [ny   nx   Inf  1   ]);     % [count_y  count_x  all_depths   1 time]
end


end