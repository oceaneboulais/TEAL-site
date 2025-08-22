#!/bin/bash
#
# Copies downloaded HYCOM fields to the server path for access
#
# Alex Andriatis
# 2021-05-03
starttime=`date +%s`
RUNDIR="Read_Hycom"
DATADIR="HYCOM"
#WEBDIR="/var/www/html"
WEBDIR="/Volumes/Shared/www/html"

rsync -auvihP $DATADIR/Hycom_Timeseries.mat $WEBDIR/data/.
rsync -auvihP $DATADIR/Hycom_Timeseries_Center.mat $WEBDIR/data/.

now=$(date +"%T")
echo "Rsynced files at: $now"
endtime=`date +%s`
runtime=$((endtime-starttime))

echo "Runtime: " $runtime " seconds"

