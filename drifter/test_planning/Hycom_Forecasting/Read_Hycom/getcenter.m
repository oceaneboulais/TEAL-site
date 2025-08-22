% Grab a single vertical profile from a hycom dataset, to reduce file size
%
% Alex Andriatis
% 2021-05-02

try

tic;
addpath(genpath('MATLAB'))
datapath = 'HYCOM';
filename='Hycom_Timeseries.mat';
savename='Hycom_Timeseries_Center.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

lonc=-117.7398;
latc=32.9087;

[data1.longitude,lonI] = closest(data.longitude,lonc);
[data1.latitude,latI] = closest(data.latitude,latc);

fields=fieldnames(data);
NX = length(data.longitude);
NY = length(data.latitude);
NZ = length(data.depth);
NT = length(data.time);

for i=1:length(fields)
    field=fields{i};
    tmp = data.(field);
    if ndims(tmp)==4 & all(size(tmp)==[NX NY NZ NT])
        data1.(field)=squeeze(tmp(lonI,latI,:,:));
    end
end

for i=1:length(fields)
    field=fields{i};
    tmp = data.(field);
    if ndims(tmp)==3 & all(size(tmp)==[NX NY NT])
        data1.(field)=squeeze(tmp(lonI,latI,:));
    end
end
data1.depth=data.depth;
data1.time = data.time;

save(fullfile(datapath,savename),'-struct','data1','-v7.3');
disp(['Saved profile in center of region in ' savename]);

toc;

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end

