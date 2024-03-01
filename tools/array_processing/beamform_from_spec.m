function [B,Bpow] = beamform_from_spec(S,f,az_deg,elev_deg,pos,w,do_power)
% conventional beamformer in FFT domain:
%
% INPUTS:
%       S:    complex spectrogram [freq time element]
%       pos   position of sensors
%       az_deg   (vector) angle from x-axis to y-axis in array coordinates
%       elev_deg     (vector)   elevation up from the horizontal
%
% OUTPUTS:
%       B(freq,time,azimuth,elevation)
verbose = false;
c = 1500;

Nt = size(S,2);
Nf = length(f);
Nch = size(pos,1);
Naz = length(az_deg);
Nel = length(elev_deg);

if ~exist('do_power','var')
    do_power = false;
end

if ~exist('w','var')||isempty(w)
    w(1,1,:) = ones(Nch,1)/Nch;
else
    w(1,1,:) = w(:);
end

% Put all quantities in the following dimensions
% ang_deg = permute(ang_deg(:), [2,3,4,5,1,6]);
% elev_deg = permute(elev_deg(:), [2,3,4,1,5]);
az_deg = permute(az_deg(:), [2,3,4,1,5]);
elev_deg = permute(elev_deg(:),[2,3,1,4] );

v = getReplicaVector(f,pos,elev_deg,az_deg,c);
%%Output of v is [Nfreq Nel Nazi Nelevation]

v = permute(v,[1 5 2 3 4]);
%%v now has [f ? Nel ? Nelevation]
% S = permute(S,[1 3 4 5 2]);
% for fidx = 1:length(f)
%     B(fidx,:,:) = sum((w.'.*S(fidx,:,:,:,:) .* v(fidx,:,:,:)),2);
% end

[~,minDim] = min([Nt Nf Naz Nel]);

H = v.*w;  %%Final array weight  [freq ? Nel ? Nelevation]
% try 
num_elements = Nt*Nf*Nch*Naz*Nel;
array_size_GB = 2*num_elements*8/1024^3;
B = zeros(Nf,Nt,Naz,Nel);
if do_power
    Bpow = zeros(Nf,Nt,Naz,Nel);
end
if array_size_GB < 20
    fprintf('BF: vectorized direct multiplication\n')
    % first see if we can do it all at once
    B = sum(conj(H).*S,2);
    B = permute(B, [1,5,3,4,2]);
    if do_power
        Bpow = conj(B).*B;
    end
% catch 
else
    % if that fails,
    % % loop over freq, the first dimension
    % tic
    % B = zeros(Nf,Nt,Naz,Nel);
    % Bpow = zeros(Nf,Nt,Naz,Nel);
    % for ii = 1:Nf
    %     B(ii,:,:,:,:) = sum(conj(H(ii,:,:,:,:)).*S(ii,:,:,:,:),3);
    %     Bpow(ii,:,:,:) = squeeze(conj(B(ii,:,:,:,:)  ) .* B(ii,:,:,:,:) ) ;
    % end
    % toc

    
    if Nel>1 & Naz==1
        % loop over elevation 
        fprintf('BF: looping over elevation\n')
        for ii = 1:Nel
            B(:,:,:,ii) = sum(conj(H(:,:,:,:,ii)).*S,3);
            if do_power
                Bpow(:,:,:,ii) = squeeze(conj(B(:,:,:,ii)  ) .* B(:,:,:,ii) ) ;
            end
        end

    elseif Naz>1 & Nel==1
        % loop over azimuth
        fprintf('BF: looping over azimuth\n')
        for ii = 1:Naz
            B(:,:,ii,:) = sum(conj(H(:,:,:,ii,:)).*S,3);
            if do_power
                Bpow(:,:,ii,:) = squeeze(conj(B(:,:,ii,:)  ) .* B(:,:,ii,:) ) ;
            end
        end
    else
        %loop over time, the 5th dimension
        fprintf('BF: looping over time\n')
        for ii = 1:Nt
            if verbose
                fprintf('%i of %i\n',ii,Nt)
            end
            B(:,ii,:,:,:) = sum(conj(H(:,:,:,:,:)).*S(:,ii,:,:,:),3);
            if do_power
                Bpow(:,ii,:,:) = conj(B(:,ii,:,:,:) ) .* B(:,ii,:,:,:) ;
            end
        end
    end


end %if arraysize
   
        
        
    


    
% B = permute(B, [1,2,4,5,3]);

% B = squeeze(B);




