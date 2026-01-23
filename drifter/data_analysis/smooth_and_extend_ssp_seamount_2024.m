close all, clear all
%% approx lat/lon where we took the measurement 
% we'll use this to get a hycom profile to extend to depth
% we also use the lat to convert depth to pressure
lat=38.853825;	lon=-63.903267;

% I want to get the best estimate of the ssp near the lat/lon/time 
% but the drifter might not have had a deep dive at that time
% deep temps are less variable, so we'll use a larger time frame for the
% deeper profiles, but not for the shallow ones
plot_times_utc = [datetime(2023,10,09,19,24,35) datetime(2023,10,09,20,02,0)];
plot_times_utc_deep = [datetime(2023,10,09,19,24,35) datetime(2023,10,15,20,02,0)];

% this is the directory where I save the hycom profiles
% if the profile doesn't exist, the code will download it to this directory
hycom_dir = '/Users/alaferri/Databases/HYCOM';

% this is where I've saved the gebco nc file
gebfile = '/Users/alaferri/Databases/GEBCO_2021.nc';

savefilename = fullfile(pwd,'ssp_drifter_ctd.mat');

extend_type = 'deep_ctd'; % 'hycom', 'none'

stitch_depth_m = 552; % this is the depth at which we'll start using the model

% this is the measurement freom the ship ctd
% ctdfile = '/Users/alaferri/Data/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/MGL23-12_CTD_Data/20231010_3rd deployment_kelvin.cnv';
ctdfile = '/Volumes/cruise/RR2408/ctd/data/RR2408_Cast2.cnv';
dctd = readtable(ctdfile,'FileType','text','NumHeaderLines',149);
dctd.Properties.VariableNames = {'Pressure_db','Salinity_psu','Temp_degC','Time_sec','_'}

%% load the ctd data from the drifter
% filedir = '/Volumes/Shared/ONR_DRIFTER/2023_Fall_Kelvin_Seamount/Drifter5_Acoustic3_20231009T182000_20231010T125000/CTD';
% filename = fullfile(filedir,'aml_log_2023-10-09_18-22-34.aml');

use_remote_path = true;
[data_basedir,procdata_basedir,gitpath] = setUpDrifterPaths(use_remote_path,1);
expt = '2023_Fall_Kelvin_Seamount';
drifter_num = 5;
if isempty(drifter_num)
    filelist = dir(fullfile(data_basedir,expt,'*','CTD','*.aml'));
else
    filelist = dir(fullfile(data_basedir,expt,sprintf('Drifter%i*',drifter_num),'CTD','*.aml'));
end
ctd = [];
for fileidx = 1:length(filelist)

    filename = fullfile(filelist(fileidx).folder,filelist(fileidx).name);

    ctd_tmp = readCTD(filename,lat);
    ctd = vertcat(ctd,ctd_tmp);
end


% ctd = readCTD(filename,lat);

tidx = find(ctd.Time_UTC >= plot_times_utc(1) & ctd.Time_UTC <= plot_times_utc(2)) ;
ctd_tmp = ctd(tidx,:);

tidx_deep = find(ctd.Time_UTC >= plot_times_utc_deep(1) & ctd.Time_UTC <= plot_times_utc_deep(2)) ;
ctd_deep = ctd(tidx_deep,:);
ctd_deep(ctd_deep.Depth>540|ctd_deep.Depth<=200,:) = [];

ctd = vertcat(ctd_tmp,ctd_deep);
% ctd = ctd_tmp;

%% create smoothed profile 
if 0
    % create smoothed profile
    dctd.Depth = sw_dpth(dctd.Pressure_db,lat);
    [unique_depths,idx] = unique(dctd.Depth);
    tmp_temp = dctd.Temp_degC(idx);
    tmp_salt = dctd.Salinity_psu(idx);
else
    [unique_depths,idx] = unique(ctd.Depth);
    tmp_temp = [ctd.TempCT(idx), ctd.TempSVT(idx)];
    tmp_salt = [ctd.SalinityCT(idx), ctd.SalinitySVT(idx)];
end

