% This script runs the figure-making scripts for the hycom fields
% Alex Andriatis
% 2021-05-03
try
tic;

addpath('/home/aandriat/Hycom_Forecasting');
addpath('/home/aandriat/Hycom_Forecasting/Plot');

datapath = '/home/aandriat/Data/HYCOM';
filename='TFO2_Hycom_Timeseries.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

make_HYCOM_forecast_figure_new('figure',1,datapath,data);
make_HYCOM_forecast_figure_new('figure',2,datapath,data);
make_HYCOM_forecast_figure_new('movie',1,datapath,data);
make_HYCOM_forecast_figure_new('movie',2,datapath,data);

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end

