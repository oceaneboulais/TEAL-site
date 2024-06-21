close all, clear all
use_remote_path = true;
[data_basedir,procdata_basedir,gitpath] = setUpDrifterPaths(use_remote_path);
process_all_data = true;

experiment = '2023_Kelvin';

switch experiment
    case '2023_Kelvin'
        ship_gps_files = dir(fullfile(data_basedir,'2023_Fall_Kelvin_Seamount','/MGL2312/raw/serial/MGL-cnav.*'));
        filesavedir = fullfile(procdata_basedir,mfilename,'2023_Fall_Kelvin_Seamount');
    case '2024_Seamounts'
        ship_gps_files = dir(fullfile(data_basedir,'2024_Seamounts','/RR2408/openrvdas/data/RR2408_gnss_gp170_fwd*'));
        filesavedir = fullfile(procdata_basedir,mfilename,'2024_Seamounts');
end
ship_gps_files = dir('/Volumes/cruise/RR2408/openrvdas/data/RR2408_gnss_gp170_fwd*');

filename_out = fullfile(filesavedir,'gps_data_table');

if ~isfolder(filesavedir)
    mkdir(filesavedir);
end

if process_all_data 
    gpsData = [];
    for ii = 1:length(ship_gps_files)
        tic
        fprintf('Processing file %i of %i\n',ii,length(ship_gps_files))
        shipfile = fullfile(ship_gps_files(ii).folder,ship_gps_files(ii).name);
        gpsDataTmp = readGPS(shipfile);
        gpsData = [gpsData; gpsDataTmp];
        toc
    end
else
    %perform a merge with the existing table and the latest data 

    % first read in the existing table
    gpsData = readtable(filename_out);
    max_time = max(gpsData.time_utc);
    % we always want to load the current day to get the missing data points
    max_time = datetime(year(max_time),month(max_time),day(max_time));

    % get the times from the filenames 
    filenames = {ship_gps_files.name};
         
    yearstr = extractBetween(filenames,'.y','d');
    daystr = extractAfter(filenames,'d');
    startday = datetime(str2num(vertcat(yearstr{:})),1,1)...
        + days(str2num(vertcat(daystr{:}))-1);

    % which files do we need to load?
    fileidx = find(startday >= max_time);

    k = 0;
    for ii = fileidx.'
        k = k+1;
        fprintf('Processing file %i of %i\n',k,length(fileidx))
        tic
        shipfile = fullfile(ship_gps_files(ii).folder,ship_gps_files(ii).name);
        gpsDataTmp = readGPS(shipfile);
        gpsData = outerjoin(gpsData,gpsDataTmp,'MergeKeys',true);
        toc
    end

end

gpsData = unique(gpsData,'rows');

writetable(gpsData,filename_out)