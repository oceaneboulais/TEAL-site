function elev = getElevationGEBCO(lons,lats,gebfile)
% Alison B. Laferriere

if nargin<3
    gebfile = 'GEBCO_2021.nc';
end
%% Read lat lon grid
latgrid = double(ncread(gebfile,'lat'));
longrid = double(ncread(gebfile,'lon'));

%% get index for elevation to read

lat_idx(1) = find(min(lats)>latgrid,1,'last');
lat_idx(2) = find(max(lats)<=latgrid,1,'first');
latidx = lat_idx(1):lat_idx(2);


lon_idx(1) = find(min(lons)>longrid,1,'last');
lon_idx(2) = find(max(lons)<=longrid,1,'first');
lonidx = lon_idx(1):lon_idx(2);


% the data is in dimensions lon x lat
Nstart = [lon_idx(1) lat_idx(1)];
Ncount = [numel(lonidx) numel(latidx)];
Nstride = [1 1];


%% Read elevation 
elev = double(ncread(gebfile,'elevation',Nstart,Ncount,Nstride)); 


%% Interpolate elevation.  
elev= interp2(latgrid(latidx), longrid(lonidx), elev, lats,lons);
    

end
