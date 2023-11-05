function [data_basedir,procdata_basedir,gitpath,envdir] = setUpDrifterPaths(use_remote,add_path)
% set up paths depending on what system I'm using
% drivename: base directory where all drifter data is hosted
% savedir: base directory where all analysis products are saved
% gitdir: directory of GIT repo sio_research
% use_remote: optional flag to indicate that we want to use the local drive
%   or the remote drive (jonah)
% add_path: optional flag to indicate if we want to add the git path or not
if ~exist("use_remote",'var')
    use_remote = false;
end
if ~exist("add_path",'var')
    add_path = true;
end

[~,hostname] = system('hostname');
switch hostname(1:end-1)
    case {'Alisons-MacBook-Pro.local','Alisons-MBP','alisons-mbp.dynamic.ucsd.edu'}
        % Alison local computer
        gitpath = '/Users/alaferri/GIT/sio_code/sio_research';
        if use_remote % use jonah
            fprintf('Using remote path to jonah on Alison''s computer\n')
            data_basedir = '/Volumes/public/Laferriere/ONR_DRIFTER';
            procdata_basedir = '/Volumes/public/Laferriere/Analysis';
            envdir = '/Volumes/public/Laferriere/Databases';
        else % use external drive
            fprintf('Using local path to Novus on Alison''s computer\n')
            data_basedir = '/Volumes/Novus/ONR_DRIFTER/';
            procdata_basedir = '/Volumes/Novus/Analysis';     
            envdir = '/Volumes/Novus/Environments';
        end
    case 'macmussel-2.ucsd.edu'
        % this is for macmussel / Alison
        fprintf('Using remote path to Jonah on Alison''s macmussel account\n')
        gitpath = '/Volumes/Laferriere/GIT/sio_research_jonah';
        data_basedir = '/Volumes/Laferriere/ONR_DRIFTER';
        procdata_basedir = '/Volumes/Laferriere/Analysis';
        envdir = '/Volumes/Laferriere/Databases';
    otherwise 
        error('set your path!')
end

if add_path
    addpath(genpath(gitpath))
end
