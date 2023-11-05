%
% hamilton_jim.m
%
% function [vp,sedrho,kp,sedth,vbase,rhobase,kbase,zbase,mzphi] = hamilton_jim(ssz,Cp,sedth,base,tt)
%
% written by Katherine Kim (MPL - SIO)
%
% Modified by Kevin Heaney
% January 29, 2003
%
% Modified even more by James Murray (OASIS, Inc)
% October, 2012
%
%
% Algorithm Description:
%
% A Matlab script to use Edwin Hamilton's and Richard Bachman's empirical formula to convert sediment
% grainsize (PHI == log2(mm)) to geo-acoustic properties of the sediment
% (cp(sed), rho(sed), atten(sed))
%
% History: Bachman (NRaD) used these formulas during the SWellEx Experiments (NRaD and MPL Joint
% shallow water acoustic experiments off the coast of San Diego in the 90s).  Martin Olivera and
% James Murray of the Marine Physical Laboratory created Unix executables and scripts to easily
% convert sediment grainsize to geoacoustic values (1994).  Katherine Kim (MPL) cleaned up the
% FORTRAN code and re-wrote it as a Matlab script (2000).  Kevin Heaney modified the code
% further (2003).  James Murray contiued the tradition of cleaning up and modifying it (2012).
%
% Output Variables:
%
%  vp		: Sediment Compressional Sound Speed; real vector; [m/s]
%  sedrho	: Sediment density; real vector; [g/cc]
%  kp		: Sediment Attenuation; real vector; [dB/Wavelength]
%  sedth	: Sediment Thickness; real; [m]
%
% Input Parameters:
%
%     ssz	:  water sound speed at the interface; real;  [m/s]
%     mzphi 	:  mean sediment grain size [phi units = log2 mm]; real;
%     sedth 	:  sediment thickness; real; [m]    if sedth = 0 then use tt and compute sedth
%
%
% Internal Variables:
%
% zmax		: Maximum Sediment Depth, real; [m]
% zsponge	: Depth of Sediment Sponge, real; [m]
% iz		: Depth index; integer
% ssr		: Sound Sped ratio; real
% vp0		: Sediment Compressional Speed at surface
% sedrho0	: Initial Sedimetn Density; real; [g/cc]
% nsed		: Index of sediment thickness; integer
% ttmp		: Temporary Variable - travel time
% phi_face	: Temporary Ratio between two types of sediments; real
% a_vp		: Temporary Sediment Speed for Integral; real vector; [m/s]
% kp0		: Initial Attenuation; real vector; [dB/Wavelength]
%
%
%
%
% function [vp,sedrho,kp,sedth,mzphi,zout] = hamilton_jim(ssz,phi,sedth)
%
%
function [vp,sedrho,kp,sedth,mzphi,zout] = hamilton_jim(ssz,mzphi,sedth)
%
%
%


zmax = 800;
zsponge = 200;

% currently set 0 as the sediment water interface
iz = 1;

% Calculate the sound speed ratio of the bottom of the water and
% the top of the sediment.
ssr = 1.180 - 0.034 * mzphi + 0.0013 * mzphi^2;
%fprintf(stderr,"Sound Speed Ratio = %f\n",ssr);

if(0)
    disp(['Sound Speed Ratio = ',num2str(ssr)]);
end
% Calculate the sound speed of the top of the sediment.
vp0 = ssr * ssz;

% Calculate the density at the top of the sediment layer.
sedrho0 = (22.85 - mzphi) / 10.275;

% Calculate the geoacoustic parameters in a manner consistent with
% the mean grain size.

%------------------------------
% CASE A: Sands (mzphi <= 3.25)
%------------------------------
if (mzphi <= 3.25)
    
    % First, calculate the theoretical sound speed profile for the
    % sediment.  We don't know how thick the sediment is, but a sound
    % speed profile for a huge sediment thickness will help us use a
    % brute force method to get the thickness.
    %
    if (sedth == 0);
        nsed = 1000;
    else
        zout = [0:0.25:sedth];
        nsed = length(zout);
        tt = 10000;
    end;
    %
    vp(1) = vp0;
    ttmp = 0;
    for j = 2:nsed;
        vp(j) = (vp0/0.95605868) * zout(j)^(0.015);
        ttmp = 2.00 / (vp(j-1) + vp(j)) + ttmp;
        if (ttmp >= tt/2000)
            nsedth = j;
            sedth = zout(nsedth - 1);                       % Sediment thickness
            vp = vp(1:nsedth);
            
            nsed = nsedth; % MG 7/30/2019; added to prevent error
            
            break;
        end
    end
    
    % Second, calculate the sediment density profile.
    sedrho(1) = sedrho0;
    for j = 2:nsed
        sedrho(j) = sedrho0;
    end
    
    % Third, calculate the sediment attenuation at the upper interface.
    if (mzphi < 2.5)
        kp0 = 0.23 + 0.0268 * mzphi;
    elseif ((mzphi >= 2.5) & (mzphi < 4.12))
        kp0 = -0.1516607 + 0.1794643 * mzphi;
    end
    
    % Fourth, calculate the sediment attenuation profile.
    kp(1) = kp0 * vp0 / 1000;
    for j = 2:nsed
        kp(j) = (kp0 / 1.647549) * zout(j)^(-0.1667);
        kp(j) = kp(j) * vp(j) / 1000;             % Convert units to dB/lambda
    end
    
    %-----------------------------------------------------------------
    % CASE B: Mixture of Sand and Silt/Clay (3.25 < mzphi < 5.75)
    %         (We'll calculate the weighed average of the parameters
    %         calculated for the sand and the silt/clay cases -- cases
    %\tab\tab    A above and C below.)
    %-----------------------------------------------------------------
