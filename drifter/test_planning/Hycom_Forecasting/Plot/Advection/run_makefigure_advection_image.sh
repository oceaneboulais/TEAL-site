#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02
starttime=`date +%s`
RUNDIR="Plot/Advection"

echo "Plotting forecasted velocities"
nohup matlab -nodesktop -nosplash < $RUNDIR/run_makefigure_advection_image.m > $RUNDIR/LOGS/run_makefigure_advection_image.log 2>&1

DATADIR="HYCOM/Figures"
#WEBDIR="/var/www/html"
WEBDIR="/Volumes/Shared/www/html"

rsync -auvihP $DATADIR/HYCOM_forecast_advection_200*.png $WEBDIR/figures/.
rsync -auvihP $DATADIR/HYCOM_forecast_advection_200*.fig $WEBDIR/figures/.

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
