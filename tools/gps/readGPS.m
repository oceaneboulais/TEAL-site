function gpsData = readGPS(filename)
% gpsData = readLatestGPS(filename)
% this function parses a GPS serial log and gets the latest GPS point from
% the $GPGGA line. Use readLatestGPS.m instead to get only the last point.
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

fileID = fopen(filename);

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

gpsData = [];
% Read and parse each line of the file
k = 0;
while ~feof(fileID)
    line = fgetl(fileID);  % Read a line
    if contains(line, '$GPGGA')
        % Parse the sentence and store it in the cell array
        gpsData = [gpsData; parseGPGGA(line,startday)];
    end
end

% Close the file
fclose(fileID);

end
