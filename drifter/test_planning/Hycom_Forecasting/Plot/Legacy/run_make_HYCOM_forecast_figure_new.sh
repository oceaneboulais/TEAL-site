#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02
starttime=`date +%s`
RUNDIR="/home/aandriat/Hycom_Forecasting/Plot"

echo "Plotting forecasted velocities"
nohup matlab -nodesktop -nosplash < $RUNDIR/run_make_HYCOM_forecast_figure.m > $RUNDIR/LOGS/run_make_HYCOM_forecast_figure.log 2>&1

DATADIR="/home/aandriat/Data/HYCOM/Figures"
WEBDIR="/var/www/html"

rsync = -auvihP $DATADIR/HYCOM_forecast_* $WEBDIR/figures/.

#rsync -auvihP $DATADIR/HYCOM_forecast_200.png $WEBDIR/figures/.
#rsync -auvihP $DATADIR/HYCOM_forecast_200.avi $WEBDIR/figures/.
#rsync -auvihP $DATADIR/HYCOM_forecast_200_zoom.png $WEBDIR/figures/. 
#rsync -auvihP $DATADIR/HYCOM_forecast_200_zoom.avi $WEBDIR/figures/.

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
