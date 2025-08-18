function DigitalDataMeas=DigitalRawtoMeasured(DigitalPar,DigitalDataRaw)
%%
%Based on which sensor is desired, choose from data.  data includes values
%where is row is a interleaved reading of digital data samples.
%%
%Assign to local variables
data=DigitalDataRaw;
%%
%Load Magnetometer Data
%   Scale Heading Data Word
%   XHeading - Word 7
%   YHeading - Word 8
%   ZHeading - Word 9
HeadingScale=20; %Heading Scale value [20nT/bit]
datascaled=data; %Initialize all values to zero
datascaled(:,7:9)=cast(data(:,7:9),'double')*HeadingScale; %integer data must be cast to double to performing floating point arithmetic
%%
%Load accelerometer Data
%   Scale Heading Data Word
%   XAccel - Word 4
%   YAccel - Word 5
%   ZAccel - Word 6
AccelScale=.001; %Accelerometer Scale Value[.001G/bit]
datascaled(:,4:6)=cast(data(:,4:6),'double')*AccelScale; %integer data must be cast to double to performing floating point arithmetic
%%
%Assign Scaled data back to digital data
%
DigitalDataMeas=datascaled;
