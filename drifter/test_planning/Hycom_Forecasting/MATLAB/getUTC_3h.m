% This function returns the current UTC time as a matlab datenum
% Then rounds to the nearest 3-hour period
%
% function time = getUTC_3h()
%
% Alex Andriatis
% 2021-05-02
%
% A.Laferriere 2025-08-22 
% updated to also accept time in, if no input uses current time
function time = getUTC_3h(time_in)
    if nargin==0
        tnow = getUTC;
    else
        tnow = time_in;
    end

    thour = tnow-floor(tnow);
    thour = floor(thour*24);
    tmult = floor(thour/3);
    time = floor(tnow)+(tmult*3)/24;
end
