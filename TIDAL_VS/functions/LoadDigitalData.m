function [DigitalDataMeas,DigitalPar]=LoadDigitalData(DigitalPar,InputPar)
%%
%Author: Mark Paulus
%Rev. 5, 02/28/2020
%Changes for Rev. 5-->
%   -Only rotate magnetomters for SN 169 based on bench testing.
% Changes for Rev. 4-->
%   -Added Accelerometer Calibration values to function
% Changes for Rev. 3-->
%   -
%
% Changes for Rev. 2-->
%   -Changed data scaled such that each value was scaled from the previous
%   value
%   -Indexes for digital data were incorrect
%   -Updated scaling to include accelerometers
%
%LoadDigitalData
%   This function loads the digitaldata file and performs the necessary
%   conversions
% Inputs
%   DigitalName--> Name of the digital file
%   MagCal--> Magnetometer Calibration
%   MagRadCal --> Magnetometer Calibration for Radius (amplitude)
%   NumSensors --> Number of Sensors saved in file
%   SensorNum --> Sensor to be used (1 or 2).  Pick 1 if only 1 sensor is
%   available.

% Outputs
%   DigitalData --> Scaled Digital Data
%%
% % Test Data for troubleshooting
% DigitalName='C:\Users\PaulusME\Documents\Research\Hybrid Mobile Vehicle\Data Acquisition\MarkPaulusMatlabToolbox\VS Data AcquisitionRev8\Input Data\DigitalData-15Aug2018-1248.vs';
% 
% MagCal=[3.3802e4,-.5510e4,-2.4034e4];% [X,Y,Z] correction
%%
%Check for a local copy of the file.  Download if not available
CopyToLocal(DigitalPar.Name)
%%
%Load Digital Header
[InputPar, DigitalPar]=LoadDheader(InputPar,DigitalPar);
%%
%Read Digital File
%Read Attitude Information
DigitalDataRaw=ReadRawDigitalData(DigitalPar);
DigitalDataMeas=DigitalRawtoMeasured(DigitalPar,DigitalDataRaw);
end