figure
ax(1) = subplot(1,3,1);
plot(tmp_temp,-unique_depths,'.')
hold on
xlim([0 25])
ax(2) = subplot(1,3,2);
plot(tmp_salt,-unique_depths,'.')
hold on
xlim([30 40])
ax(3) = subplot(1,3,3);
plot(ctd.SoundSpeedSVT,-ctd.Depth,'.','linewidth',2)
hold on

%% combine measurements and interpolate to a regular depth grid 

depth = min(ctd.Depth):1:max(unique_depths);
% depth = [1:5:60 70:10:max(ctd_data.Depth)];

temp = pchip(unique_depths,mean(tmp_temp,2),depth);
salt = pchip(unique_depths,mean(tmp_salt,2),depth);
%temp = interp1(unique_depths,mean(tmp_temp,2,'omitnan'),depth,'linear','extrap');
%salt = interp1(unique_depths,mean(tmp_salt,2,'omitnan'),depth,'linear','extrap');

subplot(1,3,1)
plot(temp,-depth,'linewidth',2)
subplot(1,3,2)
plot(salt,-depth,'linewidth',2)

%% now lets smooth the result
[b,a] = butter(4,0.09,'low'); 
% [b,a] = butter(4,0.06,'low');
tempfilt = filtfilt(b,a,temp);
saltfilt = filtfilt(b,a,salt);

subplot(1,3,1)
plot(tempfilt,-depth,'-.','linewidth',2)

subplot(1,3,2)
plot(saltfilt,-depth,'-.','linewidth',2)

