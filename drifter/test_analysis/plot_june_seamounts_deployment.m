clear all, close all
use_remote = true;

gitpath = fullfile(pwd,'../..');

addpath(genpath(gitpath))

[data_basedir,procdata_basedir,~,envdir] = setUpDrifterPaths(use_remote,0);

gebfile = fullfile(envdir,'GEBCO_2021.nc');


driftlog = getDeployLog(gitpath);
driftlog = driftlog(strcmp(driftlog.ExperimentName,'2024_Jun_Seamounts'),:);

%% get the approximate drifter tracks from the log entries
[drift_time,drift_lat,drift_lon] = getLinearDriftTrack(driftlog,[27 28 29]);

sio_n = [39.620 -63.66];
sio_s = [37.71	-63.352];
a2 = [38.47273, -63.1697];
tr = [38.03572 -63.00637];

map_lat_lim = [37 40];
map_lon_lim = [-65.5  -62];

lat_width = 2;
lon_width = 4;
scale_ruler = 0:25:100;
map_scale_loc = [-2.055,0.6069];
tile_scale_loc = [1.5e-3,0.607];

markercolors = linspecer(5);
markercolors = markercolors([2 4 5],:);

markersize = 12;

add_label = false;

%% get the lat/lon grid for bathy

blons = map_lon_lim(1):0.001:map_lon_lim(2);
blats = map_lat_lim(1):0.001:map_lat_lim(2);

[bLATS,bLONS] = meshgrid(blats,blons);
elev = getElevationGEBCO(bLONS(:), bLATS(:),gebfile);
bathymetry = reshape(elev,size(bLATS));


ax = axesm('MapProjection','mercator','MapLatLimit',map_lat_lim,...
    'MapLonLimit',map_lon_lim);
setm(ax,'MLineLocation',lon_width/4,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/4,...
    'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
    'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
axis off; framem on; gridm on; tightmap
geoshow(bLATS,bLONS,bathymetry,'displaytype','texturemap')
[C,hb]=contourm(bLATS,bLONS,bathymetry,'k','linewidth',1,'fill','off');
t=clabelm(C,hb,'labelspacing',2000);
set(t,'BackgroundColor','none')
set(t,'color','k')
setm(gca,'fontweight','bold','fontsize',14);
clim([-6000 0])

plotm(sio_n,'s','linewidth',2,'MarkerSize',markersize,'MarkerFaceColor','w','MarkerEdgeColor','k');
textm(sio_n(1),sio_n(2)+0.1,'SIO N','fontweight','bold','fontsize',12)
plotm(sio_s,'s','linewidth',2,'MarkerSize',markersize,'MarkerFaceColor','w','MarkerEdgeColor','k');
textm(sio_s(1),sio_s(2)+0.1,'SIO S','fontweight','bold','fontsize',12)
plotm(a2,'s','linewidth',2,'MarkerSize',markersize,'MarkerFaceColor','w','MarkerEdgeColor','k');
textm(a2(1),a2(2)+0.1,'A2','fontweight','bold','fontsize',12)
plotm(tr,'s','linewidth',2,'MarkerSize',markersize,'MarkerFaceColor','w','MarkerEdgeColor','k');
textm(tr(1),tr(2)+0.1,'TR','fontweight','bold','fontsize',12)


%%
k = 0;
for di = 27:29
    k = k+1;

    deploy_id = find(driftlog.Deployment == di);

    lon_plot = [driftlog.LonLastSat(deploy_id),...
            driftlog.LonFirstSat(deploy_id)];
         
    lat_plot = [driftlog.LatLastSat(deploy_id),...
                driftlog.LatFirstSat(deploy_id)];

    for dive_idx = 1:length(deploy_id)

        % plotm(driftlog.LatDeploy(deploy_id),driftlog.LonDeploy(deploy_id),'.',...
        % 'linewidth',2,'MarkerSize',20,'Color',markercolors(k,:),'MarkerEdgeColor','k');
        plotm(driftlog.LatRecovery(deploy_id),driftlog.LonRecovery(deploy_id),'o',...
            'linewidth',2,'MarkerSize',markersize,'MarkerFaceColor',markercolors(k,:),'MarkerEdgeColor','k');
        
    
        h(k) = plotm(lat_plot(dive_idx,:),lon_plot(dive_idx,:),'-^','Color',markercolors(k,:),'linewidth',2,...
        'MarkerSize',markersize,'MarkerFaceColor',markercolors(k,:),'MarkerEdgeColor','k');

    end


    
    setm(gca,'fontweight','bold','fontsize',12);
         
   vector_sensor = driftlog.VectorSensor(deploy_id);
   legend_str{k} = sprintf('Drifter #%i: %s to %s, %s',median(driftlog.DrifterNumber(deploy_id)),...
        min(driftlog.TimeLastSatUTC(deploy_id)),max(driftlog.TimeFirstSatUTC(deploy_id)),vector_sensor{1});
end

sc = scaleruler('on');
setm(sc,'Fontweight','bold','Fontsize',12,'color','k','MajorTick',scale_ruler,'MinorTick',0)
colorbar

legend(h,legend_str,'FontWeight','bold','fontsize',12)

colormap(cmocean('deep'))
cb=colorbar; cb.FontWeight = 'bold';
cb.FontSize = 12;
