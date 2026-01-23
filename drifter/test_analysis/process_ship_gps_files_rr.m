close all, clear all
use_remote_path = true;
[data_basedir,procdata_basedir,gitpath] = setUpDrifterPaths(use_remote_path);
process_all_data = true;

ship_gps_files = dir(fullfile(data_basedir,'2024_Jun_Seamounts/RR2408/openrvdas/data/RR2408_gnss_gp170_fwd*.txt'));
% ship_gps_files = dir('/Volumes/Novus/ONR_DRIFTER/2024_Jun_Seamounts/RR2408/openrvdas/data/RR2408_gnss_gp170_fwd*.txt');%-2024-06-16.txt';

% gpsDataTmp = readGPS(ship_gps_files);

% gpsData = unique(gpsDataTmp,'rows');



filesavedir = fullfile(procdata_basedir,mfilename,'2024_Jun_Seamounts');
if ~isfolder(filesavedir)
    mkdir(filesavedir);
end
% 
filename_out = fullfile(filesavedir,'gps_data_table');
% writetable(gpsData,filename_out)
% 


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

    startday = datetime(extractBetween(filenames,'RR2408_gnss_gp170_fwd-','.txt'));
 


    % which files do we need to load?
    fileidx = find(startday >= max_time);

    k = 0;
    for ii = fileidx
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