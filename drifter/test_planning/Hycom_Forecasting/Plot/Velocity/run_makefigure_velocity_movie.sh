#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02
starttime=`date +%s`
RUNDIR="Plot/Velocity"

echo "Plotting forecasted velocities"
nohup matlab -nodesktop -nosplash < $RUNDIR/run_makefigure_velocity_movie.m > $RUNDIR/LOGS/run_makefigure_velocity_movie.log 2>&1

DATADIR="HYCOM/Figures"
#WEBDIR="/var/www/html"
WEBDIR="/Volumes/Shared/www/html"

rsync -auvihP $DATADIR/HYCOM_forecast_velocity_200*.avi $WEBDIR/figures/.

ffmpeg -f avi -i $DATADIR/HYCOM_forecast_velocity_200.avi $DATADIR/HYCOM_forecast_velocity_200.mp4 -y
ffmpeg -f avi -i $DATADIR/HYCOM_forecast_velocity_200_zoom.avi $DATADIR/HYCOM_forecast_velocity_200_zoom.mp4 -y

rsync -auvihP $DATADIR/HYCOM_forecast_velocity_200*.mp4 $WEBDIR/figures/.

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
