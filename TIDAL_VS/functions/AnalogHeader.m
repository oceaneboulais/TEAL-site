function AnalogPar = AnalogHeader(AnalogPar)
%Author: Mark Paulus
%Rev. -, 10/3/2019
%Read Header on digital and analog data files
% Input Arguments
%   Input.Header
%       fname-->Name of raw data file (acoustic)
%       Version --> File Format Version
% Outputs
%   AHeader--> Analog Header Data from file
%%
%Debug Values
% clear all;
% close all;
% InputPar.fname='AnalogData-25Sep2019-1025.vs'; % File stored in Input data.  Need to add to path for this to work.
% InputPar.Header.Version=3;


%%
% Read header into cell
HeaderCellArray=ReadHeader(AnalogPar.fname); %Raw Header from file
%%
%Find Software Revision
AnalogPar.AHeader.Version=str2double(FieldFind(HeaderCellArray,"File Format Rev"));
%%
if AnalogPar.AHeader.Version==1 
    %Assign Values to Structure
    AnalogPar.AHeader.All=HeaderCellArray;
    AnalogPar.AHeader.TestName=HeaderCellArray{1,2};
    AnalogPar.AHeader.SampleRate=str2double(HeaderCellArray{5,2});
    AnalogPar.AHeader.VS1.HChanSense=str2double(HeaderCellArray{10,2});
    AnalogPar.AHeader.VS2.HChanSense=0;
    AnalogPar.AHeader.CurrentTime=datetime(HeaderCellArray{14,2},'Format', 'MMMM d, yyyy -- HH:mm:ss');
    AnalogPar.AHeader.NumSensors=1;
    
 elseif   AnalogPar.AHeader.Version==3 
    %Assign Values to Structure
    AnalogPar.AHeader.All=HeaderCellArray;
    AnalogPar.AHeader.TestName=HeaderCellArray{1,2};
    AnalogPar.AHeader.SampleRate=str2double(HeaderCellArray{5,2});
    AnalogPar.AHeader.VS1.HChanSense=str2double(HeaderCellArray{10,2});
    AnalogPar.AHeader.VS2.HChanSense=str2double(HeaderCellArray{21,2});
    AnalogPar.AHeader.CurrentTime=datetime(HeaderCellArray{25,2},'Format', 'MMMM d, yyyy -- HH:mm:ss');
    AnalogPar.AHeader.NumSensors=2;
elseif AnalogPar.AHeader.Version==4
    %Assign Values to Structure
    AnalogPar.AHeader.All=HeaderCellArray;
    AnalogPar.AHeader.TestName=FieldFind(HeaderCellArray,"Test Name");
    AnalogPar.AHeader.NumSensors=str2double(FieldFind(HeaderCellArray,"Number of Sensors"));
    AnalogPar.AHeader.AcqSoftVer=str2double(FieldFind(HeaderCellArray,"Acq Software Revision"));
    AnalogPar.AHeader.SampleRate=str2double(FieldFind(HeaderCellArray,"Sample Rate"));
    AnalogPar.AHeader.InputCoupling=(FieldFind(HeaderCellArray,"Input Coupling"));
    AnalogPar.AHeader.CurrentTime=datetime(FieldFind(HeaderCellArray,"Current Time"),'Format', 'MMMM d, yyyy -- HH:mm:ss');
    AnalogPar.AHeader.PrevFileName=FieldFind(HeaderCellArray,"Previous Filename");
    AnalogPar.AHeader.CurrentFileName=FieldFind(HeaderCellArray,"Current Filename");
    AnalogPar.AHeader.NextFileName=FieldFind(HeaderCellArray,"Next Filename");
    %%
    %Load Ch. 1
    AnalogPar.AHeader.VS1.ModelNum=(FieldFind(HeaderCellArray,"VS 1 Model Number"));
    AnalogPar.AHeader.VS1.SN=(FieldFind(HeaderCellArray,"VS 1 Serial Number"));
    %
    AnalogPar.AHeader.VS1.XChanSense=str2double(FieldFind(HeaderCellArray,"VS 1 X Channel Sensitivity"));
    AnalogPar.AHeader.VS1.YChanSense=str2double(FieldFind(HeaderCellArray,"VS 1 Y Channel Sensitivity"));
    AnalogPar.AHeader.VS1.HChanSense=str2double(FieldFind(HeaderCellArray,"VS 1 H Channel Sensitivity"));
    AnalogPar.AHeader.VS1.ZChanSense=str2double(FieldFind(HeaderCellArray,"VS 1 Z Channel Sensitivity"));
    %
    AnalogPar.AHeader.VS1.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,1)"));
    AnalogPar.AHeader.VS1.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,2)"));
    AnalogPar.AHeader.VS1.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,3)"));
    AnalogPar.AHeader.VS1.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,1)"));
    AnalogPar.AHeader.VS1.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,2)"));
    AnalogPar.AHeader.VS1.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,3)"));
    AnalogPar.AHeader.VS1.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,1)"));
    AnalogPar.AHeader.VS1.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,2)"));
    AnalogPar.AHeader.VS1.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,3)"));
    
    %
    AnalogPar.AHeader.VS1.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (1)"));
    AnalogPar.AHeader.VS1.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (2)"));
    AnalogPar.AHeader.VS1.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (3)"));
    %%
    %Load Ch. 2
    AnalogPar.AHeader.VS2.ModelNum=(FieldFind(HeaderCellArray,"VS 2 Model Number"));
    AnalogPar.AHeader.VS2.SN=(FieldFind(HeaderCellArray,"VS 2 Serial Number"));
    %
    AnalogPar.AHeader.VS2.XChanSense=str2double(FieldFind(HeaderCellArray,"VS 2 X Channel Sensitivity"));
    AnalogPar.AHeader.VS2.YChanSense=str2double(FieldFind(HeaderCellArray,"VS 2 Y Channel Sensitivity"));
    AnalogPar.AHeader.VS2.HChanSense=str2double(FieldFind(HeaderCellArray,"VS 2 H Channel Sensitivity"));
    AnalogPar.AHeader.VS2.ZChanSense=str2double(FieldFind(HeaderCellArray,"VS 2 Z Channel Sensitivity"));
    %
    AnalogPar.AHeader.VS2.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,1)"));
    AnalogPar.AHeader.VS2.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,2)"));
    AnalogPar.AHeader.VS2.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,3)"));
    AnalogPar.AHeader.VS2.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,1)"));
    AnalogPar.AHeader.VS2.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,2)"));
    AnalogPar.AHeader.VS2.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,3)"));
    AnalogPar.AHeader.VS2.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,1)"));
    AnalogPar.AHeader.VS2.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,2)"));
    AnalogPar.AHeader.VS2.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,3)"));
    
    %
    AnalogPar.AHeader.VS2.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (1)"));
    AnalogPar.AHeader.VS2.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (2)"));
    AnalogPar.AHeader.VS2.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (3)"));    
