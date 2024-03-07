function [Bpow,Fout,Tout,elev_hist] = beamform_from_spec_avg(S,T,freq,az_deg,elev_deg,pos,w,fband_in,time_avg,hist_param)
% conventional beamformer in FFT domain:
%
% INPUTS:
%       S:    complex spectrogram [freq time element]
%       T:     time in seconds
%       freq:     frequencies in Hz
%       pos   position of sensors
%       az_deg   (vector) angle from x-axis to y-axis in array coordinates
%       elev_deg     (vector)   elevation in degrees up from the horizontal
%       fband_in: Frequencies in Hz to incoherently sum beamformer over.
%              If array: First column is start freq, second column is end freq.
%               Each row is a different bandwidth that produces a new cell
%               in Bpow and Fout.
%              If scalar: divide frequencies up into bands of this size for
%               calculation, then recombine on output
%       time_avg: time in second over which beams are incoherently
%           averaged.
%       hist_param: (optional) parameters for creating histograms of peak direction
%           from instantaneous beamformer. if empty or omited, histogram
%           processing is skipped.
%
% OUTPUTS:
%       Bpow{freq_band}(freq,time,azimuth,elevation): cell array of linear
%        beamformed output, with each cell corresponding to one frequency
%           band in fband. If fband_in is a scalar, the result is
%           concatenated into a single array.
%       Fout{freq_band}:  Frequencies in Hz that correspond to elements in
%                   first dimension of Bpow. If fband_in is a scalar, Fout
%                   is concatenated into a single vector
%       Tout:   time-averaged time ouptuts.            
%       elev_hist(elevations, freq_band): matrix whose columns  are
%           histograms of elevation angles taken from individual beampatterns
%           before time averaging. Each column corresponds to a different
%           frequency band.
%

c = 1500;

Nt = size(S,2);
Nf = length(freq);
Nch = size(pos,1);
Naz = length(az_deg);
Nel = length(elev_deg);

if ~exist('hist_param','var')
    hist_param = [];
end

if ~exist('w','var')||isempty(w)
    w(1,1,:) = ones(Nch,1)/Nch;
else
    w(1,1,:) = w(:);
end
if ~exist('time_avg','var')
    time_avg = [];
end

% Put all quantities in the following dimensions
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
%array_size_GB = 2*num_elements*8/1024^3;
%B = zeros(Nf,Nt,Naz,Nel);

%%%Note: we save a lot of RAM memory by conducting matrix operations
% independently for each frequency band.  We get rid of B variable,
%   and average by reusing memory in original Bpow.
% Time-averaging saves a lot of disk space:  even averaging over 0.1
% sec reduced memory by a factor of 20.

fprintf('BF: vectorized direct multiplication\n')
% first see if we can do it all at once
% H is dimension [Nfreq 1 Nchan Nazi Nelv]
% S is dimension [Nfreq Ntime Nchan]
%  element-by element multiplication is replicated across all azimuths
%  and elevation angles.

if isscalar(fband_in)
    df = min(diff(freq));
    fband1 = freq(1):fband_in:(freq(end)-fband_in);
    fband2 = [(fband1(2)-df):fband_in:fband1(end) freq(end)];
    fband = [fband1(:) fband2(:)];
else
    fband = fband_in;
end

disp('Start beamforming over bands...')
if ~isempty(hist_param)
    elev_hist=zeros(length(hist_param.el_edges)-1,length(fband),'single');
end


for Iband = 1:size(fband,1)  %For each frequency band
    fprintf('Beamforming from %3.2f to %3.2f Hz\n',fband(Iband,1),fband(Iband,2));
    Ifidx = (freq>=fband(Iband,1))&(freq<=fband(Iband,2));
    Fout{Iband}=freq(Ifidx);
    Bpow{Iband}=sum(conj(H(Ifidx,:,:,:,:)).*S(Ifidx,:,:),3);  %%Sum across elements.

    Bpow{Iband}=abs(Bpow{Iband}).^2; %[Nfreq Nt 1 Naz Nel]
    Bpow{Iband}=permute(Bpow{Iband},[1,2,4,5,3]); %[Nfreq Nt Naz Nel]
    disp('Finished large matrix beamforming operation.');
    toc

    if ~isempty(hist_param)
        disp('Starting histogram...')
        %%%Create histogram from  unaveraged beampatterns
        bin_width = median(diff(hist_param.el_edges));
        el_centers = hist_param.el_edges(1:end-1)+bin_width/2;
        elev_deg=squeeze(elev_deg);
    
        B_incoh = squeeze(sum(Bpow{Iband}));
    
        [~,max_idx] = max(B_incoh);
        elev_est= (elev_deg(max_idx));
    
        elev_hist(:,Iband) = single(histcounts(elev_est,hist_param.el_edges,'Normalization','count'));
    
        disp('Finished histogram.')
    end
    

    %Consolidate time bins
    if ~isempty(time_avg)
        disp('Starting time averaging...')
        Ninc=ceil(time_avg./T(1));  %%Number of samples per beampattern.
        Nbeam_count=floor(Nt./Ninc);
        Itindex=Ninc:Ninc:Nt;
        Itindex=Itindex-round(Ninc/2);
        for Ibeam=1:Nbeam_count
            indexx=1+(Ibeam-1)*Ninc+(0:(Ninc-1));
            Bpow{Iband}(:,Ibeam,:,:)=sum(Bpow{Iband}(:,indexx,:,:),2);
        end
        Bpow{Iband}=Bpow{Iband}(:,1:Ibeam,:,:);
        disp('Finished time averaging.')
    else
        Itindex = 1:length(T);
    end
        toc
end %Iband
Tout = T(Itindex);
if isscalar(fband_in)
% now consolidate by concatenating over the first dim
    Bpow = vertcat(Bpow{:});
    Fout = vertcat(Fout{:});
end
disp('Finished beamform_from_spec_avg.')
toc







