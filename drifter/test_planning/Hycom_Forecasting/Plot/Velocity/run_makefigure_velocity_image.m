% This script runs the figure-making scripts for the hycom fields
% Alex Andriatis
% 2021-05-03
try
tic;

addpath(genpath('MATLAB'))
addpath(genpath('Plot'))

datapath = 'HYCOM';
filename='Hycom_Timeseries.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

makefigure_velocity('figure',1,datapath,data);
makefigure_velocity('figure',2,datapath,data);

toc;
catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end

