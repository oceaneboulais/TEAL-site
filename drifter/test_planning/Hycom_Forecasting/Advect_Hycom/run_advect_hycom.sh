#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02
starttime=`date +%s`
RUNDIR="/home/aandriat/Hycom_Forecasting/Advect_Hycom"

echo "Advecting HYCOM"
mkdir $RUNDIR/LOGS
nohup matlab -nodesktop -nosplash < $RUNDIR/advect_hycom.m > $RUNDIR/LOGS/advect_hycom.log 2>&1
bash $RUNDIR/copy_hycom_toweb.sh > $RUNDIR/LOGS/copy_hycom_toweb.log 2>&1

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
