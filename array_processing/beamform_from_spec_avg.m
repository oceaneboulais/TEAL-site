function [Bpow,elev_hist,Fout] = beamform_from_spec_avg(S,T,freq,az_deg,elev_deg,pos,w,hist_param,fband)
% conventional beamformer in FFT domain:
%
% INPUTS:
%       S:    complex spectrogram [freq time element]
%       T:     time in seconds
%       freq:     frequencies in Hz
%       pos   position of sensors
%       az_deg   (vector) angle from x-axis to y-axis in array coordinates
%       elev_deg     (vector)   elevation up from the horizontal
%
% OUTPUTS:
%       B(freq,elevation,azimuth,time)
verbose = false;
c = 1500;

Nt = size(S,2);
Nf = length(freq);
Nch = size(pos,1);
Naz = length(az_deg);
Nel = length(elev_deg);



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

v = getReplicaVector(freq,pos,elev_deg,az_deg,c);
%%Output of v is [Nfreq Nchan Nazi Nelev]
% v: the array maniford vector freq x Nchannels x azimuths x elevations

disp('Permute weights')
v = permute(v,[1 5 2 3 4]);
toc
%%v now has [freq ? Nchan ? Nelev]
% S = permute(S,[1 3 4 5 2]);
% for fidx = 1:length(freq)
%     B(fidx,:,:) = sum((w.'.*S(fidx,:,:,:,:) .* v(fidx,:,:,:)),2);
% end

[~,minDim] = min([Nt Nf Naz Nel]);

H = v.*w;  %%Final array weight  [freq Ntime(1) Nel Nazi Nelevation]
% try
num_elements = Nt*Nf*Nch*Naz*Nel;
array_size_GB = 2*num_elements*8/1024^3;
B = zeros(Nf,Nt,Naz,Nel);

%if array_size_GB < 20
if array_size_GB < 100
    fprintf('BF: vectorized direct multiplication\n')
    % first see if we can do it all at once
    % H is dimension [Nfreq 1 Nchan Nazi Nelv]
    % S is dimension [Nfreq Ntime Nchan]
    %  element-by element multiplication is replicated across all azimuths
    %  and elevation angles.
    %  Original command sums across time, which is a mistake before
    %  computing the power
    %B = sum(conj(H).*S,2);
    %B = permute(B, [1,5,3,4,2]);  % [Nfreq Nelv Nchan]--must be error



    disp('Start beamforming over bands')
    for Iband = 1:size(fband,1)
        fprintf('Beamforming from %3.2f to %3.2f Hz\n',fband(Iband,1),fband(Iband,2));
        Ifidx = (freq>=fband(Iband,1))&(freq<=fband(Iband,2));
        Fout{Iband}=freq(Ifidx);
        Bpow{Iband}=sum(conj(H(Ifidx,:,:,:,:)).*S(Ifidx,:,:),3);  %%Sum across elements
        Bpow{Iband}=abs(Bpow{Iband}).^2;
        Bpow{Iband}=permute(Bpow{Iband},[1,5,4,2,3]); %[Nfreq Nel Nazi Nt]
        disp('Finished large matrix beamforming operation');
        toc
        %%%Create histogram of full unsorted beampatterns
        bin_width = median(diff(hist_param.el_edges));
        el_centers = hist_param.el_edges(1:end-1)+bin_width/2;
        elev_deg=squeeze(elev_deg);
        elev_hist=zeros(length(hist_param.el_edges)-1,length(fband),'single');

        B_incoh = squeeze(sum(Bpow{Iband}));

        [~,max_idx] = max(B_incoh);
        elev_est= (elev_deg(max_idx));

        elev_hist(:,Iband) = single(histcounts(elev_est,hist_param.el_edges,'Normalization','count'));
        
        disp('Finished histogram, starting time averaging')
        
        %Consolidate time bins
        time_avg=0.1; %Averaging time in seconds
        Ninc=ceil(time_avg./T(1));  %%Number of samples per beampattern.
        Nbeam_count=floor(Nt./Ninc);

        for Ibeam=1:Nbeam_count
            indexx=1+(Ibeam-1)*Ninc+(0:(Ninc-1));
            Bpow{Iband}(:,:,:,Ibeam)=sum(Bpow{Iband}(:,:,:,indexx),4);
        end
        Bpow{Iband}=Bpow{Iband}(:,:,:,1:Ibeam);
        disp('Finished time averaging')
        toc
    end %Iband
    disp('Finished beamforming processing.')
    toc
    %Bpow=(sum(Bpow,4))/Nt;%%%averages over time
    toc

    %keyboard
    % catch
else


    if Nel>1 & Naz==1
        % loop over elevation
        fprintf('BF: looping over elevation\n')
        for ii = 1:Nel
            B(:,:,:,ii) = sum(conj(H(:,:,:,:,ii)).*S,3);
            Bpow(:,:,:,ii) = squeeze(conj(B(:,:,:,ii)  ) .* B(:,:,:,ii) ) ;

        end

    elseif Naz>1 & Nel==1
        % loop over azimuth
        fprintf('BF: looping over azimuth\n')
        for ii = 1:Naz
            B(:,:,ii,:) = sum(conj(H(:,:,:,ii,:)).*S,3);

            Bpow(:,:,ii,:) = squeeze(conj(B(:,:,ii,:)  ) .* B(:,:,ii,:) ) ;

        end
    else
        %loop over time, the 5th dimension
        fprintf('BF: looping over time\n')
        for ii = 1:Nt
            if verbose
                fprintf('%i of %i\n',ii,Nt)
            end
            B(:,ii,:,:,:) = sum(conj(H(:,:,:,:,:)).*S(:,ii,:,:,:),3);

            Bpow(:,ii,:,:) = conj(B(:,ii,:,:,:) ) .* B(:,ii,:,:,:) ;

        end
    end


end %if arraysize





