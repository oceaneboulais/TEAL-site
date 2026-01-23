#!/bin/sh
#
# Reads the latest HYCOM hindcasts and forecasts +/- 7 days
# 
# Alex Andriatis
# 2021-05-02

starttime=`date +%s`
RUNDIR=$(pwd)
mkdir $RUNDIR/LOGS

echo "Reading HYCOM"
bash $RUNDIR/Read_Hycom/run_get_hycom.sh > $RUNDIR/LOGS/run_get_hycom.log 2>&1

echo "Advecting HYCOM"
bash $RUNDIR/Advect_Hycom/run_advect_hycom.sh > $RUNDIR/LOGS/run_advect_hycom.log 2>&1

echo "Making velocity images"
bash $RUNDIR/Plot/Velocity/run_makefigure_velocity_image.sh > $RUNDIR/LOGS/run_makefigure_velocity_image.log 2>&1

echo "Making advection images"
bash $RUNDIR/Plot/Advection/run_makefigure_advection_image.sh > $RUNDIR/LOGS/run_makefigure_advection_image.log 2>&1

echo "Making velocity movies"
bash $RUNDIR/Plot/Velocity/run_makefigure_velocity_movie.sh > $RUNDIR/LOGS/run_makefigure_velocity_movie.log 2>&1

echo "Making advection movies"
bash $RUNDIR/Plot/Advection/run_makefigure_advection_movie.sh > $RUNDIR/LOGS/run_makefigure_advection_movie.log 2>&1

echo "Completed Hycom Forecasting"
endtime=`date +%s`
runtime=$((endtime-starttime))
echo "Reading complete"
echo "Runtime: " $runtime " seconds"
