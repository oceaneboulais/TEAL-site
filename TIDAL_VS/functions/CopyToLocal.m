function []=CopyToLocal(RelativePath)
%%
%Author: Mark Paulus
% Rev. 1 Changes-->
%   Introduced Function
%   6/23/2020
%
%%
%This function will be used to copy files into a local directory
%
%%
%Inputs -->
%   RelativePath--> The path, including filename relative to the base
%       directory \Research\VS Data Sets
%%
%Debugging code

%RelativePath='September 2019 Data\Buoy 21\Calibration\DigitalData-25Sep2019-1024.vs'
%%
%User=getenv('USERPROFILE');
%Base='VS Data Sets';
%filename=fullfile(Base,RelativePath);
filename=RelativePath;
Local=exist(filename);
if Local==2 % Check to see if the local file exists.  If it does, do nothing, else copy
else
    display(filename);
    prompt='File does not exist on the local directory.  Do you wish to copy to file from the server? [Y/N]';
    response=input(prompt,'s'); % Prompt user to create a local directory
    if response=='Y' || response=='y'  %If a lower or upper case y is responded for yes, then copy file
        ServerBase='W:\'; %Define the Base path to the server
        ServerFile=fullfile(ServerBase,RelativePath); %Define the File on the server
        display('Beginning copy.  This may take a while')
        LocalLocation=fileparts(filename); % define the local location for the file to be copied
        IsDir=exist(LocalLocation); %Check to see if directory exists
        if IsDir==7 %Check to see if directory exists
        else
            mkdir(LocalLocation); % Make a directory if one doesn't exist
        end
        copyfile(ServerFile,filename)
        display('Copy Complete')
    else
        display('File cannot be opened, program was aborted')
       return 
    end
end
        
    