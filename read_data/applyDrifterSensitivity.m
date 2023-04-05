function S = applyDrifterSensitivity(S,F,type,sensor)
% INPUTS:
%   S:      short time fourier transform or PSD
%           (can either be Nfreq x 1 but must also specify 'sensor', or Nfreq x 16
%           and it is assumed that ch 1-8 are hydrophones, 9 omni, 11-12
%           directional
%   F:      frequency in Hz
%   type:   'pow' or 'mag'
%   sensor: if using 1 channel, specify which sensor it is ('HTI-92WB', 
%           'GTI-M35-300-omni', or 'GTI-M35-300-directional'

Nch = size(S,3);

if Nch==16
    hydro_sens = getSensitivity(F,'HTI-92WB');
    omni_sens = getSensitivity(F,'GTI-M35-300-omni');
    directional_sens = getSensitivity(F,'GTI-M35-300-directional');
    sens_dB = [hydro_sens(:).*ones(1,8) omni_sens(:) directional_sens(:).*ones(1,2) zeros(length(F),5)];
elseif Nch==1
    sens_dB = getSensitivity(F,sensor);
end

switch type
    case 'mag'
        S = S.* (10.^(-sens_dB(:)/20));
    case 'pow'
        S = S.* (10.^(-sens_dB(:)/10));
end
