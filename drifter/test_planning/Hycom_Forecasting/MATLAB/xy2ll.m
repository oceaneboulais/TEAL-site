% [lon,lat] = xy2ll(x,y,lon0,lat0,press) converts from cartesian x-y coordinates to longitudes and latitudes, 
% with respect to some origin point defined by [lon0,lat0];
% 
%       lat      = decimal degrees (+ve N, -ve S) [- 90.. +90]
%       lon      = decimal degrees (+ve E, -ve W) [-180..+180]
% OPTIONAL:
%     pressure     =  sea pressure ( default is 0 )               [ dbar ]
%            ( i.e. absolute pressure - 10.1325 dbar )
%
% Alex Andriatis
% 2020-10-08

function [lon,lat] = xy2ll(x,y,lon0,lat0,press);

  if (~exist('press', 'var'))
    press=0;
  end

  % Check inputs
  if size(x)~=size(y)
   error('x and y input dimensions must match');
  end
  if (numel(lon0)~=1 & numel(lon0)~=numel(x)) | (numel(lat0)~=1 & numel(lat0)~=numel(y))
   error('lon0 and lat0 inputs must be numbers or match dimensions of x and y');
  end
  if numel(press)~=1 & numel(press)~=numel(x)
   error('pressure input must be a number or match dimensions of x and y');
  end

  if numel(lon0)==1
    lon0 = repmat(lon0,1,numel(x));
  end
  if numel(lat0)==1
    lat0 = repmat(lat0,1,numel(x));
  end
  if numel(press)==0
    press = repmat(press,1,numel(x));
  end

  lonadjust=0;
  I = find(lon0>180);
  if length(I)>0
    lon0(I) = lon0(I)-360;
    lonadjust=1;
  end

  [r,c] = size(x);
  
  lat = y(:)./gsw_distance([lon0(:) lon0(:)],[lat0(:)-1/2 lat0(:)+1/2],press(:)) + lat0(:);
  lon = x(:)./gsw_distance([lon0(:)-1/2 lon0(:)+1/2],[lat(:) lat(:)],press(:)) + lon0(:);
  
  lon(lat>90) = rem(lon(lat>90)+180,360);
  lat(lat>90) = 180-lat(lat>90);
  lon(lat<-90) = rem(lon(lat<-90)+180,360);
  lat(lat<-90) = -180-lat(lat<-90);

  lon = rem(lon,360);
  lon(lon>180)=360-lon(lon>180);

  if lonadjust
    I = find(lon<0);
    lon(I) = lon(I)+360;
  end

  lon = reshape(lon,r,c);
  lat = reshape(lat,r,c);
end
