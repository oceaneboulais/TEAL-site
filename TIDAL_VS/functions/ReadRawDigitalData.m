function [DigitalDataRaw]=ReadRawDigitalData(DigitalPar)
%%%%%%%%%%%%%%%%%%%%
%Author: Mark Paulus
%Rev. 1, 8/30/2018
%
%   Read Raw Digital Data
%       This function reads the raw digital data and converts it to a data
%       file
%Read raw data in from file.  Store in Data
%fname='C:\Users\PaulusME\Documents\Research\Hybrid Mobile Vehicle\Data Acquisition\MarkPaulusMatlabToolbox\VS Data AcquisitionRev18\Input Data\DigitalData-07Dec2018-1304.vs';
fname=DigitalPar.Name; % Assign to local variable
fid=fopen(fname); % Open File Reference
header_length=fread(fid,1,'uint32','b'); %Determine header length
header=fread(fid,header_length,'char*1','b'); % read Header from file.  This data is used to move to a position in the file.  The data is not used here
%
if DigitalPar.Header.Version <= 3
    dataraw=fread(fid,'40*uint8',24,'b'); % Read 40 unsigned 8 bit integers.  Then skip 3 double precision GPS data values (64 bits each, or 8 uint8 values)
    dataraw=cast(dataraw,'uint8');
    
    %%
    %Sort 1D array into data whose row is a time stamped data point
    N=floor(length(dataraw)/40)*40;
    dataraw=dataraw(1:N);
    datatemp=reshape(dataraw,40,[]); %resahpe array so that each column is a data point for 1 time
    datatemp=datatemp'; %transpose so that each row is 1 data point in time
    datatemp=datatemp(:,11:40); %remove zeroes
    %Combine data into 16 bit integers
    for i=1:size(datatemp,1) %For each row
        %The following will combine adjacent arry elements (such as 1&2 or 3&4)
        %into a single higher byte type (U8 to U16).  Matlab is little endian,
        %but the bytes are provided in big endian.  Data is combined and then
        %the bytes are swapped.
        data(i,:)=swapbytes(typecast(datatemp(i,:),'int16')); %
    end
    DigitalDataRaw=cast(data,'double');
elseif DigitalPar.Header.Version==4
    
    dataraw=fread(fid,'54*uint8','b'); %Read 30 unsigned 8 bit integers.Then 3 double precision GPS data values (64 bits each, or 8 uint8 values).  The 10 leading zeros were removed from file saving.
    dataraw=cast(dataraw,'uint8');
        %Sort 1D array into data whose row is a time stamped data point
    N=floor(length(dataraw)/54)*54;
    dataraw=dataraw(1:N);
    datatemp=reshape(dataraw,54,[]); %resahpe array so that each column is a data point for 1 time
    datatemp=datatemp'; %transpose so that each row is 1 data point in time
    %%
    %The following will combine adjacent arry elements (such as 1&2 or 3&4)
    %into a single higher byte type (U8 to U16).  Matlab is little endian,
    %but the bytes are provided in big endian.  Data is combined and then
    %the bytes are swapped.
    for i=1:size(datatemp,1) %For each row
        DigDataTemp=swapbytes(typecast(datatemp(i,1:30),'int16')); %
        GPSDataTemp=swapbytes(typecast(datatemp(i,31:54),'double'));
        data(i,:)=[cast(DigDataTemp,'double'),GPSDataTemp];
    end
    %%
    %Map locations of new data into locations of old data
    DigitalDataRaw=zeros(size(data));
    DigitalDataRaw(:,1:2)=data(:,1:2);
    DigitalDataRaw(:,4:9)=data(:,3:8);
    DigitalDataRaw(:,3)=data(:,9);
    DigitalDataRaw(:,10:15)=data(:,10:15);
    %DigitalDataRaw(:,16:18)=data(:,16:18); %GPS Data
elseif DigitalPar.Header.Version>=5
    
    dataraw=fread(fid,'54*uint8','b'); %Read 30 unsigned 8 bit integers.Then 3 double precision GPS data values (64 bits each, or 8 uint8 values).  The 10 leading zeros were removed from file saving.
    dataraw=cast(dataraw,'uint8');
        %Sort 1D array into data whose row is a time stamped data point
    N=floor(length(dataraw)/54)*54;
    dataraw=dataraw(1:N);
    datatemp=reshape(dataraw,54,[]); %reshape array so that each column is a data point for 1 time
    datatemp=datatemp'; %transpose so that each row is 1 data point in time
    %%
    %The following will combine adjacent arry elements (such as 1&2 or 3&4)
    %into a single higher byte type (U8 to U16).  Matlab is little endian,
    %but the bytes are provided in big endian.  Data is combined and then
    %the bytes are swapped.
    for i=1:size(datatemp,1) %For each row
        DigDataTemp=swapbytes(typecast(datatemp(i,1:30),'int16')); %
        GPSDataTemp=swapbytes(typecast(datatemp(i,31:54),'double'));
        data(i,:)=[cast(DigDataTemp,'double'),GPSDataTemp];
    end
    %%
    %Map locations of new data into locations of old data
    DigitalDataRaw=zeros(size(data));
    DigitalDataRaw(:,1:2)=data(:,1:2);
    DigitalDataRaw(:,4:9)=data(:,3:8);
    DigitalDataRaw(:,3)=data(:,9);
    DigitalDataRaw(:,10:15)=data(:,10:15);
    DigitalDataRaw(:,16:18)=data(:,16:18); %GPS Data
else
    "Non Valid Format"
end
fclose(fid); %Close reference
end