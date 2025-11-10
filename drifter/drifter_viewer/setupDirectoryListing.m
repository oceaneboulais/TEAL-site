function app = setupDirectoryListing(app)
display('Loading available files...')
% get a list of all experiment folders in this data directory 
% and make a dropdown selection
app.ExperimentDropDown.Items = getFolders(app.SelectDirectory.Value);

% find available drifters in this directory and add them to the
% dropdown list 
subdirlist = getFolders(fullfile(app.SelectDirectory.Value,app.ExperimentDropDown.Value,'Drifter*'));
app.SelectDrifter.Items = unique(extractBetween(subdirlist,'Drifter','_Acoustic'));

if isempty(subdirlist)
    return
end


drifter_folder = fullfile(app.SelectDirectory.Value,...
                app.ExperimentDropDown.Value);

app.filelist = dir(fullfile(drifter_folder,'**',...
    sprintf('Drifter%i*',str2double(app.SelectDrifter.Value)),'AcousticData','drifter-5V*.wav*'));

% check file size and remove any incopmlete files
filesize = vertcat(app.filelist.bytes);
badfiles = filesize~=294912044;
warning('Removing %i bad files:',sum(badfiles))
app.filelist(badfiles) = [];

filenames = vertcat(app.filelist.name);
file_time_utc = timeFromFilename(filenames);

% %now only get the ones that correspond to selected drifters 
% subdirlist = getFolders(fullfile(app.SelectDirectory.Value,...
%     app.ExperimentDropDown.Value,['Drifter' app.SelectDrifter.Value '*']));

% only enable timeframes contained within the selected
% experiment from the datepicker
tdiff = diff(file_time_utc);
gap_idx = find(tdiff > hours(0.5));   % indices where a gap occurs

% Start of each block: first file + one after each gap
start_idx = [1; gap_idx + 1];

% End of each block: each gap + last file
stop_idx  = [gap_idx; length(file_time_utc)];

% Combine to 2XN array of durations
app.EventTimeRange = [file_time_utc(start_idx) file_time_utc(stop_idx)].';

start_times = app.EventTimeRange(1,:);
stop_times  = app.EventTimeRange(2,:);


app.SelectDate.Limits = [min(start_times) max(stop_times)];
app.SelectDate.Value = min(start_times);

app.SelectHour.Value = hour(min(start_times));
app.SelectMinute.Value = minute(min(start_times));
app.SelectSecond.Value = second(min(start_times));


display('Done loading filelist.')