function [sunset_utc, sunrise_utc,sunset_local,sunrise_local] = calculateSunriseSunset(lat,lon,date)
% [sunset_utc, sunrise_utc,sunset_local,sunrise_local] = calculateSunriseSunset(lat,lon,date)
% calculate the sunset and sunrise in utc and local time 
% INPUTS
%   lat: latitude in decimal degrees for which you'd like it calculated 
%   lon: longitude in decimal degrees for which you'd like it calculated 
%   date: a datetime for the day you'd like it calculated 
% OUTPUTS:
%   sunset_utc: datetime of the sunset in utc time
%   sunrise_utc: datetime of the sunrise in utc time
%   sunset_local: datetime of the sunset in local time (based on lat/lon)
%   sunrise_local: datetime of the sunrise in local time (based on lat/lon)
% 
% A. Laferriere 2024
% based on François Beauducel (2024). 
% SUNRISE: sunrise and sunset times (https://github.com/beaudu/sunrise/releases/tag/v1.4.1), GitHub. Retrieved June 22, 2024.

if nargin == 0
    lat = 38.537;
    lon =-62.222;
end
if ~exist('date','var')
    % use todays date 
    today = datetime("today","TimeZone","UTC");
    date = today + hours(12);
    
else
    date = datetime(year(date),month(date),day(date),12,0,0);
end

yearStart = dateshift(date,"start","year");               % midnight beginning of year
yearEnd = dateshift(date,"start","year","next");          % midnight end of year

B = 360*(day(date,'dayofyear')-81)/365;
eot = minutes(9.87*sind(2*B) - 7.53*cosd(B) - 1.5*sind(B));

yearFrac = (date - yearStart) ./ (yearEnd - yearStart);    % year fraction at noon each day
gamma = 2*pi * yearFrac;                                   % year fraction in radians
delta = 0.006918 - 0.399912*cos(gamma) + 0.070257*sin(gamma) - 0.006758*cos(2*gamma) ...
    + 0.000907*sin(2*gamma) - 0.002697*cos(3*gamma) + 0.00148*sin(3*gamma);
omega = acosd((cosd(90.833)./(cosd(lat).*cos(delta))) - tand(lat).*tan(delta));

sunrise_utc = date - minutes(4*(lon + omega)) - eot;
sunset_utc  = date - minutes(4*(lon - omega)) - eot;

zd = NaN(size(lon));
zd(~isnan(lon)) = timezone(lon(~isnan(lon)));

% Convert the timezone offset to a duration
tz_offset = hours(zd);

% Apply the duration to the sunrise and sunset
sunrise_local = sunrise_utc - tz_offset;
sunrise_local.TimeZone = '';

%sunrise_local = sunrise_utc;
sunset_local = sunset_utc - tz_offset;
sunset_local.TimeZone = '';

