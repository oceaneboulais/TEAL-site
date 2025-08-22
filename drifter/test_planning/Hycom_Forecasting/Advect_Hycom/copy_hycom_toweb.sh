#!/bin/bash
#
# Copies downloaded HYCOM fields to the server path for access
#
# Alex Andriatis
# 2021-05-03
starttime=`date +%s`
RUNDIR="/home/aandriat/Hycom_Forecasting/Advect_Hycom"
DATADIR="/home/aandriat/Data/HYCOM"
WEBDIR="/var/www/html"

rsync -auvihP $DATADIR/LJCT_Hycom_Timeseries_advection.mat $WEBDIR/data/.

now=$(date +"%T")
echo "Rsynced files at: $now"
endtime=`date +%s`
runtime=$((endtime-starttime))

echo "Runtime: " $runtime " seconds"

