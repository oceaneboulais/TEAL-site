% [x,y] = ll2xy(lon,lat,lon0,lat0, pressure);
% convert from lat-lon coordinates to xy coordinates, with respect to some origin point
%     lat      = decimal degrees (+ve N, -ve S) [- 90.. +90]
%     lon      = decimal degrees (+ve E, -ve W) [-180..+180]
% OPTIONAL:
%     pressure     =  sea pressure ( default is 0 )               [ dbar ]
%            ( i.e. absolute pressure - 10.1325 dbar )
%
% Alex Andriatis
% 2020-10-08

function [x,y] = ll2xy(lon,lat,lon0,lat0,press);

  if (~exist('press', 'var'))
    press=0;
  end

  % Check inputs
  if sum(size(lat))~=sum(size(lon))
   if numel(lon)==1 & numel(lat)~=1
     lon = repmat(lon,1,numel(lat));
   elseif numel(lat)==1 & numel(lon)~=1
     lat = repmat(lat,1,numel(lon));
   else
     error('lon and lat input dimensions must match');
   end
  end
  if (numel(lon0)~=1 & numel(lon0)~=numel(lon)) | (numel(lat0)~=1 & numel(lat0)~=numel(lat))
   error('lon0 and lat0 inputs must be numbers or match dimensions of lon and lat');
  end
  if numel(press)~=1 & numel(press)~=numel(lon)
   error('pressure input must be a number or match dimensions of lon and lat');
  end

  if numel(lon0)==1
    lon0 = repmat(lon0,1,numel(lon));
  end
  if numel(lat0)==1
    lat0 = repmat(lat0,1,numel(lon));
  end
  if numel(press)==0
    press = repmat(press,1,numel(lon));
  end

  lonadjust=0;
  I = find(lon>180);
  if length(I)>0
    lon(I) = lon(I)-360;
    lonadjust=1;
  end
  lon0(lon0>180) = lon0(lon0>180)-360;

  [r,c] = size(lon);

  lonabs = (lon(:)-lon0(:))./abs(lon(:)-lon0(:));
  x = gsw_distance([lon0(:) lon(:)],[lat0(:) lat0(:)],press(:)).*lonabs(:);
  latabs = (lat(:)-lat0(:))./abs(lat(:)-lat0(:));
  y = gsw_distance([lon0(:) lon0(:)],[lat(:) lat0(:)],press(:)).*latabs(:);

  x = reshape(x,r,c);
  y = reshape(y,r,c);

end

