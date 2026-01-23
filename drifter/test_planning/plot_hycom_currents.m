% this script reads in HYCOM SSP and current profiles and displatys them on
% a map and in line plots 

close all, clear all

addpath(genpath('../../'))

envdir = '/Users/alaferri/Databases'; % this is where I will download hycom files 
hycom_save_dir = fullfile(envdir,'HYCOM');
gebfile = fullfile(envdir,'GEBCO_2021.nc');

cur_axis = [0 0.5];
depth_axis = [-1000 0];
ssp_axis = [1480 1530];

dq = 20;


%% select your time and your points 

time_list = datetime(2023,10,4,12,0,0);
% forecast_days = days(floor(days(time_list - datetime(2023,9,30,12,0,0)))+days(1));

% time_list = datetime(2023,9,29,12,0,0);
forecast_days = 0;

lon_center = -117.732200;
lat_center =   32.910300;

lat_width = 0.25;
lon_width = 0.5;
scale_ruler = 0:2:10;
map_scale_loc = [-2.055,0.6069];
tile_scale_loc = [1.5e-3,0.607];


%% get the lat/lon grid 

lon_limits = [lon_center-lon_width/2, lon_center+lon_width/2];
lat_limits = [lat_center-lat_width/2, lat_center+lat_width/2];

lons = lon_limits(1):0.001:lon_limits(2);
lats = lat_limits(1):0.001:lat_limits(2);

[LATS,LONS] = meshgrid(lats,lons);

%% get the bathymetry 

elev = getElevationGEBCO(LONS(:), LATS(:),gebfile);
bathymetry = reshape(elev,size(LATS));

%% get the ocean currents from HYCOM
% note that downloading a full hycom file can take a few minutes
downloadHYCOMFile(time_list,'uv3z',hycom_save_dir,forecast_days);
hycom_cur = readHYCOMFile(time_list,LONS,LATS,'uv3z',hycom_save_dir,forecast_days);
%% make some map plots 

%% plot the bathymetry 

figure
ax = axesm('MapProjection','mercator');
setm(gca,'MapLatLimit',[min(lats) max(lats)])
setm(gca,'MapLonLimit',[min(lons) max(lons)])
setm(gca,'PLabelMeridian','west','MLabelParallel','south','ParallelLabel','on','MeridianLabel','on')
setm(gca,'MLineLocation',lon_width/4,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/4,...
     'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
     'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
axis off; framem on; gridm on; tightmap
geoshow(LATS,LONS,bathymetry,'displaytype','texturemap')
hold on
[C,h]=contourm(LATS,LONS,bathymetry,'k');
t=clabelm(C,h,'labelspacing',2000);
set(t,'BackgroundColor','none','color','k')
setm(gca,'fontweight','bold','fontsize',14);

sc = scaleruler('on');
setm(sc,'Fontweight','bold','Fontsize',12,'color','k','MajorTick',...
        scale_ruler,'XLoc',map_scale_loc(1),'YLoc',map_scale_loc(2))
    % scale_ruler,'XLoc',-2.0555,'YLoc',0.60785)
colorbar(ax)
set(gca,'fontweight','bold','fontsize',14);

clim(depth_axis)

colormap(cmocean('deep'))
%% plot the current at a specified depth in horizontal slices, loop through times
depth_list = [0 100 200 500];

ssize = get(groot, 'ScreenSize');
fcur = figure;  set(gcf,'Renderer','zbuffer'); set(gcf, 'Position', ssize);

