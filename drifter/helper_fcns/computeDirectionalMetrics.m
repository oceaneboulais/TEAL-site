function [metrics,Ix,Iy,Iz] = computeDirectionalMetrics(P,V,do_3D_metrics,compass_offset,elevation_offset,T,time_avg,v_is_scaled)

if ~exist('do_3D_metrics','var')
    metrics.do_3D_metrics = false;
else
    metrics.do_3D_metrics = do_3D_metrics;
end

if ~exist('compass_offset','var')
    compass_offset = 0;
end

if ~exist('elevation_offset','var')
    elevation_offset = 0;
end
if ~exist('time_avg','var')
    time_avg = [];
elseif time_avg==0
    time_avg=[];
end
if ~exist('v_is_scaled','var')
    v_is_scaled = true;
end

metrics.rho = 1000; 
metrics.sound_speed = 1500;
metrics.compass_offset = compass_offset;
metrics.elevation_offset = elevation_offset;

P = squeeze(P);

% convert the "velocity" channels to velocity units
if ~v_is_scaled
    % v is already in velocity units, don't scale
    VtoP = 1;
else
    % V has already been scaled to have pressure units, convert it back
    VtoP = (metrics.rho*metrics.sound_speed);
end
% scale velocity BACK to velocity units if it has been scaled to pressure
% units
V = V/VtoP;

if size(V,1)==3
    Vx = squeeze(V(1,:,:));
    Vy = squeeze(V(2,:,:));
    Vz = squeeze(V(3,:,:));
elseif size(V,1)==2
    Vx = squeeze(V(1,:,:));
    Vy = squeeze(V(2,:,:));
    % Vz = zeros(size(Vy));
    Vz = [];
elseif size(V,3)==3
    Vx = squeeze(V(:,:,1));
    Vy = squeeze(V(:,:,2));
    Vz = squeeze(V(:,:,3));
elseif size(V,3)==2
    Vx = squeeze(V(:,:,1));
    Vy = squeeze(V(:,:,2));
    Vz = [];
end

Psq = abs(P).^2;
Vxsq = abs(Vx).^2;
Vysq = abs(Vy).^2;


Ix=squeeze(conj(P).*Vx);
Iy=squeeze(conj(P).*Vy);

if ~isempty(Vz)
    Iz = conj(P).*Vz;
else
    Iz = zeros(size(Ix));
    Vz = zeros(size(Vx));
    metrics.elegram = [];
end
Vzsq = abs(Vz).^2;

if ~isempty(time_avg)

    disp('Starting intensity time averaging...')

    %Consolidate time bins
    Ninc=ceil(time_avg./T(1));  %%Number of samples per beampattern.
    Nt = length(T);
    Nbeam_count=floor(Nt./Ninc);
    Itindex=Ninc:Ninc:Nt;
    Itindex=Itindex-round(Ninc/2);
    for Ibeam=1:Nbeam_count
        indexx=1+(Ibeam-1)*Ninc+(0:(Ninc-1));
        Ix(:,Ibeam)=mean(Ix(:,indexx),2);
        Iy(:,Ibeam)=mean(Iy(:,indexx),2);
        Iz(:,Ibeam)=mean(Iz(:,indexx),2);
        Psq(:,Ibeam) = mean(Psq(:,indexx),2);
        Vxsq(:,Ibeam) = mean(Vxsq(:,indexx),2);
        Vysq(:,Ibeam) = mean(Vysq(:,indexx),2);
        Vzsq(:,Ibeam) = mean(Vzsq(:,indexx),2);
    end
    Ix = Ix(:,1:Ibeam);
    Iy = Iy(:,1:Ibeam);
    Iz = Iz(:,1:Ibeam);
    Psq = Psq(:,1:Ibeam);
    Vxsq = Vxsq(:,1:Ibeam);
    Vysq = Vysq(:,1:Ibeam);
    Vzsq = Vzsq(:,1:Ibeam);
    metrics.T = T(Itindex);
    disp('Finished time averaging.')
end



metrics.I = single(cat(3,Ix,Iy,Iz));
metrics.PdB = single(10*log10(Psq));

% we define azigram in terms of compass direction
% assuming v dims are Vx,Vy,Vz, or Vew,Vns

%%%%%Azigram computation
metrics.azigram = single(wrapTo360(atan2d(real(Ix),real(Iy)) + compass_offset));
Ixy = sqrt(real(Ix).^2 + real(Iy).^2);
metrics.elegram = single(atand(real(Iz)./Ixy));

pressure_autospectrum = 0.5*squeeze(Psq)./(metrics.rho*metrics.sound_speed^2);

factor=2*metrics.sound_speed.^2;
if metrics.do_3D_metrics && ~isempty(metrics.elegram)
    normalized_velocity_autospectrum=0.5*metrics.rho.*(Vxsq+Vysq+Vzsq);
    
    metrics.phase_speed =factor*pressure_autospectrum./sqrt((real(Ix)).^2+(real(Iy)).^2+(real(Iz)).^2);
    metrics.intensity=sqrt((real(Ix)).^2+(real(Iy)).^2+(real(Iz)).^2);
    metrics.intensity_phase_z = atan2d(imag(Iz),real(Iz));
    metrics.intensity_phase_z =single(metrics.intensity_phase_z);
else
    normalized_velocity_autospectrum=0.5*metrics.rho.*(Vxsq+Vysq);
    
    metrics.phase_speed =factor*pressure_autospectrum./sqrt((real(Ix)).^2+(real(Iy)).^2);
    metrics.intensity=sqrt(real(Ix).^2+real(Iy).^2);
end

metrics.phase_speed=single(metrics.phase_speed);
metrics.intensity=single(metrics.intensity);

metrics.energy_density=single(normalized_velocity_autospectrum + pressure_autospectrum);


transport_velocity = metrics.intensity./metrics.energy_density;
metrics.normalized_transport_velocity =  transport_velocity/metrics.sound_speed;
metrics.normalized_transport_velocity = single(metrics.normalized_transport_velocity);


metrics.KEtoPEratio=single(normalized_velocity_autospectrum./pressure_autospectrum);

metrics.intensity_phase = atan2d(sqrt(imag(Ix).^2+imag(Iy).^2),sqrt((real(Ix)).^2+(real(Iy)).^2));
metrics.intensity_phase = single(metrics.intensity_phase);



