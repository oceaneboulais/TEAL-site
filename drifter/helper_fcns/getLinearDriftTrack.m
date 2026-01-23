function [drift_time,drift_lat,drift_lon,drift_speed_mps,drift_speed_kts] = ...
    getLinearDriftTrack(driftlog,deployments,dt)
% Approximate the drifter track from the last GPS fix before it dove and
% the first satelite fix after it surfaces. These are stored in the
% "TFO_Drifter_deployment_log.xlsx" spreadsheet which can be read in matlab to create
% the table "driftlog" via the function getDeployLog.m 
%
% INPUTS
%   driftlog: table returned from function getDeployLog
%   deployment: the deployment number for which you want the tracks
%       according to the drifter log spreadsheet
%   dt: (optional) time in seconds to sample the track, default is 60
%
% OUTPUTS
%   drift_time: a cell ar
%   lon
%
% A. Laferriere 2024
do_interp = false;
if ~exist('dt','var')
    dt = 60;
elseif ~isscalar(dt)
    % then it is a vector of times
    do_interp = true;
end



for deploy_idx = 1:length(deployments)

    % there will be a deployment entry for each "dive" in the log
    deploy_id = find(driftlog.Deployment == deployments(deploy_idx));

    for dive_idx = 1:length(deploy_id)
        di = deploy_id(dive_idx);
        if any(isnan([driftlog.LatLastSat(di) driftlog.LonLastSat(di) driftlog.LatFirstSat(di) driftlog.LonFirstSat(di)]))
            warning('No GPS fix data for this dive')
            drift_lat{deploy_idx,dive_idx} = nan; 
            drift_lon{deploy_idx,dive_idx} = nan;
            drift_time{deploy_idx,dive_idx} = NaT;
            continue
        end
        if do_interp
            drift_time{deploy_idx,dive_idx} = dt;
        else
            drift_time{deploy_idx,dive_idx} = driftlog.TimeLastSatUTC(di):seconds(dt):driftlog.TimeFirstSatUTC(di);
        end
        % get GPS points for tracks along the ellipsoid 
        [lattrk,lontrk] = track2(driftlog.LatLastSat(di),driftlog.LonLastSat(di),...
            driftlog.LatFirstSat(di),driftlog.LonFirstSat(di),wgs84Ellipsoid);

        % compute the distance from the first poitn to the last point
        drift_dist_m = distance(driftlog.LatLastSat(di),driftlog.LonLastSat(di),...
            driftlog.LatFirstSat(di),driftlog.LonFirstSat(di),wgs84Ellipsoid);
        
        % ** assume the drifter drifted at a constant speed **
        drift_time_utc = linspace(driftlog.TimeLastSatUTC(di),driftlog.TimeFirstSatUTC(di),length(lattrk));
        
        drift_speed_mps = drift_dist_m/seconds(drift_time_utc(end) - drift_time_utc(1));
        drift_speed_kts = 1.94384*drift_speed_mps;

        drift_lat{deploy_idx,dive_idx} = interp1(drift_time_utc,lattrk,drift_time{deploy_idx,dive_idx});
        drift_lon{deploy_idx,dive_idx} = interp1(drift_time_utc,lontrk,drift_time{deploy_idx,dive_idx});

        
    end
end