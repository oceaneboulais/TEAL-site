function [MeasuredValues,DigitalDataMeas,Fs] = readTIDALData(filename)
% [MeasuredValues,DigitalDataMeas, Fs] = readTIDALData(filename)
% this function reads in the analog TIDAL data given by filename and the
% associated digital data and returns the following
%   MeasuredValues : matrix of analog data for channels X, Y, H, and Z
%   DigitalDataMeas: magnetometer and accelerometer data 
%       accelerometer: 4-X, 5-Y, 6-Z
%       magnetometer: 7-X, 8-Y, 9-Z


% function based of the matlab script master_TiDALDataRead.m 
% A. Laferriere 2025

%Define classes
InputPar=InputClass;
InputParAcCal=AcousticCalClass;
%
DigitalPar=DigitalParClass;
DigitalParAcCal=DigitalParClass;
%
AnalogPar=AnalogParClass;
InputPar.FileGeneration=FileGenEnum.New;

% Analog Calibration Parameters
InputParAcCal.Cal=false;

disp(filename)


AnalogPar.fname= filename;
filename_base = erase(filename,'AnalogData');
[filepath,name,ext] = fileparts(filename_base);
DigitalPar.Name=fullfile(filepath,['DigitalData' name ext]);


% read header info
AnalogPar = AnalogHeader(AnalogPar);
% Read Data
fid=fopen(AnalogPar.fname); % Open File Reference
header_length=fread(fid,1,'uint32','b'); %Determine header length
header=fread(fid,header_length,'char*1','b'); % read Header from File
% disp('Header info imported.');

% disp('Reading raw data...');
DataRaw=fread(fid,'12*uint8',1,'b'); % Read data as bytes.  Each data sample is 3, 8 bit numbers followed by a quality byte.  This code reads the all 4 numbers and then ignores the quality byte.
fclose(fid); %Close reference
% disp('Raw data read complete.');


 % Manipulate data so that it is in numerical format for computer
DataRaw=cast(DataRaw,'uint8'); %Cast data to UINT for all values.
DataShaped=reshape(DataRaw,[3,(size(DataRaw,1)/3)])';  %Reshape array so that each row is 1 sample.  Note that reshape fills columns first so need to transpose
clear SampleTemp Sample MeasuredValues

for Ichan=1:3
    SampleTemp(:,1+Ichan)=typecast(DataShaped(:,Ichan),'uint8');
end
SampleTemp(:,1)=0x00;
Ineg=find(bitget(SampleTemp(:,2),8));
SampleTemp(Ineg,1)=0xFF;

SampleTemp=fliplr(SampleTemp);
SampleTemp=SampleTemp';
SampleTemp=SampleTemp(:);
Sample=double(typecast(SampleTemp,'int32'));
Data=4.096*Sample/(2^23); % convert from int to voltage
MeasuredValues=reshape(Data,4,size(Data,1)/4)';  % Make an array of data X,Y,H,Z
MeasuredValues=MeasuredValues(:,[3 1 2 4]);
Fs=AnalogPar.AHeader.SampleRate;
% AnalogTime=0:1/Fs:5*60-1/Fs; % Create a time vector for entire file


%Load Digital Data
[DigitalDataMeas,DigitalPar]=LoadDigitalData(DigitalPar,InputPar);
