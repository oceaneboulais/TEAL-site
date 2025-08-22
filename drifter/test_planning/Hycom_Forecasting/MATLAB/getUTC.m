% This function returns the current UTC time as a matlab datenum
%
% function time = getUTC()
%
% Alex Andriatis
% 2020-10-30
%
function time = getUTC()
  time = datenum(datetime('now','TimeZone','Z'));
end
