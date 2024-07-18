function app = setupDirectoryListing(app)

% get a list of all experiment folders in this data directory 
% and make a dropdown selection
app.ExperimentDropDown.Items = getFolders(app.SelectDirectory.Value);

% find available drifters in this directory and add them to the
% dropdown list 
subdirlist = getFolders(fullfile(app.SelectDirectory.Value,app.ExperimentDropDown.Value,'Drifter*'));
app.SelectDrifter.Items = unique(extractBetween(subdirlist,'Drifter','_Acoustic'));

%now only get the ones that correspond to selected drifters 
subdirlist = getFolders(fullfile(app.SelectDirectory.Value,...
    app.ExperimentDropDown.Value,['Drifter' app.SelectDrifter.Value '*']));

% only enable timeframes contained within the selected
% experiment from the datepicker
start_times = datetime(extractBetween(subdirlist,20,34));
stop_times = datetime(extractBetween(subdirlist,36,50));
app.EventTimeRange = [start_times(:) stop_times(:)];

app.SelectDate.Limits = [min(start_times) max(stop_times)];
app.SelectDate.Value = min(start_times);