%% Add derived fields to HYCOM data
%
%
% Alex Andriatis
% 2021-05-02
try

tic;
addpath(genpath('MATLAB'))
datapath = 'HYCOM';
filename='Hycom_Timeseries.mat';

fpath = fullfile(datapath,filename);
data = load(fpath);

% Add absolute salinity and conservative temperature fields
p = gsw_p_from_z(-data.depth,mean(data.latitude));

data.SA = NaN(size(data.salinity));
data.T = data.SA;
data.SP = data.SA;
data.CT = data.SA;
data.sigma0 = data.SA;
data.sound_speed = data.SA;

for t=1:length(data.time)
    disp(['Calculating derived quantities for time ' num2str(t) ' of ' num2str(length(data.time))]);
    for k=1:length(data.depth)
        
        T = squeeze(data.temperature(:,:,k,t));
        SP = squeeze(data.salinity(:,:,k,t));
       
        SA = gsw_SA_from_SP(SP,p(k),data.longitude,data.latitude);
        CT = gsw_CT_from_t(SA,T,p(k));
        sigma0 = gsw_sigma0(SA,CT);
        sound_speed = gsw_sound_speed(SA,CT,p(k));
        
        data.T(:,:,k,t)=T;
        data.SP(:,:,k,t)=SP;
        data.SA(:,:,k,t)=SA;
        data.CT(:,:,k,t)=CT;
        data.sigma0(:,:,k,t)=sigma0;
        data.sound_speed(:,:,k,t)=sound_speed;
    end
end

MLD = NaN(size(data.T,[1 2 4]));
for i=1:length(data.longitude)
    disp(['Calculing MLD for longitude ' num2str(i) ' of ' num2str(length(data.longitude))]);
    for j=1:length(data.latitude)
        for t=1:length(data.time)
            SA = squeeze(data.SA(i,j,:,t));
            CT = squeeze(data.CT(i,j,:,t));
            mlp = gsw_mlp(SA,CT,p);
            MLD(i,j,t)=mlp;
        end
    end
end
data.MLD = MLD;

save(fpath,'-struct','data','-v7.3');
disp(['Added derived variables to' fpath]);

toc;

catch e
  fprintf(2,'There was an error! The message was:\n\t\t%s\n',e.message);
  fprintf(2,'The identifier was:\n\t\t%s\n',e.identifier);
end


