function HeaderCellArray = ReadHeader(fname)
%Author: Mark Paulus
%Rev. -, 10/3/2019
%Read Header on digital and analog data files
% Input Arguments
%   Input.
%       fname-->Name of raw data file (acoustic)
% Outputs
%   HeaderCellArray--> Header Data from file
%%
% %Debug Values
% clear all;
% close all;
% % InputPar.fname='AnalogData-25Sep2019-1025.vs'; % File stored in Input data.  Need to add to path for this to work.
% % InputPar.Header.Version=3;
% % InputPar.Header.type="Analog";
% InputPar.fname='DigitalData-25Sep2019-1025.vs'; % File stored in Input data.  Need to add to path for this to work.
% InputPar.FileVersion=3;
% InputPar.Header.type="Digital";
%%
%Read Header Data
fid=fopen(fname); % Open File Reference
header_length=fread(fid,1,'uint32','b'); %Determine header length
header=fread(fid,header_length,'char*1','b'); % read Header from File
header=char(header); %convert integer value of character to letter
fclose(fid);
%%
%Convert to Cell Array format where each entry is a string
HeaderCellArray = strsplit(header','\n'); %Split character string by line feeds
%Convert each element to string
for i=1:size(HeaderCellArray,2)
    HeaderCellArray{i}=convertCharsToStrings(HeaderCellArray{i});
end
%
HeaderCellArray=HeaderCellArray(1,1:end-1); % Remove last cell.  It was empty
HeaderCellArray=reshape(HeaderCellArray,2,[]); %Reshape so first column is name of value
HeaderCellArray=HeaderCellArray';   %Take the transpose so each row is a field


end


