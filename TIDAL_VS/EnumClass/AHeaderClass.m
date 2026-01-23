classdef AHeaderClass
%%This class is for holding the digital parameters
    
    properties
        All={};
        TestName={'Default Test Name'}
        Version=5; %File Format Revision Number.  Rev 3 was 2 channels of data in old format
        AcqSoftVer=[]; % Version of Acquisition Software
        SampleRate=[]; % Samples per second of digital data
        CurrentTime=datetime('January 1, 1900 -- 01:00:00','Format', 'MMMM d, yyyy -- HH:mm:ss');
        PrevFileName=[];
        CurrentFileName=[];
        NextFileName=[];
        VS=VSInfoAnalog;
    end
    
end

