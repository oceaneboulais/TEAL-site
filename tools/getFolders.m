function foldernames = getFolders(datadir)
% get subfolders in a specified directory and return them as a string array
dirlist = dir(datadir);
foldernames = string({dirlist.name});
foldernames = foldernames([dirlist.isdir]);
% remove temporary file folders and back referenced ones
foldernames(startsWith(foldernames,'.')) = [];