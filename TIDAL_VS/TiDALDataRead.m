% This Script is for reading data off of the TiDAL.
%
clear all
close all
%%
%Define classes
InputPar=InputClass;
InputParAcCal=AcousticCalClass;
%
DigitalPar=DigitalParClass;
DigitalParAcCal=DigitalParClass;
%
AnalogPar=AnalogParClass;
InputPar.FileGeneration=FileGenEnum.New;

%%
% Analog Calibration Parameters
InputParAcCal.Cal=false;
%%
% User defined parameters
%
% DigitalData Parameters
% DigitalPar.Name='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1200\DigitalData-27SEP2023-1200.vs';  % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN1. Followed by X,Y,Z, UP, down
DigitalPar.Name='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1226\DigitalData-27SEP2023-1226.vs';  % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN2. Followed by X,Y,Z, UP, down
%
% Analog Parameters
%AnalogPar.fname='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1200\AnalogData-27SEP2023-1200.vs'; % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN1. Followed by X,Y,Z, UP, down
AnalogPar.fname='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1226\AnalogData-27SEP2023-1226.vs'; % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN2. Followed by X,Y,Z, UP, down
%%
% Change to Base directory so that file path information will work.
load('BaseFilePath.mat');
currentFolder=[currentFolder,'\']; %Add path seperator to base filename
cd(currentFolder)
%%
% Copy from server to local path
% CopyToLocal(AnalogPar.fname) %Check to see if a local copy exists.  If not, copy from server
%%
% Read in analog data
% Read Header Information
AnalogPar = AnalogHeader(AnalogPar);
% Read Data
fid=fopen(AnalogPar.fname); % Open File Reference
header_length=fread(fid,1,'uint32','b'); %Determine header length
header=fread(fid,header_length,'char*1','b'); % read Header from File
DataRaw=fread(fid,'12*uint8',1,'b'); % Read data as bytes.  Each data sample is 3, 8 bit numbers followed by a quality byte.  This code reads the all 4 numbers and then ignores the quality byte.
fclose(fid); %Close reference
%%
% Manipulate data so that it is in numerical format for computer
DataRaw=cast(DataRaw,'uint8'); %Cast data to UINT for all values.
DataShaped=reshape(DataRaw,[3,(size(DataRaw,1)/3)])';  %Reshape array so that each row is 1 sample.  Note that reshape fills columns first so need to transpose
Sample=zeros(size(DataShaped,1),1,"double");
tic
for i=1:size(DataShaped,1)
    SampleTemp=typecast(DataShaped(i,:),'uint8');
    if bitget(SampleTemp(1),8) % Check to see if bit is set, meaning it is negative
        %SampleTemp(1)=bitand(SampleTemp(1),0x7f);
        SampleTempMasked=[0xFF,SampleTemp];
        Sample(i)=double(typecast(flip(SampleTempMasked),'int32'));
    else
        SampleTempMasked=[0x00,SampleTemp];
        Sample(i)=double(typecast(flip(SampleTempMasked),'int32'));   
    end
end
toc
%%
% Take raw int values and convert them to voltage
Data=4.096*Sample/(2^23); % convert from int to voltage
MeasuredValues=reshape(Data,4,size(Data,1)/4)';  % Make an array of data X,Y,H,Z
%%
%Load and manipulate Digital Data
[DigitalDataMeas,DigitalPar]=LoadDigitalData(DigitalPar,InputPar);
%%
% Plot and display analog data results
AnalogTime=0:1/AnalogPar.AHeader.SampleRate:5*60-1/AnalogPar.AHeader.SampleRate; % Create a time vector for entire file
%
figure
title('Analog Data Zoomed')
hold on
plot(AnalogTime,MeasuredValues(:,1),'-xb')
plot(AnalogTime,MeasuredValues(:,2),'-+r')
plot(AnalogTime,MeasuredValues(:,3),'-og')
plot(AnalogTime,MeasuredValues(:,4),'-*c')
hold off
xlim([1,1.01])
ylim ([-2,2])
legend('ChX','ChY','ChH','ChZ')
xlabel('Time[s]')
ylabel('Amplitude[V]')
%
figure
title('Analog Data')
hold on
plot(AnalogTime,MeasuredValues(:,1),'-xb')
plot(AnalogTime,MeasuredValues(:,2),'-+r')
plot(AnalogTime,MeasuredValues(:,3),'-og')
plot(AnalogTime,MeasuredValues(:,4),'-*c')
hold off
legend('ChX','ChY','ChH','ChZ')
xlabel('Time[s]')
ylabel('Amplitude[V]')
%%
%Plot and display digital results

figure('Position',[50,50,1200,600]);
CalPlot = tiledlayout(2,1,'TileSpacing','Compact');
% Plot raw magnetometer values
nexttile
plot(DigitalDataMeas(:,7),'-b')
hold on;
plot(DigitalDataMeas(:,8),'-r')
plot(DigitalDataMeas(:,9),'-g')
hold off;
ylabel('Magnetic (nT)')
%ylim([-60000,-70]);
ax = gca;
ax.YAxis.Exponent = 0;
ytickformat('%,.0f')
title('Raw Magnetometer Values')
legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')
%
% Plot Values before Calibration
nexttile
plot(DigitalDataMeas(:,4),'-b')
hold on;
plot(DigitalDataMeas(:,5),'-r')
plot(DigitalDataMeas(:,6),'-g')
ylabel('Acceleration [g]')
hold off;
title('Raw Accelerometer Values')
legend('Ch. X','Ch. Y','Ch. Z','Location','eastoutside')
%ylim([ALower,AUpper]);
%
disp('Read Complete')
%%
%
%Save Wave File
% audiowrite([fileparts(AnalogPar.fname) '\ChX.wav'],MeasuredValues(:,1)/3/rms(MeasuredValues(:,1)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChY.wav'],MeasuredValues(:,2)/3/rms(MeasuredValues(:,2)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChZ.wav'],MeasuredValues(:,4)/3/rms(MeasuredValues(:,4)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChH.wav'],MeasuredValues(:,3)/3/rms(MeasuredValues(:,3)),int32(AnalogPar.AHeader.SampleRate))