%% now extend with the hycom profile 
% get the water depth from gebco database
water_depth_m = abs(getElevationGEBCO(lon, lat, gebfile));
% lets get teh HYCOM profile for the beginning and end of the measurement 
switch extend_type
    case 'hycom'
        % get the hycom profiles over a spatial grid?
        % lon = (lon-1):0.1:(lon+1);
        % lat = (lat-1):0.1:(lat+1);
        
        hycom_times = ctd.Time_UTC([1 end]);
        downloadHYCOMFile(hycom_times,'ts3z',hycom_dir,0);
        hycom = readHYCOMFile(hycom_times,lon,lat,'ts3z',hycom_dir,0);
        
        % average over the time dimension
        time_dim = ndims(hycom.temp_degC);
        hycom.temp_degC = squeeze(mean(hycom.temp_degC,time_dim));
        hycom.salt_psu = squeeze(mean(hycom.salt_psu,time_dim));
        
        pres= sw_pres(hycom.depth_m,lat);
        hycom.sound_speed = sw_svel(hycom.salt_psu,hycom.temp_degC,pres);
        
        subplot(1,3,1)
        plot(hycom.temp_degC,-hycom.depth_m)
        
        subplot(1,3,2)
        plot(hycom.salt_psu,-hycom.depth_m)
        
        
        pres= sw_pres(hycom.depth_m,lat);
        hycom.sound_speed = sw_svel(hycom.salt_psu,hycom.temp_degC,pres);
        
        depth_ext = [depth hycom.depth_m(hycom.depth_m>stitch_depth_m & hycom.depth_m<water_depth_m).'];
        depth_ext = [depth_ext water_depth_m+200];
        
        new_depths = depth(1):1:max(depth_ext);
        
        temp_ext = [tempfilt hycom.temp_degC(hycom.depth_m>stitch_depth_m).'];
        temp_ext = spline(depth_ext(~isnan(temp_ext)),temp_ext(~isnan(temp_ext)),new_depths);
        % temp_ext = interp1(depth_ext(~isnan(temp_ext)),temp_ext(~isnan(temp_ext)),depth_ext,'linear','extrap');
        
        salt_ext = [saltfilt hycom.salt_psu(hycom.depth_m>stitch_depth_m).'];
        % salt_ext = interp1(depth_ext(~isnan(saltfilt)) ,salt_ext(~isnan(saltfilt)) ,hycom.depth_m,'linear','extrap');
        % salt_ext = interp1(depth_ext(~isnan(salt_ext)) ,salt_ext(~isnan(salt_ext)) ,depth_ext,'linear','extrap');
        salt_ext = spline(depth_ext(~isnan(salt_ext)),salt_ext(~isnan(salt_ext)),new_depths);
        
        
    
        subplot(1,3,1)
        plot(temp_ext,-new_depths,'-.','linewidth',2)
        grid on
        set(gca,'FontSize',14,'FontWeight','bold')
        xlabel('Temp, deg C')
        ylabel('Depth, m')
        
        subplot(1,3,2)
        plot(salt_ext,-new_depths,'-.','linewidth',2)
        grid on
        set(gca,'FontSize',14,'FontWeight','bold')
        xlabel('Salinity, psu')
        ylabel('Depth, m')
    
        subplot(1,3,3);
        plot(hycom.sound_speed,-hycom.depth_m)
    
        pres_ext= sw_pres(new_depths,lat);
        sound_speed_ext = sw_svel(salt_ext,temp_ext,pres_ext);

    case 'deep_ctd'
        ctd_ssp = load('ssp_ship_ctd.mat');

        subplot(1,3,1)
        plot(ctd_ssp.ssp.temp_degc,-ctd_ssp.ssp.depth_m)
        
        subplot(1,3,2)
        plot(ctd_ssp.ssp.salt_psu,-ctd_ssp.ssp.depth_m)

        depth_ext = [depth ctd_ssp.ssp.depth_m(ctd_ssp.ssp.depth_m>stitch_depth_m)];% & ctd_ssp.ssp.depth_m<water_depth_m)];
        depth_ext = [depth_ext water_depth_m+200];
        
        new_depths = depth(1):1:max(depth_ext);
        
        temp_ext = [tempfilt ctd_ssp.ssp.temp_degc(ctd_ssp.ssp.depth_m>stitch_depth_m)];
        temp_ext = spline(depth_ext(~isnan(temp_ext)),temp_ext(~isnan(temp_ext)),new_depths);
        % temp_ext = interp1(depth_ext(~isnan(temp_ext)),temp_ext(~isnan(temp_ext)),depth_ext,'linear','extrap');
        
        salt_ext = [saltfilt ctd_ssp.ssp.salt_psu(ctd_ssp.ssp.depth_m>stitch_depth_m)];
        % salt_ext = interp1(depth_ext(~isnan(saltfilt)) ,salt_ext(~isnan(saltfilt)) ,hycom.depth_m,'linear','extrap');
        % salt_ext = interp1(depth_ext(~isnan(salt_ext)) ,salt_ext(~isnan(salt_ext)) ,depth_ext,'linear','extrap');
        salt_ext = spline(depth_ext(~isnan(salt_ext)),salt_ext(~isnan(salt_ext)),new_depths);
        
                subplot(1,3,1)
        plot(temp_ext,-new_depths,'-.','linewidth',2)
        grid on
        set(gca,'FontSize',14,'FontWeight','bold')
        xlabel('Temp, deg C')
        ylabel('Depth, m')
        
        subplot(1,3,2)
        plot(salt_ext,-new_depths,'-.','linewidth',2)
        grid on
        set(gca,'FontSize',14,'FontWeight','bold')
        xlabel('Salinity, psu')
        ylabel('Depth, m')
    
        subplot(1,3,3);
        plot(ctd_ssp.ssp.sound_speed_mps,-ctd_ssp.ssp.depth_m)
    
        pres_ext= sw_pres(new_depths,lat);
        sound_speed_ext = sw_svel(salt_ext,temp_ext,pres_ext);
    otherwise
        new_depths = depth;
        pres= sw_pres(depth,lat);
        temp_ext = tempfilt;
        salt_ext = saltfilt;
        sound_speed_ext = sw_svel(saltfilt,tempfilt,pres);
end





subplot(1,3,3);
plot(sound_speed_ext,-new_depths,'linewidth',2)
grid on
set(gca,'FontSize',14,'FontWeight','bold')
xlabel('Sound Speed, m/s')
ylabel('Depth, m')

ssp.water_depth_m = water_depth_m;
ssp.sound_speed_mps = sound_speed_ext;
ssp.depth_m = new_depths;
ssp.temp_degc   = temp_ext;
ssp.salt_psu = salt_ext;
ssp.time_range_utc = [min(ctd.Time_UTC) max(ctd.Time_UTC)];

save(savefilename,"ssp");
