function gpsData = readGPS(filename)

fileID = fopen(filename);

yearstr = extractBetween(filename,'.y','d');
daystr = extractAfter(filename,'d');
startday = datetime(str2num(yearstr{:}),1,1) + days(str2num(daystr)-1);

gpsData = [];
% Read and parse each line of the file
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
function gpsData = parseGPGGA(line,start_day)
    % Find the index where '$GPGGA' occurs in the line
    gpggaIndex = strfind(line, '$GPGGA');
    
    % Check if '$GPGGA' was found in the line
    if isempty(gpggaIndex)
        error('No $GPGGA sentence found in the line');
    end
    
    % Extract the substring starting from '$GPGGA'
    gpggaSubstring = line(gpggaIndex:end);
    
    % Split the sentence into individual fields
    fields = strsplit(gpggaSubstring, ',');
    
    % Extract relevant information
    % Parse the day and time
    time = datetime(fields{2},'InputFormat','HHmmss.SS');

% Combine day and time to form a datetime
    gpsData.time_utc = datetime(year(start_day),month(start_day),day(start_day),hour(time),minute(time),second(time));
    gpsData.latitude = degminsec2deg(str2double(fields{3}(1:2)),str2double(fields{3}(3:end)),0);
    if fields{4}=='S'
        gpsData.latitude = -gpsData.latitude;
    end
    gpsData.longitude = degminsec2deg(str2double(fields{5}(1:3)),str2double(fields{5}(4:end)),0);
    if fields{6}=='W'
        gpsData.longitude = -gpsData.longitude;
    end
    gpsData.fixQuality = str2double(fields{7});
    gpsData.numSatellites = str2double(fields{8});
    gpsData.horizontalDilution = str2double(fields{9});
    gpsData.altitude = str2double(fields{10});

    gpsData = struct2table(gpsData);
    
    % Check for valid data
    if isnan(gpsData.latitude) || isnan(gpsData.longitude) || isnan(gpsData.fixQuality) || isnan(gpsData.numSatellites) || isnan(gpsData.horizontalDilution) || isnan(gpsData.altitude)
        error('Invalid or missing data in $GPGGA sentence');
    end
end