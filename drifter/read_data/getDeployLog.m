function driftlog = getDeployLog(gitpath,deploy_no)

driftlog_file = fullfile(gitpath,'drifter','Drifter_TFO_deployment_log.xlsx');
opts = detectImportOptions(driftlog_file);
opts = setvartype(opts, 'DeployTimeUTC', 'string');  % or whatever your column is called
opts = setvartype(opts, 'RecoverTimeUTC', 'string');  % or whatever your column is called
driftlog = readtable(driftlog_file,opts);
% driftlog.SunriseUTC = datetime(driftlog.SunriseUTC, "ConvertFrom", "excel",'Format','HH:mm:SS');
% driftlog.SunsetUTC = datetime(driftlog.SunsetUTC, "ConvertFrom", "excel",'Format','HH:mm:SS');

% calculate the sunrise and sunset based on lat/lon/date of drifter dive
[driftlog.SunsetUTC, driftlog.SunriseUTC] = calculateSunriseSunset(...
    driftlog.LatLastSat,driftlog.LonLastSat,driftlog.TimeLastSatUTC);

if exist('deploy_no','var')&~isempty(deploy_no)
    driftlog = driftlog(deploy_no==driftlog.Deployment,:);
end

% deploy_time = driftlog.DeployDateLocal + driftlog.DeployTimeLocal;
% recover_time = driftlog.RecoverDateLocal + driftlog.RecoverTimeLocal;
% driftlog.DeployTimeUTC  = deploy_time + hours(driftlog.TimeZoneOffset);
% driftlog.RecoverTimeUTC = recover_time + hours(driftlog.TimeZoneOffset);

% make sure recover and deploy times are read as datetime arrays
driftlog.DeployTimeUTC = datetime(driftlog.DeployTimeUTC);
driftlog.RecoverTimeUTC =  datetime(driftlog.RecoverTimeUTC);

t0_utc = string(datetime(driftlog.DeployTimeUTC ,'Format','yyyyMMdd''T''HHmmss'));
t0_utc(ismissing(t0_utc)) = '';

tend_utc = string(datetime(driftlog.RecoverTimeUTC,'Format','yyyyMMdd''T''HHmmss'));
tend_utc(ismissing(tend_utc)) = '';


driftlog.event_name  = compose("Drifter%i_Acoustic%i_%s_%s", ...
    driftlog.DrifterNumber,driftlog.AcousticSphere,t0_utc,tend_utc);



