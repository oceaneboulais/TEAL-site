#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02
starttime=`date +%s`
RUNDIR="Read_Hycom"

echo "Reading HYCOM"
mkdir $RUNDIR/LOGS/
nohup matlab -nodesktop -nosplash < $RUNDIR/load_hycom_multiday_automated.m > $RUNDIR/LOGS/load_hycom_multiday_automated.log 2>&1
nohup matlab -nodesktop -nosplash < $RUNDIR/combine_hycom.m > $RUNDIR/LOGS/combine_hycom.log 2>&1
nohup matlab -nodesktop -nosplash < $RUNDIR/calculations_hycom.m > $RUNDIR/LOGS/calculations_hycom.log 2>&1
nohup matlab -nodesktop -nosplash < $RUNDIR/getcenter.m > $RUNDIR/LOGS/getcenter.log 2>&1
bash $RUNDIR/copy_hycom_toweb.sh > $RUNDIR/LOGS/copy_hycom_toweb.log 2>&1

endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