elseif ((mzphi < 5.75) & (mzphi > 3.25))
    
    % First, calculate the parameter phi_fact to weigh the values of
    % compressional wave speed, density, and attenuation.  It provides
    % a "degree of siltyness".
    phi_fact = (mzphi - 3.25) / (5.75 - 3.25);
    
    % Second, calculate a theoretical sound speed profile for the sediment.
    a_vp(1) = vp0;        % For Case A (sand), it is...
    ttmp = 0;
    %
    %
    zout = [0:0.25:1000*0.25];
    for j = 1:1000;
        a_vp(j+1) = (vp0/0.95605868) * zout(j+1) ^(0.015);
    end
    
    c_vp(1) = vp0;         % For Case C (silt/clay) it is...
    ttmp = 0;
    for j = 1:1000;
        c_vp(j+1) = vp0 + 0.712 * zout(j+1);
    end
    
    vp(1) = vp0;
    
    
    % So now for Case B, it is...
    if (sedth == 0);
        nsed = 1000;
    else
        zout = [0:0.25:sedth];
        nsed = length(zout);
        tt = 10000;
    end;
    %
    for m = 1:length(zout)-1
        vp(m+1) = c_vp(m+1)*phi_fact+a_vp(m+1)*(1-phi_fact);
        ttmp = 2.00 / (vp(m+1) + vp(m)) + ttmp;
        if (ttmp >= tt/2000)
            nsed = m-1;      % Sediment thickness.
            sedth = zout(nsedth);
            break;
        end
    end
    
    % Third, calculate the sediment density profile.
    a_sedrho(1) = sedrho0;      % For Case A (sand), it is...
    for j = 1:nsed
        a_sedrho(j+1) = sedrho0;
    end
    
    c_sedrho(1) = sedrho0;      % For Case C (silt/clay) it is...
    for j = 1:nsed
        c_sedrho(j+1) = sedrho0+1.395e-03*zout(j)-6.17e-07*zout(j)^2;
    end
    
    for m = 1:nsed        % So now for Case B, it is...
        sedrho(m) = c_sedrho(m)*phi_fact+a_sedrho(m)*(1-phi_fact);
    end
    
    % Fourth, calculate the sediment attenuation at the upper interface.
    if ((mzphi >= 2.5) & (mzphi < 4.12))
        kp0 = -0.1516607 + 0.1794643 * mzphi;
    elseif ((mzphi >= 4.12) & (mzphi < 4.82))
        kp0 = 2.556396 - 0.4778311 * mzphi;
    elseif ((mzphi >= 4.82) & (mzphi < 5.35))
        kp0 = 1.206895 - 0.1978517 * mzphi;
    elseif ((mzphi >= 5.35) & (mzphi < 6.00))
        kp0 = 0.6295269 - 8.993236e-02 * mzphi;
    end
    
    % Fifth, calculate the sediment attentuation profile.
    kp(1) = kp0 * vp0 / 1000;
    for j = 2:nsed
        sandtmp = (kp0 / 1.6475) * zout(j)^(-1/6);
        silttmp = kp0+9.088e-5*zout(j)-2.285e-7*zout(j)^2+1.336e-10*zout(j)^3;
        kp(j) = silttmp*phi_fact+sandtmp*(1-phi_fact);
        kp(j) = kp(j) * vp(j) / 1000;       % Convert to dB/lambda
    end
    
    %----------------------------------
    % CASE C: Silt/Clay (mzphi >= 5.75)
    %----------------------------------
elseif (mzphi >= 5.75)
    
    % First, calculate the theoretical sound speed profile for the
    % sediment.  We don't know how thick the sediment is, but a sound
    % speed profile for a huge sediment thickness will help us use a
    % brute force method to get the thickness.
    if (sedth == 0);
        nsed = 1000;
    else
        zout = [0:0.25:sedth];
        nsed = length(zout);
        tt = 10000;
    end;
    %
    vp(1) = vp0;
    ttmp = 0;
    for j = 2:length(zout)
        vp(j) = vp0 + 0.712 * zout(j);
        ttmp = 2.00 / (vp(j-1) + vp(j)) + ttmp;
        if (ttmp >= tt/2000)
            nsedth = j-1;
            vp = vp(1:nsedth);
            break;
        end
    end
    
    % Second, calculate the sediment density profile.
    sedrho(1) = sedrho0;
    for j = 2:nsed
        sedrho(j) = sedrho0 + 1.395e-03 * zout(j) - 6.17e-07 * zout(j)^2;
    end
    
    % Third, calculate the sediment attenuation at the upper interface.
    if ((mzphi >= 5.35) & (mzphi < 6.00))
        kp0 = 0.6295269 - 8.993236e-02 * mzphi;
    elseif ((mzphi >= 6.00) & (mzphi < 7.10))
        kp0 = 0.2974684 - 3.458935e-02 * mzphi;
    elseif (mzphi >= 7.10)
        kp0 = 0.1299449 - 1.099449e-02 * mzphi;
    end
    
    % Fourth, calculate the sediment attenuation profile.
    kp(1) = kp0 * vp0 / 1000;
    for j = 2:nsed
        kp(j) = kp0+9.088e-5*zout(j)-2.285e-7*zout(j)^2+1.336e-10*zout(j)^3;
        kp(j) = kp(j) * vp(j) / 1000;       % Convert units to dB/lambda
    end
    
    % Here's the end of the three big "ifs" corresponding to the calculation
    % of geoacoustic propertoes.  The "ifs" branch out depending on the value
    % of mzphi.
end

