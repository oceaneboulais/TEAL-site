function driftlog = getDeployLog(gitpath,deploy_no)

driftlog_file = fullfile(gitpath,'drifter','TFO_Drifter_deployment_log.xlsx');
driftlog = readtable(driftlog_file);
driftlog.SunriseUTC = datetime(driftlog.SunriseUTC, "ConvertFrom", "excel",'Format','HH:mm:SS');
driftlog.SunsetUTC = datetime(driftlog.SunsetUTC, "ConvertFrom", "excel",'Format','HH:mm:SS');

if exist('deploy_no','var')&~isempty(deploy_no)
    driftlog = driftlog(deploy_no==driftlog.Deployment,:);
end

% deploy_time = driftlog.DeployDateLocal + driftlog.DeployTimeLocal;
% recover_time = driftlog.RecoverDateLocal + driftlog.RecoverTimeLocal;
% driftlog.DeployTimeUTC  = deploy_time + hours(driftlog.TimeZoneOffset);
% driftlog.RecoverTimeUTC = recover_time + hours(driftlog.TimeZoneOffset);

t0_utc = string(datetime(driftlog.DeployTimeUTC ,'Format','yyyyMMdd''T''HHmmss'));
t0_utc(ismissing(t0_utc)) = '';

tend_utc = string(datetime(driftlog.RecoverTimeUTC,'Format','yyyyMMdd''T''HHmmss'));
tend_utc(ismissing(tend_utc)) = '';


driftlog.event_name  = compose("Drifter%i_Acoustic%i_%s_%s", ...
    driftlog.DrifterNumber,driftlog.AcousticSphere,t0_utc,tend_utc);



