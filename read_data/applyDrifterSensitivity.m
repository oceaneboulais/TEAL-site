function Sout = applyDrifterSensitivity(S,F,type,sensor)
% apply drifter sensitivity to data spectrogram
% assume spectrogram produced from data sample read using audioread with range +/-1
% INPUTS:
%   S:      short time fourier transform or PSD
%           (can either be Nfreq x 1 but must also specify 'sensor', or Nfreq x 16
%           and the acoustic config must be provided 
%           directional
%   F:      frequency in Hz
%   type:   'pow' or 'mag' for STFT/spectrogram, 'fft' for multi channel fft
%   sensor: if using 1 channel, specify which sensor it is ('HTI-92WB', 
%           'GTI-M35-300-omni', or 'GTI-M35-300-directional'
%           if using 16 channels, this must point to the acoustic config
%           file

switch type
    case {'mag','pow'}
        if ndims(S)==3
            % this is a spectrogram
            Nch = size(S,3);
        else
            Nch = 1;
        end
        L=0;
    case {'fft'}
        [K,L] = size(S);
        if K==length(F)
            Nch = L;
        elseif L==length(F)
            Nch = K;
            S = S.';
        else
            error('Dimensions inconsistent!')
        end
end

nbits = 24; % drifter daq is 24 bits
volts = 5; % drifter daq is +/- 5V

if Nch >1
    acoustic_config = readtable(sensor);
    % first, do the hydrophone spectrograms
    k = 0;
    for ich = 1:size(S,2)    
        if isempty(acoustic_config.sensor_type{ich})
            continue
        end
        k = k+1;
        ch_select(k) = ich;
        sensor_type(k) = string(acoustic_config.sensor_type{ich});
        switch type
            case {'mag','pow'}
                Sout(:,:,k) = applyDrifterSensitivity(S(:,:,ich),F,type,sensor_type(k));
            case 'fft'
                Sout(:,k) = applyDrifterSensitivity(S(:,ich),F,type,sensor_type(k));
        end
    end
else
%     [sens_dB,sens_phase_deg] = getSensitivity(F,sensor);
    H = getSensitivity(F,sensor,'nbits',24);
    H = H*(2^(nbits-1)); % sensitivity given in uPa/count, data read +/-1 from audioread

    switch type
        case {'mag','fft'}
    %         S = S.* (10.^(-sens_dB(:)/20)).*exp(1i*sens_phase_deg(:)*pi/180);
              Sout = S.*H.';
        case 'pow'
            Sout = S.* (10.^(-sens_dB(:)/10));
    end
end

if L==length(F)
    % we transposed it, so transpose it back
    Sout = Sout.';
end
