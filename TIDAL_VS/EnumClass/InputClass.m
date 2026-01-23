classdef InputClass
    %This class defines all the input parameters and initializes them to
    %default.
properties
    %% Define Properties in options file
    % File Properties
    %AnalogPar=AnalogParClass;
    trackname='Default-trackname'; %Defines the name of the track file to load
    FileGeneration=FileGenEnum.Old;
    %%
    % Analysis Parameters
    nfft=12800; %The length of the FFT window in samples
    NAvg=1; %Number of FFT Averages.  This is from legacy code and the FFT should not be averaged when looking at phase.
    CSDMAvg=10;  % Number of CSDM to include in average.
    NBearingAvg=4; %Number of Bearing Averages after bearing is determined
    NIntensityAvg=4; %Number of Intensity values to average before computing bearing
    AnalysisMethod=AnalysisMethodsEnum.Intensity; % CBF, Intensity, RMS-Time Domain,CSDM
    Win=WindowEnum.Hanning; %Choose the window type for the FFT calculations
    StartTime=0; %Start at beginning
    EndTime=300; %End time of analog file
    frlo=10; % Choose the low frequency [hz] for analysis .
    frhi=2000; % Choose the High frequency [hz] for analysis.
    %%
    % Environmental values
    ThetaDec=15.75; %Choose the declination angle[deg].  The declination angle for 98345 is 15.75 deg.
    density=1000; %Choose the density [kg/m^3] of the media.  1000 kg/m^3 for seawater and 1.2250 kg/m^3 for air.
    SpeedOfSound=1500; %Choose the speed of sound [m/s] for the media.  1500 m/s for seawater and 343 m/s for air.
    g=9.81; %Acceleration [m/s^2] due to gravity.
    %%   
    BearingName='Default-BearingName' %Defines the title used on the bearing plots  
    %%
    % TIS File Saving Properties
    TISFileName='Default-TISFileName' %Defines the file path and name for saving the TIS file if 
    %%
    % Options to be used within the code
    Options=OptionsClass;
   
    
end
        
end