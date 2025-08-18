classdef GroundTruthEnum
    enumeration 
        % Each Range track has a different read file and must be selected.
        % Default will cause an error.  The BearingTest is used when
        % conducting bearing tests and no range track data is available.
        % The bearing track must be added manually to the options file.
        Default, BearingTest, RangeTrackOct2018,RangeTrackSept2019, RangeTrackJuly2020
    end
end