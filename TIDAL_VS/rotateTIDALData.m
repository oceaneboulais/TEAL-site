%%%% tidalrotation_master.m
function x = rotateTIDALData(x,NASdata,NAS_avg_time,Fs)
% Rotate raw TiDAL data
% Input:
%   dataFolder: Folder containing matching Analog and Digital TiDAL Data
%   NAS_avg_time: number of seconds over which NAS data is averaged
% 
% At present, individual histogram are generated from an entire file (5 minutes).

NASdata.DigitalDataMeas=[NASdata.DigitalDataMeas(1,:); NASdata.DigitalDataMeas];
NASdata.g=NASdata.DigitalDataMeas(:,4:6);
NASdata.m=NASdata.DigitalDataMeas(:,7:9);
naslen = size(NASdata.DigitalDataMeas,1);  %Sampled every 10 seconds
NASdata.dt=1./NASdata.DigitalPar.Header.SampleRate;

t_NAS=NASdata.dt*(0:(naslen-1));  %time axis of NAS data in seconds
t_NAS_update=unique([0:NAS_avg_time:max(t_NAS) max(t_NAS)]);
acoulen = size(x,1);  %%Five minute file
t_ac=(0:(acoulen-1))./Fs;


g_all=zeros(acoulen,3);
m_all=zeros(acoulen,3);

for I=1:3
    g_all(:,I)=interp1(t_NAS,NASdata.g(:,I),t_ac);
    m_all(:,I)=interp1(t_NAS,NASdata.m(:,I),t_ac);
end

for It=1:(length(t_NAS_update)-1)  %For each interpolated point...
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

