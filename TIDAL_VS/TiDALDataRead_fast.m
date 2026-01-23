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
% DigitalData Parameter
base_dir='/Users/thode/Proposals/DURIP/Software/2023-10-12T1055/';

Digital_fnames=dir([base_dir filesep 'DigitalData*vs']);
Analog_fnames=dir([base_dir filesep 'AnalogData*vs']);

% DigitalPar.Name='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1200\DigitalData-27SEP2023-1200.vs';  % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN1. Followed by X,Y,Z, UP, down
DigitalPar.Name='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1226\DigitalData-27SEP2023-1226.vs';  % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN2. Followed by X,Y,Z, UP, down
DigitalPar.Name='/Users/thode/Proposals/DURIP/Software/2023-10-12T1055/DigitalData-13OCT2023-0001.vs';

% Analog Parameters
%AnalogPar.fname='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1200\AnalogData-27SEP2023-1200.vs'; % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN1. Followed by X,Y,Z, UP, down
AnalogPar.fname='VS Data Sets\2023 September Data\TestVSDAQ\2023-09-27T1226\AnalogData-27SEP2023-1226.vs'; % VS 209, test .1hz digital data rate NWSE, final checkout test for DAQ SN2. Followed by X,Y,Z, UP, down
AnalogPar.fname='/Users/thode/Proposals/DURIP/Software/2023-10-12T1055/AnalogData-13OCT2023-0001.vs';

[filepath,name]=fileparts(AnalogPar.fname);

% Change to Base directory so that file path information will work.
load('BaseFilePath.mat');
currentFolder=[currentFolder,filesep]; %Add path seperator to base filename
cd(currentFolder)


%%
% Copy from server to local path
% CopyToLocal(AnalogPar.fname) %Check to see if a local copy exists.  If not, copy from server
%%
% Read in analog data
% Read Header Information

%for Ifile=181:length(Analog_fnames)
for Ifile=1:length(Analog_fnames)
    disp(Analog_fnames(Ifile).name)

    DigitalPar.Name=[filepath filesep Digital_fnames(Ifile).name];
    AnalogPar.fname=[filepath filesep Analog_fnames(Ifile).name];

    AnalogPar = AnalogHeader(AnalogPar);
    % Read Data
    fid=fopen(AnalogPar.fname); % Open File Reference
    header_length=fread(fid,1,'uint32','b'); %Determine header length
    header=fread(fid,header_length,'char*1','b'); % read Header from File
    DataRaw=fread(fid,'12*uint8',1,'b'); % Read data as bytes.  Each data sample is 3, 8 bit numbers followed by a quality byte.  This code reads the all 4 numbers and then ignores the quality byte.
    fclose(fid); %Close reference


    disp('Header info imported');
    %%
    % Manipulate data so that it is in numerical format for computer
    DataRaw=cast(DataRaw,'uint8'); %Cast data to UINT for all values.
    DataShaped=reshape(DataRaw,[3,(size(DataRaw,1)/3)])';  %Reshape array so that each row is 1 sample.  Note that reshape fills columns first so need to transpose
    clear SampleTemp Sample MeasuredValues

    tic

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

    Nfft=256;
    %     for I=1:4
    %         h(I)=subplot(4,1,I);
    %         spectrogram(MeasuredValues(1:(Fs*60),I),hanning(Nfft),round(0.75*Nfft),Nfft,Fs,'yaxis');
    %     end
    %     linkaxes(h,'x');


    if 1==0
        for Isample=1:size(DataShaped,1)
            % if rem(Isample,500000)==0,fprintf('%3.1f percent done\n', 100*Isample/size(DataShaped,1));end
            SampleTemp=typecast(DataShaped(Isample,:),'uint8'); %1x3 unit8 row vector
            if bitget(SampleTemp(1),8) % Check to see if bit is set, meaning it is negative
                %SampleTemp(1)=bitand(SampleTemp(1),0x7f);
                SampleTempMasked=[0xFF,SampleTemp];
                Sample(Isample)=double(typecast(flip(SampleTempMasked),'int32'));
            else
                SampleTempMasked=[0x00,SampleTemp];
                Sample(Isample)=double(typecast(flip(SampleTempMasked),'int32'));
            end
        end
    end
    toc
    %%
    % Take raw int values and convert them to voltage
    %%
    %Load and manipulate Digital Data
    disp('Downloading Digital Data');
    [DigitalDataMeas,DigitalPar]=LoadDigitalData(DigitalPar,InputPar);
    disp('Digital Data Downloaded')
    %%
    % Plot and display analog data results
    AnalogTime=0:1/Fs:5*60-1/Fs; % Create a time vector for entire file
    %


    %plot_vs_time_series;

    %
    disp('Read Complete')
    [~,stem,ext]=fileparts(Analog_fnames(Ifile).name);
    stem=sprintf('%s_VS-209sensor',stem);
    audiowrite([filepath filesep stem '.wav'],MeasuredValues,Fs,'BitsPerSample',32);
    save([filepath filesep strrep(stem,'Analog','Digital') '.mat'],'DigitalDataMeas','DigitalPar');
    %%Write wave file
    %  audiowrite([fileparts(AnalogPar.fname)) '.wav'],MeasuredValues,int32(AnalogPar.AHeader.SampleRate);

end %Ifile

%%
%
%Save Wave File
% audiowrite([fileparts(AnalogPar.fname) '\ChX.wav'],MeasuredValues(:,1)/3/rms(MeasuredValues(:,1)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChY.wav'],MeasuredValues(:,2)/3/rms(MeasuredValues(:,2)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChZ.wav'],MeasuredValues(:,4)/3/rms(MeasuredValues(:,4)),int32(AnalogPar.AHeader.SampleRate))
% audiowrite([fileparts(AnalogPar.fname) '\ChH.wav'],MeasuredValues(:,3)/3/rms(MeasuredValues(:,3)),int32(AnalogPar.AHeader.SampleRate))
