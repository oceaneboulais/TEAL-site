function ctd_data = readCTD(filename,lat)
% Define the CSV file name
if nargin==0
    filename = '/Volumes/Novus/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231009T182000_20231010T125000/CTD/aml_log_2023-10-09_18-22-30.aml';
end

% Open the file for reading
fileID = fopen(filename, 'r');

% Read lines until the marker is found
while ~feof(fileID)
    line = fgetl(fileID);
    if strcmp(line,'[MeasurementMetadata]')
        % this contains the variable names and units
        data = textscan(fileID, '%[^=]=%s %s %s %s %s %s %s %s %s',1,'Delimiter',',');
        columns= string(vertcat(data{2:end})).'; % remove 'Columns='
        data = textscan(fileID, '%[^=]=%s %s %s %s %s %s %s %s %s',1,'Delimiter',',');
        units = string(vertcat(data{2:end})).'; % remove 'Units='

        % if ~ismember("Pressure",columns)
        %     warning('Pressure missing from this file, skipping file')
        %     ctd_data = [];
        %     return
        % end
    end
    if strcmp(line, '[MeasurementData]')
        % Break when the marker is found
        break;
    end
end

% Read the data from the remaining lines
data = textscan(fileID, '%s %s %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',',');
if isempty(data{1})
    ctd_data = table();
    return
end
% Close the file
fclose(fileID);

% Store the data in a table (optional)
% ctd_data = table(data{1}, data{2}, data{3}, 'VariableNames', 
% {'Date','Time',Battery,Cond,TempCT,SV,TempSVT,pH,Pressure});

% add the raw data to the ctd structure
for ii = 1:length(columns)
    if isempty(columns{ii})
        continue
    end
    ctd_data.(columns{ii}) = data{ii};
end

% get conductivity ratio, conductivity in units mS/cm
CR = ctd_data.Cond/sw_c3515;
ctd_data.Time_UTC =  datetime(string(ctd_data.Date(:)) + " " + string(ctd_data.Time(:)),'format','yyyy-MM-dd HH:mm:ss');
% ctd_data.pressure = data{9}; % pressure in dBar
% ctd_data.temp = [data{5} data{7}]; % temp in C
if ~isfield(ctd_data,'Pressure')
    ctd_data.Pressure = nan(size(ctd_data.TempCT));
end
ctd_data.SalinityCT = sw_salt(CR,ctd_data.TempCT,ctd_data.Pressure);
ctd_data.DensityCT = sw_dens(ctd_data.SalinityCT,ctd_data.TempCT,ctd_data.Pressure);
ctd_data.SoundSpeedCT = sw_svel(ctd_data.SalinityCT,ctd_data.TempCT,ctd_data.Pressure);

if ~isfield(ctd_data,'SV')
    ctd_data.SV = nan(size(ctd_data.TempCT));
    ctd_data.TempSVT = nan(size(ctd_data.TempCT));
    ctd_data.SalinitySVT = nan(size(ctd_data.TempCT));
    ctd_data.DensitySVT = nan(size(ctd_data.TempCT));
    ctd_data.SoundSpeedSVT = nan(size(ctd_data.TempCT));
    ctd_data.SoundSpeedSV = nan(size(ctd_data.TempCT));
else
    ctd_data.SalinitySVT = sw_salt(CR,ctd_data.TempSVT,ctd_data.Pressure);
    ctd_data.SoundSpeedSVT = sw_svel(ctd_data.SalinitySVT,ctd_data.TempSVT,ctd_data.Pressure);
    ctd_data.SoundSpeedSV = ctd_data.SV;   
    ctd_data.DensitySVT = sw_dens(ctd_data.SalinitySVT,ctd_data.TempSVT,ctd_data.Pressure);
end
if ~isfield(ctd_data,'pH')
    ctd_data.pH = nan(size(ctd_data.TempCT));
end
if ~isfield(ctd_data,'Battery')
    ctd_data.Battery = nan(size(ctd_data.TempCT));
end

if 0 %size(ctd_data,2)>8
    units = [units, "UTC", "psu", "psu", "m/s", "m/s", "m/s", "kg/m^3", "kg/m^3", "m"];
else
    units(end) =[];
end
if exist('lat','var')
    ctd_data.Depth = sw_dpth(ctd_data.Pressure,lat);
else
    ctd_data.Depth = nan(size(ctd_data.Pressure));
end

ctd_data = struct2table(ctd_data);
% ctd_data.Properties.VariableUnits = units;