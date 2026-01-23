% this script loads and plots the GOES SST over a map around 
% the New England Seamounts
% A. Laferriere, 2024

close all, clear all

% you can either pull the SST map directly from the website, or provide a
% local file, comment out the one you dont want
url = 'https://ocean.weather.gov/sst/images/midatl/MidAtl_GoesSST24.png';
% sst_file = '/Users/alaferri/Databases/GOES/MidAtl_GoesSST24_20240620.png';

% these are coordinates I got from a kmz file, they may be out of date..
sio_n = [39.62	-63.66];
sio_s = [37.72	-63.352];
sio_e = [38.765	-62.273];
sio_w = [38.552	-64.627];
whoi_at = [38.312557 -63.015808];
nuwc = [38.8194 -64.0180];

map_lat_lim = [37 40];
map_lon_lim = [-65.5  -62];

lat_width = 2;
lon_width = 4;
scale_ruler = 0:2:10;
map_scale_loc = [-2.055,0.6069];
tile_scale_loc = [1.5e-3,0.607];

ax = axesm('MapProjection','mercator','MapLatLimit',map_lat_lim,...
    'MapLonLimit',map_lon_lim);
setm(ax,'MLineLocation',lon_width/4,'Grid','on','ParallelLabel','on','PLineLocation',lat_width/4,...
     'MeridianLabel','on','Frame','on','plabelround',-1,'mlabelround',-1,...
     'mlabellocation',lon_width/4,'PLabelLocation',lat_width/4,'flinewidth',4)
axis off; framem on; gridm on; tightmap

if exist('url','var')
    I = webread(url);
elseif exist('sst_file','var')
    I = imread(sst_file);
end
I(I==0) = nan;

% these corner points were from Y.T., they should be the same as his google
% earth plot
goes_lat = linspace(23.489400, 48.978700, size(I,1));
goes_lon = linspace(-87.437200, -43.776000, size(I,2));

[X,Y] = meshgrid(goes_lon,goes_lat(end:-1:1));
geoshow(Y,X,I,'FaceAlpha',0.5);

plotm(sio_n,'k.','linewidth',2,'MarkerSize',40);
textm(sio_n(1),sio_n(2)+0.1,'SIO N','fontweight','bold','fontsize',12)
plotm(sio_e,'k.','linewidth',2,'MarkerSize',40);
textm(sio_e(1),sio_e(2)+0.1,'SIO E','fontweight','bold','fontsize',12)
plotm(sio_s,'k.','linewidth',2,'MarkerSize',40);
textm(sio_s(1),sio_s(2)+0.1,'SIO S','fontweight','bold','fontsize',12)
plotm(sio_w,'k.','linewidth',2,'MarkerSize',40);
textm(sio_w(1),sio_w(2)+0.1,'SIO W','fontweight','bold','fontsize',12)
plotm(whoi_at,'k.','linewidth',2,'MarkerSize',40);
textm(whoi_at(1),whoi_at(2)+0.1,'AT','fontweight','bold','fontsize',12)
plotm(nuwc,'k.','linewidth',2,'MarkerSize',40);
textm(nuwc(1),nuwc(2)+0.1,'Soundscape','fontweight','bold','fontsize',12)

title('GOES SST 1 Day Composite')

% get lat lon if you have GEBCO file
gebfile = 'GEBCO_2021.nc';
if exist(gebfile,'file')
    
    blons = map_lon_lim(1):0.001:map_lon_lim(2);
    blats = map_lat_lim(1):0.001:map_lat_lim(2);
    
    [bLATS,bLONS] = meshgrid(blats,blons);
    elev = getElevationGEBCO(bLONS(:), bLATS(:),gebfile);
    bathymetry = reshape(elev,size(bLATS));

    [C,h]=contourm(bLATS,bLONS,bathymetry,'k','linewidth',1,'fill','off');
    t=clabelm(C,h,'labelspacing',2000);
    set(t,'BackgroundColor','none')
    setm(gca,'fontweight','bold','fontsize',14);

end

