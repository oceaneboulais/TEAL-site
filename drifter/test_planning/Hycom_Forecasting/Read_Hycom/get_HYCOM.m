function [D,status] = get_HYCOM(time,lon,lat,depth,fpath,sourcepath,reload)
% This function grabs the most recently available HYCOM
%  function [D] = get_HYCOM_hindcast(time,lon,lat,depth,fname,sourcepath);
% Inputs:
%   time, lon, lat, and depth can all be points or vectors
%   Time in matlab datenum. Code designed to pretty much work with only one time, multiple times take really long.
%   Lon in -180:180 decimal degrees
%   Lat in -90:90 decimal degrees
%   Depth in meters, positive down from zero at surface
%     if Depth is a point, average will be from surface down
%     if Depth is a vector, average within depth range (nearest grid cell)
%   fname is a path where hycom fields are dumped after being read
%   sourcepath is the url link to the HYCOM data in case you want to use
%   something other than the default
%  
% Outputs:
%   D is a structure containing the following fields
%     D.date: time closest to the requested time at which data is available (datenum)
%     D.longitude: vector spanning the requested longitudes (-180:180 decimal degrees)
%     D.latitude: vector spanning the requested latitudes (-90:90 decimal degrees)
%     D.depth: vector spanning the requested depths (m), positive downwards
%     D.ssh: sea surface heigth (m), positive upwards
%     D.temperature: potential temperature (deg C)
%     D.salinity: absolute salinity (g/kg)
%     D.u: east-west velocity (m/s, positive east)
%     D.v: north-south velocity (m/s, positive north)
%
% Alex Andriatis
% 05-02-2021


 % load HYCOM grid
 if exist('sourcepath','var')
    OpenDAP_URL = sourcepath;
 else
    OpenDAP_URL = 'http://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0'; % Best hindcast reanalysis file
 end
 
 if ~exist('reload','var')
     reload=0;
 end

 % Time
 param = 'time';
  time_origin = ncreadatt(OpenDAP_URL,param,'units');
  time_origin = time_origin(13:31);
  time_origin = datenum(time_origin,'yyyy-mm-dd HH:MM:SS');
  hycom_time = ncread(OpenDAP_URL,param);
  hycom_time = datenum(hycom_time./24) + time_origin;
  % If the requested time is later than the size of the data, quit
  if time(end)>hycom_time(end)
      disp(['Requested time ' datestr(time(end)) ' exceeds the limits of this file']);
      D=[];
      status=0;
      return;
  end
  % Find HYCOM time index corresponding closest to the time of interest
  if length(time)>1
    [closestval,I] = closest(hycom_time,[time(1) time(end)],1);
  else
    [closestval,I] = closest(hycom_time,[time time],1);
  end
  tmin = I(1); tmax = I(2); nt = tmax-tmin+1;
  hycom_time = ncread(OpenDAP_URL,param,tmin,nt);
  D.time = datenum(hycom_time./24) + time_origin;
  fname = ['HYCOM_' datestr(D.time(1),'yyyymmddTHHMMSS') '.mat'];
  savename = fullfile(fpath,fname);
  if ~reload
      % The closest available time might not match the requested time - check if the corresponding file exists already, skip the rest of the code if it does 
      if exist(savename,'file')
          disp(['The requested start time is ' datestr(time(1)) ' but the closest HYCOM time is ' datestr(D.time(1)) ' and a file already exists with that start time.']);
          D=[];
          status=2;
          return
      end
  end
  
 % Latitude
  param = 'lat';
  hycom_lat = ncread(OpenDAP_URL,param);
  % Find range of HYCOM indices corresponding to the region
  [closestval,I] = closest(hycom_lat,[lat(1) lat(end)],1);
  if length(lat)>1
    if closestval(1)>lat(1)
      I(1)=I(1)-1;
    end
    if closestval(2)<lat(end)
      I(2) = I(2)+1;
    end
    ymin = I(1); ymax = I(2); ny = ymax-ymin+1;
  else
    ymin = I(1); ny=1;
  end  
  D.latitude = ncread(OpenDAP_URL,param,ymin,ny);
  
 % Longitude
 param = 'lon';
  hycom_lon = ncread(OpenDAP_URL,param);
  lon(lon<0)=lon(lon<0)+360;
  [closestval,I] = closest(hycom_lon,[lon(1) lon(end)],1);
  if length(lon)>1
    if closestval(1)>lon(1)
      I(1)=I(1)-1;
    end
    if closestval(2)<lon(end)
      I(2) = I(2)+1;
    end
    xmin = I(1); xmax = I(2); nx = xmax-xmin+1;
  else
    xmin = I(1); nx=1;
  end
  D.longitude = ncread(OpenDAP_URL,param,xmin,nx);
  D.longitude(D.longitude>180) = D.longitude(D.longitude>180)-360;
  
 % Depth
 param = 'depth';
  hycom_z = ncread(OpenDAP_URL,param);
  depth(depth<0)=-depth(depth<0);
  % Find range of HYCOM indices corresponding to the region
  if length(depth)>1
    [closestval,I] = closest(hycom_z,[depth(1) depth(end)],1);
  else
    [closestval,I] = closest(hycom_z,[depth depth],1);
  end
  zmin = I(1); zmax = I(2); nz = zmax-zmin+1;
  D.depth = ncread(OpenDAP_URL,param,zmin,nz);

% 2D Fields: SSH
params = {'surf_el'};
  plab = {'ssh'};
  np = length(params);
  scale = [1];
  offset = [0];
  missvalue = -30000;
  for ip = 1:np
      param = params{ip};
      lab = plab{ip};
      tmp = ncread(OpenDAP_URL,param,[xmin,ymin,tmin],[nx,ny,nt]);
      tmp(tmp == missvalue) = nan;
      tmp = tmp.*scale(ip) + offset(ip);
      eval(['D.' lab ' = tmp;']);
      clear tmp param
  end

% 3D Fields: T, S, U, V
params = {'water_temp', 'salinity', 'water_u', 'water_v'};
plab = {'temperature','salinity','u','v'};
np = length(params);
% Scale and offset for old-style hycom data
%scale = [0.001, 0.001, 0.001, 0.001];
%offset = [20, 20, 0, 0];
scale = [1,1,1,1];
offset = [0,0,0,0];
missvalue = -30000;
for ip = 1:np
  param = params{ip};
  lab = plab{ip};
  tmp = ncread(OpenDAP_URL,param,[xmin,ymin,zmin,tmin],[nx,ny,nz,nt]);
  tmp(tmp == missvalue) = nan;
  tmp = tmp.*scale(ip) + offset(ip);
  eval(['D.' lab ' = tmp;']);
  clear tmp param
end
  
% Make sure missing values are NaN, based on where salinity is NaN or zero
D.salinity(D.salinity==0)=nan;
I = isnan(D.salinity);
D.temperature(I)=nan;
D.u(I)=nan;
D.v(I)=nan;
D.ssh(squeeze(I(:,:,1,:)))=nan;

D.ssh = squeeze(D.ssh);
D.temperature = squeeze(D.temperature);
D.salinity = squeeze(D.salinity);

% Save hycom data as matlab file with structure D 
  save(savename,'-struct','D','-v7.3');
  disp(['HYCOM data saved in ' savename]);
  status=1;
end
