function adcp = readADCP(filename)

adcp_info = ncinfo(filename);   
adcp.time = ncread(filename,'time');
adcp.lon = ncread(filename,'lon');
adcp.lat = ncread(filename,'lat');
adcp.depth = ncread(filename,'depth');
adcp.u = ncread(filename,'u');
adcp.u(adcp.u>1e20) = nan;
adcp.v = ncread(filename,'v');
adcp.v(adcp.v>1e20) = nan;