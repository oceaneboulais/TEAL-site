function [x,nas,header] = readTIDALData(filename,which_data)
% [MeasuredValues,DigitalDataMeas, Fs] = readTIDALData(filename)
% this function reads in the analog TIDAL data given by filename and the
% associated digital data and returns the following
%   MeasuredValues : matrix of analog data for channels H, X, Y, Z
%       units of volts)
%   DigitalDataMeas: magnetometer and accelerometer data 
%       accelerometer: 4-X, 5-Y, 6-Z
%       magnetometer: 7-X, 8-Y, 9-Z
%   which_data (optional): 1 x 3 logical for: [analgo  digital header]

if ~exist('which_data','var')
    which_data = [true true true];
end

% function based of the matlab script master_TiDALDataRead.m 
% A. Laferriere 2025

% initialize output 
x = []; % acoustic data
nas = []; % NAS data
header = []; % acoustic data header 


disp(filename)

if which_data(3)
    %  init analog data class
    AnalogPar=AnalogParClass;
    AnalogPar.fname= filename;
    
    % read header info
    AnalogPar = AnalogHeader(AnalogPar);
    header = AnalogPar.AHeader;
end

if which_data(1)

%     disp('Reading raw data...');
    fid=fopen(filename); % Open File Reference
    header_length=fread(fid,1,'uint32','b'); %Determine header length
    header=fread(fid,header_length,'char*1','b'); % read Header from File
    DataRaw=fread(fid,'12*uint8',1,'b'); % Read data as bytes.  Each data sample is 3, 8 bit numbers followed by a quality byte.  This code reads the all 4 numbers and then ignores the quality byte.
    fclose(fid); %Close reference

     % Manipulate data so that it is in numerical format for computer
    DataRaw=cast(DataRaw,'uint8'); %Cast data to UINT for all values.
    DataShaped=reshape(DataRaw,[3,(size(DataRaw,1)/3)])';  %Reshape array so that each row is 1 sample.  Note that reshape fills columns first so need to transpose
    clear SampleTemp Sample x
    
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
    x=reshape(Data,4,size(Data,1)/4)';  % Make an array of data X,Y,H,Z
    x=x(:,[3 1 2 4]);
    disp('Raw data read complete.');  
end

if which_data(2)
    % init digital data class 
    DigitalPar=DigitalParClass;

    InputPar=InputClass;
    InputPar.FileGeneration=FileGenEnum.New;

    filename_base = erase(filename,'AnalogData');
    [filepath,name,ext] = fileparts(filename_base);
    DigitalPar.Name=fullfile(filepath,['DigitalData' name ext]);


    %Load Digital Data
%     disp('Reading digital data...')
    [nas.DigitalDataMeas,nas.DigitalPar]=LoadDigitalData(DigitalPar,InputPar);
    disp('Read digital data complete.')
end


