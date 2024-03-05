function file_time_utc = timeFromFilename(filenames)

% returns the time from the Drifter filename
years = filenames(:,12:15);
days = filenames(:,17:19);
months = repmat('0101',[size(years,1) 1]);
times = filenames(:,21:26);


file_time_utc = datetime([years months times],'InputFormat','yyyyMMddHHmmss') + str2num(days)-1;