function B = beamform_from_spec(S,f,ang_deg,elev_deg,pos,w)
% conventional beamformer in FFT domain:
%
% INPUTS:
%       pos(chan,xy)    position of sensors
%       ang_deg(na,1)   angle from x-axis to y-axis in array coordinates
%
% OUTPUTS:
%       B(freq,time,angle)

c = 1500;

omega = 2*pi*f(:);

Nt = size(S,2);
Nf = length(f);
Nch = size(pos,1);
Naz = length(ang_deg);
Nel = length(elev_deg);

if ~exist('w','var')||isempty(w)
    w = ones(Nch,1)/Nch;
end

% Put all quantities in the following dimensions
% (freq,time,chan,ang,xy)
% ang_deg = permute(ang_deg(:), [2,3,4,5,1,6]);
% elev_deg = permute(elev_deg(:), [2,3,4,1,5]);
ang_deg = permute(ang_deg(:), [2,3,4,1,5]);
elev_deg = permute(elev_deg(:),[2,3,1,4] );

v = getReplicaVector(f,pos,elev_deg,ang_deg,c);

S = permute(S,[1 3 4 5 2]);
% for fidx = 1:length(f)
%     B(fidx,:,:) = sum((w.'.*S(fidx,:,:,:,:) .* v(fidx,:,:,:)),2);
% end

[~,minDim] = min([Nt Nf Naz Nel]);

H = v.*w.';
try 
    
    B = sum(conj(H).*S,2);
catch 
    B = zeros(Nf,1,Naz,Nel,Nt);
    for ii = 1:size(v,3)
        B(:,:,ii,:,:) = sum(conj(H(:,:,ii,:)).*S(:,:,:,:,:),2);
    end
end
   
        
        
    


    
% B = permute(B, [1,2,4,5,3]);
B = permute(B, [1,5,3,4,2]);
% B = squeeze(B);




