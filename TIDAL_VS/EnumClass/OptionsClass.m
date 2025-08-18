classdef OptionsClass
    %This defines options to be set in the options files for how the code
    %will execute.  Many of the options are true/false based on historical
    %code development.  New options should use enumerators
    properties
        StartAngle=0; %This is the start angle when using the Intensity Histogram
        AngleChange=180; %This is the amount of angle change allowed when searching the Intensity Histogram
        MagCompare=false; %true graphs the AccelMag and PressMag, false does not graph.
        PlotTimeBearing=false; %Controls plotting of the time bearing record
        PlotSpectrogram=false; %Controls plotting of the histogram
        PlotCalibration=false; %Controls plotting of the calibration results.
        RemOutliers=false; %Controls removal of Quartile Outliers
        IntensityHistMethod=true; %Controls whether Histogram method is used.  False uses mean of all values from frlo to frhi
        PlotRotXfromN=false; %Plots rotation of the X axis from North in the NE plane
        Weighted=true; %Use weighted Historgram method.  This is always true.
        CoordTransformation=true; %Perform a coordinate transformation to NED coordinates, otherwise false reports results in VS X,Y,Z coordinate.
        VS_SN169=true; % Sensor 169 needed to have adjustments based on improper factory calibration alignment.  Should only be set to true for SN 169.
        ConvertToTIS=false; % Convert data to a TIS outuput and write to file.
        CheckTISFile=false; %This is used to plot spectrograms of files before and after making the wave file.  This is only necessary when ConvertToTIS is true
        GPSTrack=false; %Use GPS Track for Buoy's
        BuoyType=BuoyTypeEnum.Default; %Assigns the Buoy type
        PlotAnalogTimeData=false; %Plots analog time data after loaded.
        WaveWrite=false; %Writes a wavefile to disk for analog files
        %%
        % Ground truth and tracking assignemnts
        GroundTruth=GroundTruthEnum.Default; %Assigns the type of track to compare the VS results against
        Buoy=BuoyEnum.Default; %Assigns the buoy to use from the track data or GPS for comparison.  Could be VS, Sonobuoy or others.  This comes from track data
        Target=TargetEnum.Default; %Assigns the target to use for comparison.
    end
end