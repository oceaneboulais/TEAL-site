%%
%Author: Mark Paulus
%%
%This function will be used to write the base file path to a text file.
%This will allow the base file path to be used throughtout the scripts.
%This was done to allow each operation to have its own folder and not
%reside at the highest level.  This function will run at startup
%
%%
currentFolder = pwd;
file='BaseFilePath'; % File name containing the base path
save(file,'currentFolder');
