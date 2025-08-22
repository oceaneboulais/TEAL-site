% Grabbing HYCOM data for TFO2
% This script is adapted to read from both the hidcasts and forecasts
%
% Updated for LJCT
% Alex Andriatis 02-10-2022
% 
% Edited by A. Laferriere 08-22-2025

try

tic;

addpath('Read_Hycom');
addpath(genpath('MATLAB'))

% Test the hycom reading script
datapath = 'HYCOM';

hindcastpath = fullfile(datapath,'Hindcast');
forecastpath = fullfile(datapath,'Forecast');

if ~isfolder(hindcastpath)
    mkdir(hindcastpath)
end
if ~isfolder(forecastpath)
    mkdir(forecastpath)
end
desired_time_utc = datenum(2021,10,1);

tdays = 1; % number of days to run the forecast over 

tnow = getUTC_3h(desired_time_utc);

tlim = [tnow-tdays/2 tnow+tdays/2];
times = [tlim(1):3/24:tlim(end)];
lonlim = [-127 -116];
latlim = [27 35];
depthlim = [0 500];


sourcepath_hindcast = 'http://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0'; % May 2019-present
sourcepath_forecast = 'http://tds.hycom.org/thredds/dodsC/GLBy0.08/expt_93.0/FMRC/GLBy0.08_930_FMRC_best.ncd'; % Best forecast

% Read HYCOM
parfor t= 1:length(times)
% for t= 1:length(times)
    % There's a problem that often the HYCOM server drops out, so the reading needs to be re-launched.
    % Let's do a maximum of 10 attempts
    attempts=0;
    isdone = 0;
    while attempts<10 && ~isdone
      try
          time = times(t);
          disp(['Reading data for ' datestr(time)]);
          
          % Check if the file already exists
          fname = ['HYCOM_' datestr(time,'yyyymmddTHHMMSS') '.mat'];
          filename = fullfile(hindcastpath,fname);
          if exist(filename,'file')
              disp(['File already exists for the target time ' fname]);
          else
              % Try reading the hindcast
              reload=0;
	      disp(['Reading hindcast for ' datestr(time)]);
              [~,exitstatus] = get_HYCOM(time,lonlim,latlim,depthlim,hindcastpath,sourcepath_hindcast,reload);

              % If the requested time doesn't exist yet, check the forecast
              if exitstatus==0
		  disp(['Reading forecast for ' datestr(time)]);
                  reload=1;
                  [~,exitstatus] = get_HYCOM(time,lonlim,latlim,depthlim,forecastpath,sourcepath_forecast,reload);
              end
          end
        disp('Done reading');
        isdone=1;
      catch e
        warning(['Problem in get_HYCOM during attempt ' num2str(attempts)]);
            fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
            fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
      end
      attempts = attempts+1;
    end
    if ~isdone
        disp('Code did not finish reading the requested dataset');
    else
        disp('Success');
    end
end

toc;

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end
