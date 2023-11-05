function ctd_data = readCTD(filename,lat)
% Define the CSV file name
if nargin==0
    filename = '/Volumes/Novus/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231009T182000_20231010T125000/CTD/aml_log_2023-10-09_18-22-30.aml';
end

% Open the file for reading
fileID = fopen(filename, 'r');

% Initialize variables to store the data
measurementData = [];

% Read lines until the marker is found
while ~feof(fileID)
    line = fgetl(fileID);
    if strcmp(line, '[MeasurementData]')
        % Break when the marker is found
        break;
    end
end

% Read the data from the remaining lines
data = textscan(fileID, '%s %s %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',',');

% Close the file
fclose(fileID);

% Store the data in a table (optional)
% ctd_data = table(data{1}, data{2}, data{3}, 'VariableNames', 
% {'Date','Time',Battery,Cond,TempCT,SV,TempSVT,pH,Pressure});

% get conductivity ratio, conductivity in units mS/cm
CR = data{4}/sw_c3515;
ctd_data.time_utc =  datetime(string(data{1}(:)) + " " + string(data{2}),'format','yyyy-MM-dd HH:mm:ss');
ctd_data.pressure = data{9}; % pressure in dBar
ctd_data.temp = [data{5} data{7}]; % temp in C
ctd_data.salinity = sw_salt(CR,ctd_data.temp,ctd_data.pressure);
ctd_data.sound_speed = sw_svel(ctd_data.salinity,ctd_data.temp,ctd_data.pressure);
ctd_data.density = sw_dens(ctd_data.salinity,ctd_data.temp,ctd_data.pressure);

if exist('lat','var')
    ctd_data.depth = sw_dpth(ctd_data.pressure,lat);
end
ctd_data.sound_speed = [ctd_data.sound_speed data{6}];

ctd_data = struct2table(ctd_data);
