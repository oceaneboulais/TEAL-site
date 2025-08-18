classdef AcousticCalClass < InputClass
    %Define the AcousticCal properties
    properties
        Cal=false %Set to true when a calibration is desired.
        CalFreq=0; %Calibration frequency
        Shape=[1 0 0; 0 1 0; 0 0 1];  %Scaling Shape value
        Bias=[0;0;0] %Calibration bias value
    end
    
end

