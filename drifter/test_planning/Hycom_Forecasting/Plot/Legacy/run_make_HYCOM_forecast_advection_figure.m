% This script runs the figure-making scripts for the hycom fields
% Alex Andriatis
% 2021-05-03
try
tic;

addpath('/home/aandriat/Hycom_Forecasting');
addpath('/home/aandriat/Hycom_Forecasting/Plot');

make_HYCOM_forecast_advection_figure('png',2);
make_HYCOM_forecast_advection_figure('movie',2);

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end

