% This script advects "deployed" assets by advecting every HYCOM grid cell using depth-averaged velocity. It saves the instantaneous displacement
% and instrument positions at every timestep
%
%
% Alex Andriatis
% 2021-05-02

% Edited by A. Laferriere 2025-08-22
%   to specify the range over which the depth average is calculated 

try

tic;
addpath('Advect_Hycom');
addpath(genpath('MATLAB'))

datapath = 'HYCOM';
filename='Hycom_Timeseries.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

savename='Hycom_Timeseries_advection.mat';
savepath=fullfile(datapath,savename);

deploytime = datenum(2021,10,1);
% deploytime = getUTC_3h
dmean = 200;

xl = [-119 -117];
yl = [32 34];
[~,latI]=closest(data.latitude,yl);
[~,lonI]=closest(data.longitude,xl);
latitude = data.latitude(latI(1):latI(2));
longitude = data.longitude(lonI(1):lonI(2));

% Instead of advecting a subset of the data I'm just going to advect the whole field
%latitude = data.latitude;
%longitude = data.longitude;
     
[~,depthI]=closest(data.depth,dmean);
[~,tstartI]=closest(data.time,deploytime);
tvec = data.time(tstartI:end);
time = NaN(1,length(tvec)+1);

[XGi,YGi]=meshgrid(longitude,latitude);
YGt = NaN(size(YGi,1),size(YGi,2),length(tvec)+1);
XGt = NaN(size(XGi,1),size(XGi,2),length(tvec)+1);

displacement = zeros(size(XGt));
xdisplacement = displacement;
ydisplacement = displacement;

XGt(:,:,1)=XGi;
YGt(:,:,1)=YGi;

gridlon = data.longitude;
gridlat = data.latitude;


for t=1:length(tvec)
    disp(['Advecting "deployed" assets for timesetp ' num2str(t) ' of ' num2str(length(tvec))]);
    [time(t),timeI]=closest(data.time,tvec(t));
    % Calculate the flow fields at time t and t+1, with an intermediate
    % point
    u(:,:,1) = squeeze(mean(data.u(:,:,1:depthI,timeI),3));
    v(:,:,1) = squeeze(mean(data.v(:,:,1:depthI,timeI),3));
    
    if t<length(tvec)
        u(:,:,3) = squeeze(mean(data.u(:,:,1:depthI,timeI+1),3));
        v(:,:,3) = squeeze(mean(data.v(:,:,1:depthI,timeI+1),3));
        
        u(:,:,2) = u(:,:,1)/2+u(:,:,3)/2;
        v(:,:,2) = v(:,:,1)/2+v(:,:,3)/2;
    end
    if t<length(tvec)
        dt = tvec(t+1)-tvec(t);
        time(t+1) = tvec(t+1);
    else
        dt = 3/24;
        time(t+1)=time(t)+dt;
    end
    dt = dt*86400;
    
    for i=1:length(longitude)
        for j=1:length(latitude)
            [XGt(j,i,t+1),YGt(j,i,t+1)] = rk4(XGt(j,i,t),YGt(j,i,t),gridlon,gridlat,u,v,dt); % This is the advection script - a custom 4th order runge-kutta thing I wrote
            [xdisplacement(j,i,t+1),ydisplacement(j,i,t+1)] = ll2xy(XGt(j,i,t+1),YGt(j,i,t+1),XGt(j,i,t),YGt(j,i,t));
            displacement(j,i,t+1) = gsw_distance([XGt(j,i,t+1) XGt(j,i,t)],[YGt(j,i,t+1) YGt(j,i,t)],0);
        end
    end
end

advection.longitude = longitude;
advection.latitude = latitude;
advection.time = time;
advection.XGt = XGt;
advection.YGt = YGt;
advection.xdisplacement = xdisplacement;
advection.depth = dmean;
advection.ydisplacement = ydisplacement;
advection.displacement = displacement;

save(savepath,'-struct','advection','-v7.3');
disp(['Saved advected data in ' savepath]);

    
toc;

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end

