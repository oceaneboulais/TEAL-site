function foldernames = getFolders(datadir)
% get subfolders in a specified directory and return them as a string array
if isempty(datadir)
    foldernames = {};
    return
end
dirlist = dir(datadir);
if isempty(dirlist)
    warning('No files found in this directory.')
    foldernames = {}; 
    return
end
foldernames = string({dirlist.name});
foldernames = foldernames([dirlist.isdir]);
% remove temporary file folders and back referenced ones
foldernames(startsWith(foldernames,'.')) = [];