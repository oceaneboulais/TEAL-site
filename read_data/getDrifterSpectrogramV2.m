function [S,F,T,ch_select,sensor_type,pos] = getDrifterSpectrogramV2(y,nfft,noverlp,fs,config_file,type)
% nfft can be either the fft length, or a specified window to use
if  isempty(noverlp)
    noverlp = floor(nfft/2);
end
if length(nfft)==1
    win = hamming(nfft);
else
    win = nfft;
    nfft = length(nfft);
end
if ~exist('type','var')
    type = 'stft';
end
k = 0;

% get the channel configuration from the acoustic config file 
acoustic_config = readtable(config_file);

% first, do the hydrophone spectrograms
for ich = 1:size(y,2)    
    if isempty(acoustic_config.sensor_type{ich})
        continue
    end
    k = k+1;
    ch_select(k) = ich;
    [S(:,:,k),F,T] = spectrogram(y(:,ich),win,noverlp,nfft,fs);
    sensor_type(k) = string(acoustic_config.sensor_type{ich});
    S(:,:,k) = applyDrifterSensitivity(S(:,:,k),F,'mag',sensor_type(k));
end

% make sure the order of the channels is x-y, and E-W, N-S....

switch type
    case 'psd'
        winPow = win'*win;
        S = S.*conj(S)/(winPow*fs);
    case 'stft'
        % this is just S
end

if nargout>5
    pos = [acoustic_config.X_m acoustic_config.Y_m acoustic_config.Z_m];
    pos = pos(ch_select,:);
end

% [F,T,P,Vx,Vy,Vz,ch_select] = getVectorSpectrogram(y,nfft,noverlp,fs,vector_sensor);
% 
% S(:,:,k+1) = P;
% S(:,:,k+2) = Vx;
% S(:,:,k+3) = Vy;
% S(:,:,k+4) = Vz;
