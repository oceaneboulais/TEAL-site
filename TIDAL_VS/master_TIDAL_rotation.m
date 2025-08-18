%% tidalrotation_master.m
function master_TIDAL_rotation(dataFolder,NAS_avg_time)
% Rotate raw TiDAL data
% Input:
%   dataFolder: Folder containing matching Analog and Digital TiDAL Data
%   NAS_avg_time: number of seconds over which NAS data is averaged

addpath EnumClass

%NAS_avg_time=0.5;  %Averaging time for NAS data in sec

%dataFolder='June2025.dir';
%dataFolder='../TiDAL_March_2025_Pier_Calib/Unit001_VS107/2025-03-10T0918/';
% Get list of .wav files
wavfiles_struct = dir(fullfile(dataFolder, '*VS-209sensor.wav'));

% Extract file names into a cell array
wavfiles = {wavfiles_struct.name};
wavfiles = wavfiles(~startsWith(wavfiles, '.'));
numFiles = length(wavfiles);

for Ifile = 1:numFiles
    tt=tic;
    % Load .wav file
    wavfile = wavfiles{Ifile};
    [x,Fs] = audioread(fullfile(dataFolder,wavfile),'native');
    info = audioinfo(fullfile(dataFolder,wavfile));

    % Load corresponding NAS Data
    matfile = dir([dataFolder filesep 'DigitalData-' wavfile(12:end-10) '*.mat']);
    NASdata=load(fullfile(dataFolder,matfile.name));

    %%%%% Channels 7,8,9 are x,y,z magnetometer
    %%% Channels 4,5,6 are x,y,z accelerometer.

    NASdata.DigitalDataMeas=[NASdata.DigitalDataMeas(1,:); NASdata.DigitalDataMeas];
    NASdata.g=NASdata.DigitalDataMeas(:,4:6);
    NASdata.m=NASdata.DigitalDataMeas(:,7:9);
    naslen = size(NASdata.DigitalDataMeas,1);  %Sampled every 10 seconds
    NASdata.dt=1./NASdata.DigitalPar.Header.SampleRate;

    t_NAS=NASdata.dt*(0:(naslen-1));  %time axis of NAS data in seconds
    t_NAS_update=unique([0:NAS_avg_time:max(t_NAS) max(t_NAS)]);
    acoulen = size(x,1);  %%Five minute file
    t_ac=(0:(acoulen-1))./Fs;

    
    if Ifile==1
        g_all=zeros(acoulen,3);
        m_all=zeros(acoulen,3);
    end

    for I=1:3
        g_all(:,I)=interp1(t_NAS,NASdata.g(:,I),t_ac);
        m_all(:,I)=interp1(t_NAS,NASdata.m(:,I),t_ac);
    end

    for It=1:(length(t_NAS_update)-1)
        Igood=find((t_ac>=t_NAS_update(It)) & (t_ac<t_NAS_update(It+1)));
        m=mean(m_all(Igood,:));
        g=mean(g_all(Igood,:));
        
        % Compute rotation matrix
        u = -g ./ vecnorm(g);
        e = cross(g, m);
        w = -e ./ vecnorm(e);
        n = cross(e, g);
        n = n ./ vecnorm(n);
    
        %x(Igood,2:4)=([n;w;u]*(x(Igood,2:4)'))';  %Original reference
        %frame
        x(Igood,2:4)=(-[-w;n;u]*(x(Igood,2:4)'))';

    end
   
    %newtit = [dataFolder filesep wavfile(1:end-4) '_rot.wav'];
    newtit = [ wavfile(1:end-4) '-rot.wav']; %%%IMPORTANT-use a dash, not underscore, otherwise Ulysess gets confused
    audiowrite(fullfile(dataFolder,newtit),x,Fs,"BitsPerSample",info.BitsPerSample);
    toc(tt)
end
end