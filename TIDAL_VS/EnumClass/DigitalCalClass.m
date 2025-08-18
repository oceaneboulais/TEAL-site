classdef DigitalCalClass
    %DIGITALCALCLASS Defines all values for Digital Calibration   
    properties
        Name=''; %FileName of the digital file
        Header=DHeaderClass;
        CalMethod=CalMethodsEnum.Default; %Define the calibration methods for magnetometer.
        CalAccel=CalAccelEnum.Default; %Define the acceleration calibration method.
        AccelCal; %Acceleration Calibration values
        MagCal;     %Magnetometer calibration values
        CalQual=9999;
    end
    
end

