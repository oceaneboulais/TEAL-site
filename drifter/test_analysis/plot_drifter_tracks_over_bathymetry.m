close all, clear all

% add ship GPS tracks over the map?
add_ship_track = false;

% create an additional figure iwth the dive profile and control status for
% each dive?
plot_driftcam_status = false; 

use_remote_path = true;
[data_basedir,procdata_basedir,gitpath,envdir]= setUpDrifterPaths(use_remote_path);

gebfile = '/Volumes/homes/alaferriere/Databases/GEBCO_2021.nc'; % this is the bathymetry data file

driftlog_file = fullfile(gitpath,'drifter','TFO_Drifter_deployment_log.xlsx');
driftlog = getDeployLog(gitpath);

if add_ship_track
    ship_gps_file = fullfile(procdata_basedir,'process_ship_gps_files','2023_Fall_Kelvin_Seamount','gps_data_table.txt');
    gpsData = readtable(ship_gps_file);
end

% plot all these deployments on one map:
deployment =[14:16];

%% set some plotting options 
markercolors = lines(length(deployment));
% markercolors = {'m','b','r','b','c','g'};

markersize = 12;

add_label = false;

% lat_width = 0.75; Kelvin
% lon_width = 1.5;
% lat_width = 0.15;
% lon_width = 0.15;
% lat_width = 0.25;
% lon_width = 0.25;
lat_width = 1;
lon_width = 1;
scale_ruler = [0:5:15];

in_these_deployments = ismember(driftlog.Deployment,deployment);
if ~isempty(deployment)
    lon_center = mean([driftlog.LonLastSat(in_these_deployments);driftlog.LonFirstSat(in_these_deployments)],'omitnan');
    lat_center = mean([driftlog.LatLastSat(in_these_deployments);driftlog.LatFirstSat(in_these_deployments)],'omitnan');
else
    lon_center = -63.9;
    lat_center =38.85;
end

lon_limits = [lon_center-lon_width/2, lon_center+lon_width/2];
lat_limits = [lat_center-lat_width/2, lat_center+lat_width/2];

lons = lon_limits(1):0.001:lon_limits(2);
lats = lat_limits(1):0.001:lat_limits(2);

%% get the bathymetry 
[LATS,LONS] = meshgrid(lats,lons);
elev = getElevationGEBCO(LONS(:), LATS(:),gebfile);
bathymetry = reshape(elev,size(LATS));

%% get the approximate drifter tracks from the log entries
[drift_time,drift_lat,drift_lon] = getLinearDriftTrack(driftlog,deployment);

