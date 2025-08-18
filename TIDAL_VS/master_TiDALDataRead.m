% This Script is for reading data off of the TiDAL.
%function master_TiDALDataRead(base_dir)
%

clear all
close all
flag_digital_only=false;

addpath functions EnumClass
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

keyword='Piertest';
TiDAL_ID=3;
base_dir=load_directory_locations(keyword,TiDAL_ID);


Digital_fnames=dir([base_dir filesep 'DigitalData*.vs']);
Analog_fnames=dir([base_dir filesep 'AnalogData*.vs']);


%[filepath,name]=fileparts(AnalogPar.fname);
filepath=base_dir;

% Change to Base directory so that file path information will work.
%load('BaseFilePath.mat');
%currentFolder=[currentFolder,filesep]; %Add path seperator to base filename
%cd(currentFolder)
currentFolder=pwd;


%%
% Copy from server to local path
% CopyToLocal(AnalogPar.fname) %Check to see if a local copy exists.  If not, copy from server
%%
% Read in analog data
% Read Header Information


for Ifile=1:length(Analog_fnames)
    disp(Analog_fnames(Ifile).name)

    try
        DigitalPar.Name=[filepath filesep Digital_fnames(Ifile).name];
        AnalogPar.fname=[filepath filesep Analog_fnames(Ifile).name];

        % Read Data
        if ~flag_digital_only
            AnalogPar = AnalogHeader(AnalogPar);

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
            AnalogTime=0:1/Fs:5*60-1/Fs; % Create a time vector for entire file

            %%Write wave file
            %  audiowrite([fileparts(AnalogPar.fname)) '.wav'],MeasuredValues,int32(AnalogPar.AHeader.SampleRate);
            toc
        end  %%Digital only

        %%
        %%
        %Load and manipulate Digital Data
        disp('Downloading Digital Data');
        [DigitalDataMeas,DigitalPar]=LoadDigitalData(DigitalPar,InputPar);
        disp('Digital Data Downloaded')
        %%
        disp('Read Complete')
        [~,stem,ext]=fileparts(Analog_fnames(Ifile).name);
        stem=sprintf('%s_VS-209sensor',stem);
        if ~flag_digital_only
            audiowrite([filepath filesep stem '.wav'],MeasuredValues,Fs,'BitsPerSample',32);
        end
        save([filepath filesep strrep(stem,'Analog','Digital') '.mat'],'DigitalDataMeas','DigitalPar');

    catch
        fprintf('%s conversion failed...\n',Analog_fnames(Ifile).name);
    end
end %Ifile

%%
%