for itime = 1:length(hycom_cur.time)
    set(groot,'CurrentFigure',fcur); clf;


    tiledlayout(2,5)

    tile_location = [2 4 7 9];


    for k = 1:length(depth_list)
        depth = depth_list(k);
        [~,depth_idx] = min(abs(depth - hycom_cur.depth_m));
        depth_plot = hycom_cur.depth_m(depth_idx);
        
        
        qlat = lats(1:dq:end);
        qlon = lons(1:dq:end);
        [qlat,qlon]=meshgrid(qlat,qlon);

        dlon = hycom_cur.water_east_mps(1:dq:end,1:dq:end,depth_idx,itime); 
        dlat = hycom_cur.water_north_mps(1:dq:end,1:dq:end,depth_idx,itime);
    
    
        current_mps = sqrt(hycom_cur.water_east_mps.^2  + hycom_cur.water_north_mps.^2);
    
        %ax = nexttile(tile_location(k),[1 2]);
        ax = nexttile(tile_location(k),[1 2]);
        axesm('MapProjection','mercator','MapLatLimit',[min(lats) max(lats)],...
            'MapLonLimit',[min(lons) max(lons)])
        % setm(gca,'PLabelMeridian','west','MLabelParallel','south','ParallelLabel','on','MeridianLabel','on')
        setm(ax,'MLineLocation',lon_width/4,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/4,...
             'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
             'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
        axis off; framem on; gridm on; tightmap
        geoshow(ax,LATS,LONS,current_mps(:,:,depth_idx,itime),'displaytype','texturemap'); 
        clim(cur_axis)
        [C,h]=contourm(LATS,LONS,bathymetry,'k');
        myq = quiverm(qlat,qlon,dlat,dlon,'w',0.5);
        set(myq,'LineWidth',2)
    
        setm(gca,'PLabelMeridian','west','MLabelParallel','south','ParallelLabel','on','MeridianLabel','on')
        setm(gca,'fontweight','bold','fontsize',14);
    
        sc = scaleruler('on');
    
        setm(sc,'Fontweight','bold','Fontsize',12,...
            'color','k','MajorTick',scale_ruler,'XLoc',tile_scale_loc(1),'YLoc',tile_scale_loc(2))
        
        
        title(sprintf('Current at %1.0f m Depth',depth_plot),'fontsize',16,'FontWeight','bold')
        plotm(lat_center,lon_center,'k*','linewidth',2,'MarkerSize',18);
        colormap(cmocean('thermal'))
    end


    % now do a depth profile at the marker 
    nexttile(1,[2 1])
    [~,lat_idx] = min(abs(lat_center - lats));
    [~,lon_idx] = min(abs(lon_center - lons));

    plot(squeeze(current_mps(lon_idx,lat_idx,:,itime)),-hycom_cur.depth_m,'linewidth',2)
    grid on; hold on
    plot(squeeze(hycom_cur.water_east_mps(lon_idx,lat_idx,:,itime)).',-hycom_cur.depth_m.','linewidth',2)
    plot(squeeze(hycom_cur.water_north_mps(lon_idx,lat_idx,:,itime)),-hycom_cur.depth_m,'linewidth',2)
    title(sprintf('Current Profile at %1.4f, %1.4f',lat_center,lon_center))
    set(gca,'fontweight','bold','fontsize',14);
    xlim([-cur_axis(2) cur_axis(2)])
    xlabel('Depth, m')
    ylabel('m/s')
    legend('Total','Eastward','Northward','location','best')
    
    cb=colorbar; cb.Label.String = 'm/s';
    cb.Layout.Tile = 'east';
    clim(cur_axis)

    if forecast_days>0
        hycom_type = sprintf('%i Day Forecast',forecast_days(itime));
    else
        hycom_type = '';
    end
    sgtitle(sprintf('HYCOM %s %s',hycom_type,hycom_cur.time(itime)),'fontsize',24,'fontweight','bold')

    if save_to_ppt
        slideId = pptx.addSlide();
        fprintf('Added slide %d\n',slideId);
        pptx.addPicture(gcf);
    end
end

newFile     = pptx.save('current_profiles');
% %% plot the current in vertical slices 
% % slice down the middle in vertical and horizontal 
% [lattrk,lontrk] = track2(min(lats),min(lons),max(lats),max(lons),wgs84Ellipsoid,[],200);
% 
% 
% 
% ca = [-0.5 0.5];
% 
% figure
% tiledlayout(1,3)
% 
% nexttile
% lat_slice_tot = slice(lats,lons,-hycom_cur.depth_m,current_mps,lat_center,[],[],'linear'); 
% hold on
% lon_slice_tot = slice(lats,lons,-hycom_cur.depth_m,current_mps,[],lon_center,[],'linear');
% zlim([-900 0]); shading flat; view(3); xlim([min(lats),max(lats)]); clim([ca])
% set(gca,'fontweight','bold','fontsize',12); zlabel('Depth,m'); xlabel('Latitude'); zlabel('Longitude')
% title('Total Current')
% 
% 
% nexttile
% lat_slice_east = slice(lats,lons,-hycom_cur.depth_m,hycom_cur.water_east_mps,lat_center,[],[],'linear'); 
% hold on
% lon_slice_east = slice(lats,lons,-hycom_cur.depth_m,hycom_cur.water_east_mps,[],lon_center,[],'linear');
% zlim([-900 0]); shading flat; view(3); xlim([min(lats),max(lats)]); clim([ca])
% set(gca,'fontweight','bold','fontsize',12); zlabel('Depth,m'); xlabel('Latitude'); ylabel('Longitude');
% title('Eastward Current')
% 
% nexttile
% lat_slice_north = slice(lats,lons,-hycom_cur.depth_m,hycom_cur.water_north_mps,lat_center,[],[],'linear');
% hold on
% lon_slice_north = slice(lats,lons,-hycom_cur.depth_m,hycom_cur.water_north_mps,[],lon_center,[],'linear');
% zlim([-900 0]); shading flat; view(3); xlim([min(lats),max(lats)]); clim([ca])
% set(gca,'fontweight','bold','fontsize',12); zlabel('Depth,m'); xlabel('Latitude'); ylabel('Longitude')
% title('Northward Current')
% 
% 
% cb=colorbar; clim(ca); cb.Layout.Tile = 'east'; set(gca,'fontweight','bold','fontsize',12);
% 
% 
% sgtitle(sprintf('HYCOM %s',hycom_cur.time),'fontsize',24,'fontweight','bold')

%% do the same thing for SSP
[M,N,~,T] = size(hycom_ssp.temp_degC);
pres(1,1,:) = sw_pres(hycom_ssp.depth_m,lat_center);
dens = sw_dens(hycom_ssp.salt_psu,hycom_ssp.temp_degC,repmat(pres,[M,N,1,T]));
ssp = sw_svel(hycom_ssp.salt_psu,hycom_ssp.temp_degC,repmat(pres,[M,N,1,T]));
% 
% figure
% 
% tiledlayout(2,5)
% 
% ca = [1022 1023]
% 
% for k = 1:length(depth_list)
%     depth = depth_list(k);
%     [~,depth_idx] = min(abs(depth - hycom_cur.depth_m));
%     depth_plot = hycom_ssp.depth_m(depth_idx);
% 
% 
% 
%     %ax = nexttile(tile_location(k),[1 2]);
%     ax = nexttile(tile_location(k),[1 2]);
%     axesm('MapProjection','mercator','MapLatLimit',[min(lats) max(lats)],...
%         'MapLonLimit',[min(lons) max(lons)])
%     % setm(gca,'PLabelMeridian','west','MLabelParallel','south','ParallelLabel','on','MeridianLabel','on')
%     setm(ax,'MLineLocation',lon_width/4,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/4,...
%          'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
%          'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
%     axis off; framem on; gridm on; tightmap
% 
%     geoshow(ax,LATS,LONS,dens(:,:,depth_idx),'displaytype','texturemap');
%     clim auto; colorbar
% 
%     setm(gca,'PLabelMeridian','west','MLabelParallel','south','ParallelLabel','on','MeridianLabel','on')
%     setm(gca,'fontweight','bold','fontsize',14);
% 
%     sc = scaleruler('on');
% 
%     setm(sc,'Fontweight','bold','Fontsize',12,...
%         'color','k','MajorTick',scale_ruler,'XLoc',tile_scale_loc(1),'YLoc',tile_scale_loc(2))
% 
% 
%     title(sprintf('Density at %1.0f m Depth',depth_plot),'fontsize',16,'FontWeight','bold')
%     plotm(lat_center,lon_center,'k*','linewidth',2,'MarkerSize',18);
% 
% end
% % now do a depth profile at the marker 
% nexttile(1,[2 1])
% [~,lat_idx] = min(abs(lat_center - lats));
% [~,lon_idx] = min(abs(lon_center - lons));
% 
% plot(squeeze(dens(lon_idx,lat_idx,:)),-hycom_ssp.depth_m,'linewidth',2)
% grid on
% title(sprintf('Density Profile at %1.4f, %1.4f',lat_center,lon_center))
% set(gca,'fontweight','bold','fontsize',14);
% xlabel('Depth, m')
% ylabel('kg/m^3')


%%
figure
plot(squeeze(ssp(lon_idx,lat_idx,:,:)),-hycom_cur.depth_m,'linewidth',2)
grid on
set(gca,'fontweight','bold','fontsize',14);
xlabel('Sound Speed, m/s')
ylabel('Depth, m')
legend(datestr(hycom_ssp.time),'location','best')


if forecast_days>0
    hycom_type = sprintf('%i Day Forecast',forecast_days);
else
    hycom_type = '';
end
title({sprintf('HYCOM %s %s',hycom_type,hycom_cur.time(itime)),...
    sprintf('Sound Speed Profile at %1.4f, %1.4f',lat_center,lon_center)},'fontsize',16,'fontweight','bold')