elseif AnalogPar.AHeader.Version==5
    %Assign Values to Structure
    AnalogPar.AHeader.All=HeaderCellArray;
    AnalogPar.AHeader.TestName=FieldFind(HeaderCellArray,"Test Name");
    AnalogPar.AHeader.AcqSoftVer=str2double(FieldFind(HeaderCellArray,"Acq Software Revision"));
    AnalogPar.AHeader.SampleRate=str2double(FieldFind(HeaderCellArray,"Data Sample Rate"));
    AnalogPar.AHeader.CurrentTime=datetime(FieldFind(HeaderCellArray,"Current Time"),'Format', 'MMMM d, yyyy -- HH:mm:ss');
    AnalogPar.AHeader.PrevFileName=FieldFind(HeaderCellArray,"Previous Filename");
    AnalogPar.AHeader.CurrentFileName=FieldFind(HeaderCellArray,"Current Filename");
    AnalogPar.AHeader.NextFileName=FieldFind(HeaderCellArray,"Next Filename");
    %
    AnalogPar.AHeader.VS.ModelNum=(FieldFind(HeaderCellArray,"VS Model Number"));
    AnalogPar.AHeader.VS.SN=(FieldFind(HeaderCellArray,"VS Serial Number"));
    %
    AnalogPar.AHeader.VS.XChanSense=str2double(FieldFind(HeaderCellArray,"VS X Channel Sensitivity"));
    AnalogPar.AHeader.VS.YChanSense=str2double(FieldFind(HeaderCellArray,"VS Y Channel Sensitivity"));
    AnalogPar.AHeader.VS.HChanSense=str2double(FieldFind(HeaderCellArray,"VS H Channel Sensitivity"));
    AnalogPar.AHeader.VS.ZChanSense=str2double(FieldFind(HeaderCellArray,"VS Z Channel Sensitivity"));
    %
    AnalogPar.AHeader.VS.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,1)"));
    AnalogPar.AHeader.VS.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,2)"));
    AnalogPar.AHeader.VS.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,3)"));
    AnalogPar.AHeader.VS.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,1)"));
    AnalogPar.AHeader.VS.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,2)"));
    AnalogPar.AHeader.VS.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,3)"));
    AnalogPar.AHeader.VS.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,1)"));
    AnalogPar.AHeader.VS.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,2)"));
    AnalogPar.AHeader.VS.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,3)"));
    
    %
    AnalogPar.AHeader.VS.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS Bias (1)"));
    AnalogPar.AHeader.VS.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS Bias (2)"));
    AnalogPar.AHeader.VS.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS Bias (3)"));    

else
    Display("Error in AnalogHeader")
end
%%
AnalogPar.AHeader.CurrentTime.TimeZone='America/Los_Angeles'; %Assign Time Zone
end

%end