%% make the plot of bathymetry using a map axis
f1=figure;
ax = axesm('MapProjection','mercator');
setm(ax,'MapLatLimit',[min(lats) max(lats)])
setm(ax,'MapLonLimit',[min(lons) max(lons)])
setm(ax,'MLineLocation',lon_width/8,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/8,...
    'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
    'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
axis off; framem on; gridm on; tightmap
geoshow(LATS,LONS,bathymetry,'displaytype','texturemap')
hold on
[C,h]=contourm(LATS,LONS,bathymetry,'k');
t=clabelm(C,h,'labelspacing',2000);
set(t,'BackgroundColor','none')
% set (t, 'VerticalAlignment', 'cap')

%% now add a track for each deployment and each dive
if plot_driftcam_status
    f2=figure(2);
    tiledlayout(2,1)
end
if ~isempty(deployment)
    k = 0;
    for di = deployment

        k = k+1; % count the number of deployments

        figure(f1)
        deploy_id = find(driftlog.Deployment == di);
        drifter_no = driftlog.DrifterNumber(deploy_id(1));
        this_dir = fullfile(data_basedir,driftlog.ExperimentName(deploy_id(1)));

        % what times do I want to look at? 
        end_time = driftlog.TimeFirstSatUTC(deploy_id(end));
        if isnat(end_time)
            warning('Assuming end time is "now"')
            % we are probably still deployed (or the time is missing), 
            % lets just go to "now" time
            end_time = datetime('now', 'TimeZone', 'UTC');
            % i want it without the "timezone" proeprty
            end_time = datetime(datenum(end_time),'convertfrom','datenum');
        end
        % we want to build a track for the drifter, lets just use every
        % minute between the last sat fix before diving and the surface sat fix
        % (or the current time if the drifter is still underwater)
        time_utc = driftlog.TimeLastSatUTC(deploy_id(1)):minutes(1):end_time;

        % load the bouyancy engine log data 
        if plot_driftcam_status
            driftcam = loadDrifterLogDataV2(time_utc,this_dir{:},drifter_no);
        else 
            driftcam = [];
        end

        if add_ship_track
            % interpolate ship location to drifter time
            gpsData = unique(gpsData,'rows');
            ship_lat = interp1(gpsData.time_utc,gpsData.latitude,time_utc);
            ship_lon = interp1(gpsData.time_utc,gpsData.longitude,time_utc);
            hs = plotm(ship_lat,ship_lon,'-k','linewidth',2);
            lst_pt = find(~isnan(ship_lat),1,'last');
            plotm(ship_lat(lst_pt),ship_lon(lst_pt),'^k','linewidth',2,...
                    'MarkerSize',markersize,'MarkerFaceColor','k','MarkerEdgeColor','k');
            uistack(ax,'top')
        end
            

        % if ~isempty(driftcam)
        %     max_depth_m = max(driftcam.depth_m);
        % else
            max_depth_m = max(driftlog.MaxSetDepth(deploy_id));
        % end

        lon_plot = [driftlog.LonLastSat(deploy_id),...
                    driftlog.LonFirstSat(deploy_id)];
         
        lat_plot = [driftlog.LatLastSat(deploy_id),...
                    driftlog.LatFirstSat(deploy_id)];

        
        % loop through the dives for this deployment
        for dive_idx = 1:size(lat_plot,1)
            figure(f1)
            h(k) = plotm(lat_plot(dive_idx,:),lon_plot(dive_idx,:),'-^','Color',markercolors(k,:),'linewidth',2,...
                'MarkerSize',markersize,'MarkerFaceColor',markercolors(k,:),'MarkerEdgeColor','k');

            if add_label
                textm(lat_plot(dive_idx,1),lon_plot(dive_idx,1),num2str(dive_idx,'D%i'),...
                                'FontSize',10,'Color','w','FontWeight','bold','HorizontalAlignment',"center");
                textm(lat_plot(dive_idx,2),lon_plot(dive_idx,2),num2str(dive_idx,'S%i'),...
                                'FontSize',10,'Color','w','FontWeight','bold','HorizontalAlignment',"center"); 
            end
 
            if add_ship_track
                [ship_dist_m{k}(dive_idx,:),ship_bear_deg{k}(dive_idx,:)] = ...
                    distance(drift_lat{k,dive_idx},drift_lon{k,dive_idx},...
                    ship_lat,ship_lon,wgs84Ellipsoid);
            end

             
        end
        cb=colorbar; cb.FontWeight = 'bold';
        setm(gca,'fontweight','bold','fontsize',12);
         
        vector_sensor = driftlog.VectorSensor(deploy_id);
        legend_str{k} = sprintf('Drifter #%i: %s to %s, %1.0fm, %s',median(driftlog.DrifterNumber(deploy_id)),...
           min(driftlog.TimeLastSatUTC(deploy_id)),max(driftlog.TimeFirstSatUTC(deploy_id)),...
            max_depth_m,vector_sensor{1});

        if ~isempty(driftcam)
            f2=figure;
            nexttile(1,[1 1]); hold on
            % figure(2); hold on
            driftcamStatusPlot(driftcam,driftlog.SunsetUTC(deploy_id),driftlog.SunriseUTC(deploy_id))
            % hd(k) = plot(driftcam.time_utc,-driftcam.depth_m,'linewidth',2,'color',markercolors{k});
            grid on
            set(gca,'fontweight','bold','fontsize',12);
            ax(1) = gca;

            if add_ship_track
                % nexttile(5,[2 1]); hold on
                nexttile(2,[1 1]); hold on
                plot(driftcam.time_utc,ship_dist_m{k}/1e3,'linewidth',2,'color',markercolors(k,:));
                ylabel('Ship Distance, km')
                grid on
                set(gca,'fontweight','bold','fontsize',12);
                ax(2) = gca;
                % title('Ship Distance')
            end
        end
        % nexttile(1,[4,1])
        figure(f1)
        sc = scaleruler('on');
        % setm(sc,'Fontweight','bold','Fontsize',12,'color','w','MajorTick',[5:10:50])
        setm(sc,'Fontweight','bold','Fontsize',12,'color','w','MajorTick',scale_ruler,'MinorTick',0)
        colorbar
        
        if plot_driftcam_status
            % nexttile(5,[2 1])
            figure(f2)
            ax(1).XTick = linspace(time_utc(1),time_utc(end),20);
            ax(2).XTick = linspace(time_utc(1),time_utc(end),20);
            set(ax(2),'fontweight','bold','fontsize',12,'XTickLabelRotation',90);
        end
    end
    
    legend(h,legend_str,'FontWeight','bold','fontsize',12)

    % lst_pt = find(~isnan(gpsData.latitude),1,'last');
    % plotm(gpsData.latitude(lst_pt),gpsData.longitude(lst_pt),'ok','linewidth',2,...
    %     'MarkerSize',10,'MarkerFaceColor','k','MarkerEdgeColor','k');
end



