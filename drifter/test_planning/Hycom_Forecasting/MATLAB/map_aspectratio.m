function map_aspectratio(ax)
%function map_aspectratio(ax)
%Specify an axis handle with a map in it, and this will scale the aspect
%ratio to that appropriate for viewing the map in a Mercator projection. 
%
%4/08: gca is used if no args are passed.
%MHA

if nargin < 1
    ax=gca;
end

yl=ylim;
latmin=yl(1);
latmax=yl(2);
dar=get(ax,'dataaspectratio');
latmid=1/2*(latmin+latmax);
dar(1)=dar(1).*cos(latmid/180*pi);
set(ax,'plotboxaspectratio',dar)
set(ax,'box','on')
