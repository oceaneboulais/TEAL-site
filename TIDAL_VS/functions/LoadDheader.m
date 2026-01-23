function [InputPar, DigitalPar]=LoadDheader(InputPar,DigitalPar)
%%
%Author: Mark Paulus
%% 
%Description
%   This function reads the header information from the analog and digital
%   files and saves them to a variable.
%%
% Inputs
%   InputPar--> Input Parameters for Analog information
%   DigitalPar--> Digital Parameters for Digital Information

% Outputs
%   InputPar--> Input Parameters for Analog information
%   DigitalPar--> Digital Parameters for Digital Information
%%
switch (InputPar.Options.BuoyType)
    case {BuoyTypeEnum.VS, BuoyTypeEnum.Default}
        DigitalPar=DigitalHeader(DigitalPar);
    case BuoyTypeEnum.Sonobuoy
        DigitalPar="dummy";
    case BuoyTypeEnum.HMV
        DigitalPar="dummy";
    otherwise
        warning('Buoy Type not chosen for loadheader:InputPar.Options.BuoyType')
end


end