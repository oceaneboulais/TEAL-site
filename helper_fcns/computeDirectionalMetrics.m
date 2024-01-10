function metrics = computeDirectionalMetrics(P,V,do_3D_metrics,compass_offset,elevation_offset)

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

metrics.rho = 1000; 
metrics.sound_speed = 1500;
metrics.compass_offset = compass_offset;
metrics.elevation_offset = elevation_offset;

P = squeeze(P);

% convert the "velocity" channels to velocity units
VtoP = (metrics.rho*metrics.sound_speed);
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

Ix=squeeze(conj(P).*Vx);
Iy=squeeze(conj(P).*Vy);

if ~isempty(Vz)
    Iz = conj(P).*Vz;
    Ixy = sqrt(real(Ix).^2 + real(Iy).^2);
    elegram = atan2d(real(Iz),Ixy);
else
    Iz = zeros(size(Ix));
    Vz = zeros(size(Vx));
    elegram = [];
end

metrics.I = cat(3,Ix,Iy,Iz);
metrics.P = P;

% we define azigram in terms of compass direction
% assuming v dims are Vx,Vy,Vz, or Vew,Vns
metrics.azigram = wrapTo360(atan2d(real(Ix),real(Iy)) + compass_offset);
metrics.elegram = wrapTo180(elegram + elevation_offset);



% pressure_autospectrum=squeeze(abs(P).^2);  
% normalized_velocity_autospectrum=squeeze(abs(Vx).^2+abs(Vy).^2);
% energy_density=0.5*abs(normalized_velocity_autospectrum+pressure_autospectrum);
% polarization=(real(Vx).*imag(Vy)-real(Vy).*imag(Vx));
% polarization=-2*squeeze(polarization./(abs(Vx).^2+abs(Vy).^2));
% 
% mu = single(atan2d(real(Ix),real(Iy)));  %Compass convention (usually atan2d(y,x))
% intensity=sqrt((real(Ix)).^2+(real(Iy)).^2);
% 
% output_array.Directionality=wrapTo360(compass_offset+mu);          
% output_array.ItoERatio=intensity./energy_density;
% output_array.KEtoPERatio=normalized_velocity_autospectrum./pressure_autospectrum;
% output_array.Polarization=polarization;
% output_array.IntensityPhase=atan2d(sqrt(imag(Ix).^2+imag(Iy).^2),sqrt((real(Ix)).^2+(real(Iy)).^2));
% output_array.PhaseSpeed=1450*pressure_autospectrum./sqrt((real(Ix)).^2+(real(Iy)).^2);

pressure_autospectrum = 0.5*squeeze(abs(P).^2)./(metrics.rho*metrics.sound_speed^2);

factor=2*metrics.sound_speed.^2;
if metrics.do_3D_metrics && ~isempty(elegram)
    normalized_velocity_autospectrum=0.5*metrics.rho.*(abs(Vx).^2+abs(Vy).^2+abs(Vz).^2);
    metrics.phase_speed =factor*pressure_autospectrum./sqrt((real(Ix)).^2+(real(Iy)).^2+(real(Iz)).^2);
    metrics.intensity=sqrt((real(Ix)).^2+(real(Iy)).^2+(real(Iz)).^2);
    metrics.intensity_phase_z = atan2d(imag(Iz),real(Iz));
else
    normalized_velocity_autospectrum=0.5*metrics.rho.*(abs(Vx).^2+abs(Vy).^2);
    metrics.phase_speed =factor*pressure_autospectrum./sqrt((real(Ix)).^2+(real(Iy)).^2);
    metrics.intensity=sqrt(real(Ix).^2+real(Iy).^2);
end

metrics.energy_density=normalized_velocity_autospectrum + pressure_autospectrum;


transport_velocity = metrics.intensity./metrics.energy_density;
metrics.normalized_transport_velocity =  transport_velocity/metrics.sound_speed;

rho = 1000; c = 1500;
U = computeTransportVelocity(Ix/(rho*c),Iy/(rho*c),Vx/(rho*c),Vy/(rho*c),P,rho,c);


metrics.KEtoPEratio=normalized_velocity_autospectrum./pressure_autospectrum;

metrics.intensity_phase = atan2d(sqrt(real(Ix).^2+real(Iy).^2),sqrt((imag(Ix)).^2+(imag(Iy)).^2));

