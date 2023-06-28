function v = getReplicaVector(f,p,elev_deg,ang_deg,c)
% Computes the array manifold vector (replica vector)
% INPUTS
% f: freq in Hz
% p: sensor position Nchan x 3
% elev_deg: elevation angle in deg (0 deg in horizontal)
% ang_deg: azimuth in deg
% c: sound speed in m/s
% OUTPUTS
% v: the array maniford vector freq x Nchannels x azimuths x elevations

omega = 2*pi*f(:);

ang_deg = permute(ang_deg(:), [2,3,4,1,5]);
elev_deg = permute(elev_deg(:),[2,3,1,4] );

% get wavenumber vector k, size is freq x 1 x elevations x azimuths x 3(xyz)
k(:,1,:,:,1) = -(omega/c).*cosd(ang_deg).*cosd(elev_deg); 
k(:,1,:,:,2) = -(omega/c).*sind(ang_deg).*cosd(elev_deg); 
k(:,1,:,:,3) = -(omega/c).*ones(size(ang_deg)).*sind(elev_deg);

% get x, size is 1 x Nchannels x 1 x 1 x 3(xyz)
x = permute(p, [3,1,4,5,2]); % (1,1,chan,1,xy)

% do the dot product to compute k'p for each freq, channel, elevation, and azimuth
% resulting size is freq x Nchannels x elevations x azimuths
% using a loop because we ran into a memory issue with too large of a
% variable size for k (dot) x
%[uV sV] = memory;
% if numel(k)*size(x,2)*8 > 0.75*sV.PhysicalMemory.Available
%     for ii = 1:size(k,1)
%         k_dot_x(ii,:,:,:) = sum(k(ii,:,:,:,:).*x(:,:,:,:,:),5); % delay of arrival time relative to position [0,0] 
%     end
% else
k_dot_x = sum(k.*x,5);
% end

% finally, compute the replica vector (the array manifold vector)
% v=exp(-jk'p), size is freq x Nchannels x elevations x azimuths
v = exp(-1i*k_dot_x);