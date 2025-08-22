%% Combining HYCOM data files
% Because reading multiple HYCOM times takes a painfully long time, I load
% days individually and then combine the fields

try

tic;

datapath = '/home/aandriat/Data/HYCOM';
hindcastpath = fullfile(datapath,'Hindcast');
forecastpath = fullfile(datapath,'Forecast');

tnow = getUTC_3h;

tlim = [tnow-7 tnow+7];
times = [tlim(1):3/24:tlim(end)];

combined=[];
varnames1d = {'time'};
varnames2d = {'ssh'};
varnames3d = {'temperature','salinity','u','v'};

for t=1:length(times)
    time=times(t);
    fname = ['HYCOM_' datestr(time,'yyyymmddTHHMMSS') '.mat'];
    if exist(fullfile(hindcastpath,fname),'file')
      fpath = fullfile(hindcastpath,fname);
      disp(['Loading hindcast data from ' fname]);
    elseif exist(fullfile(forecastpath,fname),'file')
      fpath = fullfile(forecastpath,fname);
      disp(['Loading forecast data from ' fname]);
    else
      disp(['No data found for the requested time ' datestr(time)]);
      continue;
    end

    D = load(fpath);
    for n=1:length(varnames1d)
        name = varnames1d{n};
        combined.(name)(t) = D.(name);
    end
    for n=1:length(varnames2d)
	name = varnames2d{n};
	combined.(name)(:,:,t) = D.(name);
    end
    for n=1:length(varnames3d)
	name = varnames3d{n};
        combined.(name)(:,:,:,t) = D.(name);
    end
    if t==1
        combined.depth = D.depth;
        combined.longitude = D.longitude;
        combined.latitude = D.latitude;
    end
end

[combined.time,I] = unique(combined.time);
combined.ssh = combined.ssh(:,:,I);

for n=1:length(varnames3d)
    combined.(varnames3d{n}) = combined.(varnames3d{n})(:,:,:,I);
end

savepath = fullfile(datapath,'LJCT_Hycom_Timeseries.mat');
save(savepath,'-struct','combined','-v7.3');
disp(['Saved combined data in ' savepath ]);

toc;

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end
