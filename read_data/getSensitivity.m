function H = getSensitivity(f,sensor)
% applies the tabulated sensitivity for the chosen sensor
% INPUTS:
%   f:      desired frequencies in Hz
%   sensor: desired sensor ('GTI-M35-300-omni', 'GTI-M35-300-directional',
%               or 'HTI-92WB'
% OUTPUTS:
%   H:      sensivity values for in dB at frequencies f

% Alison B. Laferriere

Vmax=5;  %Assumed peak-to peak range of the ADC

switch sensor
    case 'GTI-M35-300-directional'
        ftab =  [100 4e3 7e3 10e3 12e3 20e3];
        htab = [-192 -160 -156 -155 -155.5 -160];
        phitab = -90*ones(size(htab));
    case 'GTI-M35-300-omni'
%         ftab =  [100  3e3  3.9e3 5e3   6e3  9e3  10e3 12e3 20e3 200e3];
%         htab = [-163 -164 -163   -165.5 -165 -164 -165 -163 -164 -164];
        ftab =  [100 2e3 3e3 20e3];
        htab = [-163 -163 -164 -164];
        phitab = 0*ones(size(htab));
    case 'HTI-92WB'
        ftab = [100 50e3];
        htab = [-145 -145];
        phitab = 0*ones(size(htab));
    case 'VS-209-omni'
        ftab =  [1e3 4e3 7e3 8e3 10e3 20e3];
        htab = [-162 -163 -164 -165 -165 -165];
        phitab = 0*ones(size(htab));
    case 'VS-209-directional'
        ftab =  [1e3 4.5e3 10e3 20e3];
        htab = [-185 -171 -160 -160];
        %phitab = [-90 -90 -160 -160];
        phitab = -90*ones(size(htab));
end
if any(f==0)
    fidx = f>=100;
    HdB(fidx) = interp1(log10(ftab),htab,log10(f(fidx)),'linear','extrap');
    HdB(~fidx) = htab(1);
    
    phi_deg(fidx) = interp1(log10(ftab),phitab,log10(f(fidx)),'linear','extrap');
    phi_deg(~fidx) = phi_deg(1);
else
    HdB = interp1(log10(ftab),htab,log10(f));
    phi_deg = interp1(log10(ftab),phitab,log10(f));
end

 H =  (10.^(-HdB/20)).*exp(1i*phi_deg*pi/180);  %%%Units of uPa/V
 
 H=  (Vmax./(2^32))*H;  %%Units of uPa/(count);
 