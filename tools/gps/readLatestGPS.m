function gpsData = readLatestGPS(filename)
% gpsData = readLatestGPS(filename)
% this function parses a GPS serial log and gets the latest GPS point from
% the $GPGGA line. Use readGPS.m instead to parse the whole file.
% INPUT: filename of gps log 
% OUTPUT: gpsData, a table with variables:
%   time_utc
%   latitude
%   longitude
%   fixQuality 
%   numSatellites
%   horizontalDilution
%   altitude
%
% A. Laferriere, 2024

fileID = fopen(filename, 'rt');

% the GPS time in the $GPGGA line is a relative time to the date
% lets get the date for the filename, which will depend on the format of
% the file name. 

[~,fname,ext]= fileparts(filename);
if strcmp(fname,'MGL-cnav')
    % this was the file format used on the Langseth, the number after .y is
    % .y[YYYY]d[DDD] where [YYYY] is the year and [DDD] is the year day
    yearstr = extractBetween(ext,'.y','d');
    daystr = extractAfter(ext,'d');
    startday = datetime(str2num(yearstr{:}),1,1) + days(str2num(daystr)-1);
elseif contains(fname,'_gnss_')&&contains(fname,'RR')
    % these were the file formats used on the Roger Revelle 
    % the date came last in the filename as yyyy-mm-dd.txt
    startday = datetime(filename(end-13:end-4),'InputFormat','yyyy-MM-dd');
else
    error('check GPS file format and make sure it is compatible')
end

% Move to the end of the file
fseek(fileID, 0, 'eof');

gpsData = [];
k = 0;

% Read the file from end to start to find the last valid GPS data point
buffer = '';
while ftell(fileID) > 0
    fseek(fileID, -1, 'cof');  % Move the pointer back one character
    char = fread(fileID, 1, '*char');  % Read one character
    fseek(fileID, -1, 'cof');  % Move the pointer back one character again
    if char == newline
        line = buffer;
        buffer = '';
        
        % if (contains(line, '$GPGNS') || contains(line, '$GPZDA') || contains(line, '$GPDTM')) && k == 0
        %     startdaystr = extractBefore(line, 'T');
        %     startday = datetime(startdaystr);
        %     k = 1;
        if contains(line, '$GPGGA')
            if isempty(startday)
                continue;
            end
            % Parse the sentence and store it in gpsData
            gpsData = parseGPGGA(line, startday);
            break;  % Exit the loop after finding the last valid GPS data point
        end
    else
        buffer = [char buffer];  % Prepend the character to the buffer
    end
end

% Close the file
fclose(fileID);

end

% function gpsData = parseGPGGA(line, start_day)
%     % Find the index where '$GPGGA' occurs in the line
%     gpggaIndex = strfind(line, '$GPGGA');
% 
%     % Check if '$GPGGA' was found in the line
%     if isempty(gpggaIndex)
%         error('No $GPGGA sentence found in the line');
%     end
% 
%     % Extract the substring starting from '$GPGGA'
%     gpggaSubstring = line(gpggaIndex:end);
% 
%     % Split the sentence into individual fields
%     fields = strsplit(gpggaSubstring, ',');
% 
%     % Extract relevant information
%     % Parse the day and time
%     time = datetime(fields{2}, 'InputFormat', 'HHmmss.SS');
% 
%     % Combine day and time to form a datetime
%     gpsData.time_utc = datetime(year(start_day), month(start_day), day(start_day), hour(time), minute(time), second(time));
%     gpsData.latitude = degminsec2deg(str2double(fields{3}(1:2)), str2double(fields{3}(3:end)), 0);
%     if fields{4} == 'S'
%         gpsData.latitude = -gpsData.latitude;
%     end
%     gpsData.longitude = degminsec2deg(str2double(fields{5}(1:3)), str2double(fields{5}(4:end)), 0);
%     if fields{6} == 'W'
%         gpsData.longitude = -gpsData.longitude;
%     end
%     gpsData.fixQuality = str2double(fields{7});
%     gpsData.numSatellites = str2double(fields{8});
%     gpsData.horizontalDilution = str2double(fields{9});
%     gpsData.altitude = str2double(fields{10});
% 
%     gpsData = struct2table(gpsData);
% 
%     % Check for valid data
%     if isnan(gpsData.latitude) || isnan(gpsData.longitude) || isnan(gpsData.fixQuality) || isnan(gpsData.numSatellites) || isnan(gpsData.horizontalDilution) || isnan(gpsData.altitude)
%         error('Invalid or missing data in $GPGGA sentence');
%     end
% end
