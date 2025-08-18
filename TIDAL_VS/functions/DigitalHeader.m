function DigitalPar = DigitalHeader(DigitalPar)
%Author: Mark Paulus
%Rev. -, 10/3/2019
%Read Header on digital and analog data files
% Input Arguments
%   Input.Header
%       fname-->Name of raw data file (acoustic)
%       Version --> File Format Version
% Outputs
%   DHeader--> Header Data from file
%%
%Debug Values
% clear all;
% close all;
% 
% InputPar.fname='DigitalData-25Sep2019-1025.vs'; % File stored in Input data.  Need to add to path for this to work.
% InputPar.FileVersion=3;

%%
%Read Header Data
HeaderCellArray=ReadHeader(DigitalPar.Name); %Raw Header from file
%%
%Find File Format Revision
DigitalPar.Header.Version=str2double(FieldFind(HeaderCellArray,"File Format Rev"));  
%%
% Assign to Structure
if DigitalPar.Header.Version==1
    DigitalPar.Header.All=HeaderCellArray;
    DigitalPar.Header.SampleRate=str2double(HeaderCellArray{5,2});
    DigitalPar.Header.CurrentTime=datetime(HeaderCellArray{6,2},'Format', 'MMMM d, yyyy -- HH:mm:ss');
    DigitalPar.Header.NumSensors=1;
elseif DigitalPar.Header.Version==3
    DigitalPar.Header.All=HeaderCellArray;
    DigitalPar.Header.SampleRate=str2double(HeaderCellArray{7,2});
    DigitalPar.Header.CurrentTime=datetime(HeaderCellArray{8,2},'Format', 'MMMM d, yyyy -- HH:mm:ss');
    DigitalPar.Header.NumSensors=2;
elseif DigitalPar.Header.Version==4
    DigitalPar.Header.All=HeaderCellArray;
    %%
    %Assign Values to Structure
    DigitalPar.Header.All=HeaderCellArray;
    DigitalPar.Header.TestName=FieldFind(HeaderCellArray,"Test Name");
    DigitalPar.Header.NumSensors=str2double(FieldFind(HeaderCellArray,"Number of Sensors"));
    DigitalPar.Header.AcqSoftVer=str2double(FieldFind(HeaderCellArray,"Acq Software Revision"));
    DigitalPar.Header.SampleRate=str2double(FieldFind(HeaderCellArray,"Sample Rate"));
    DigitalPar.Header.CurrentTime=datetime(FieldFind(HeaderCellArray,"Current Time"),'Format', 'MMMM d, yyyy -- HH:mm:ss');
    DigitalPar.Header.PrevFileName=FieldFind(HeaderCellArray,"Previous Filename");
    DigitalPar.Header.CurrentFileName=FieldFind(HeaderCellArray,"Current Filename");
    DigitalPar.Header.NextFileName=FieldFind(HeaderCellArray,"Next Filename");
    %%
    %Load Ch. 1
    DigitalPar.Header.VS1.ModelNum=(FieldFind(HeaderCellArray,"VS 1 Model Number"));
    DigitalPar.Header.VS1.SN=(FieldFind(HeaderCellArray,"VS 1 Serial Number"));
    %
    DigitalPar.Header.VS1.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,1)"));
    DigitalPar.Header.VS1.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,2)"));
    DigitalPar.Header.VS1.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (1,3)"));
    DigitalPar.Header.VS1.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,1)"));
    DigitalPar.Header.VS1.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,2)"));
    DigitalPar.Header.VS1.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (2,3)"));
    DigitalPar.Header.VS1.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,1)"));
    DigitalPar.Header.VS1.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,2)"));
    DigitalPar.Header.VS1.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS 1 Shape Factor (3,3)"));
    
    %
    DigitalPar.Header.VS1.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (1)"));
    DigitalPar.Header.VS1.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (2)"));
    DigitalPar.Header.VS1.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS 1 Bias (3)"));
    %%
    %Load Ch. 2
    DigitalPar.Header.VS2.ModelNum=(FieldFind(HeaderCellArray,"VS 2 Model Number"));
    DigitalPar.Header.VS2.SN=(FieldFind(HeaderCellArray,"VS 2 Serial Number"));
    %
    DigitalPar.Header.VS2.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,1)"));
    DigitalPar.Header.VS2.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,2)"));
    DigitalPar.Header.VS2.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (1,3)"));
    DigitalPar.Header.VS2.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,1)"));
    DigitalPar.Header.VS2.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,2)"));
    DigitalPar.Header.VS2.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (2,3)"));
    DigitalPar.Header.VS2.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,1)"));
    DigitalPar.Header.VS2.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,2)"));
    DigitalPar.Header.VS2.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS 2 Shape Factor (3,3)"));
    
    %
    DigitalPar.Header.VS2.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (1)"));
    DigitalPar.Header.VS2.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (2)"));
    DigitalPar.Header.VS2.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS 2 Bias (3)")); 
elseif DigitalPar.Header.Version==5
    DigitalPar.Header.All=HeaderCellArray;
    %%
    %Assign Values to Structure
    DigitalPar.Header.All=HeaderCellArray;
    DigitalPar.Header.TestName=FieldFind(HeaderCellArray,"Test Name");
    DigitalPar.Header.AcqSoftVer=str2double(FieldFind(HeaderCellArray,"Acq Software Revision"));
    DigitalPar.Header.SampleRate=str2double(FieldFind(HeaderCellArray,"Digital Sample Rate"));
    DigitalPar.Header.CurrentTime=datetime(FieldFind(HeaderCellArray,"Current Date and Time"),'Format', 'MMMM d, yyyy -- HH:mm:ss');
    DigitalPar.Header.PrevFileName=FieldFind(HeaderCellArray,"Previous Filename");
    DigitalPar.Header.CurrentFileName=FieldFind(HeaderCellArray,"Current Filename");
    DigitalPar.Header.NextFileName=FieldFind(HeaderCellArray,"Next Filename");
    %%
    DigitalPar.Header.VS.ModelNum=(FieldFind(HeaderCellArray,"VS Model Number"));
    DigitalPar.Header.VS.SN=(FieldFind(HeaderCellArray,"VS Serial Number"));
    %
    DigitalPar.Header.VS.Shape(1,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,1)"));
    DigitalPar.Header.VS.Shape(1,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,2)"));
    DigitalPar.Header.VS.Shape(1,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (1,3)"));
    DigitalPar.Header.VS.Shape(2,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,1)"));
    DigitalPar.Header.VS.Shape(2,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,2)"));
    DigitalPar.Header.VS.Shape(2,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (2,3)"));
    DigitalPar.Header.VS.Shape(3,1)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,1)"));
    DigitalPar.Header.VS.Shape(3,2)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,2)"));
    DigitalPar.Header.VS.Shape(3,3)=str2double(FieldFind(HeaderCellArray,"VS Shape Factor (3,3)"));
    
    %
    DigitalPar.Header.VS.Bias(1)=str2double(FieldFind(HeaderCellArray,"VS Bias (1)"));
    DigitalPar.Header.VS.Bias(2)=str2double(FieldFind(HeaderCellArray,"VS Bias (2)"));
    DigitalPar.Header.VS.Bias(3)=str2double(FieldFind(HeaderCellArray,"VS Bias (3)"));
else
    disp("Error in DigitalHeader")
end
DigitalPar.Header.CurrentTime.TimeZone='America/Los_Angeles'; %Assign Time Zone

end

%end


