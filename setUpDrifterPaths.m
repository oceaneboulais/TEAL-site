function [drivename,savedir,gitpath] = setUpDrifterPaths(use_remote,add_path)
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
    case 'Alisons-MacBook-Pro.local'
        % Alison local computer
        gitpath = '/Users/alaferri/GIT/sio_research';
        if use_remote % use jonah
            fprintf('Using remote path to jonah on Alison''s computer\n')
            drivename = '/Volumes/Laferriere/ONR_DRIFTER';
            savedir = '/Volumes/Laferriere/Analysis';
        else % use external drive
            fprintf('Using local path to Novus on Alison''s computer\n')
            drivename = '/Volumes/Novus/ONR_DRIFTER/';
            savedir = '/Volumes/Novus/Analysis';          
        end
    case 'macmussel-2.ucsd.edu'
        % this is for macmussel / Alison
        fprintf('Using remote path to Jonah on Alison''s macmussel account\n')
        gitpath = '/Volumes/Laferriere/GIT/sio_research_jonah';
        drivename = '/Volumes/Laferriere/ONR_DRIFTER';
        savedir = '/Volumes/Laferriere/Analysis';
    otherwise 
        error('set your path!')
end

if add_path
    addpath(genpath(gitpath))
end
