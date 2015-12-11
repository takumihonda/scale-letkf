#!/bin/bash
#===============================================================================
#
#  Wrap cyclebdy.sh in a K-computer job script (micro) and run it.
#
#  November 2014, created,                 Guo-Yuan Lien
#
#-------------------------------------------------------------------------------
#
#  Usage:
#    cyclebdy_K_micro.sh [STIME ETIME MEMBERS CYCLE CYCLE_SKIP IF_VERF IF_EFSO ISTEP FSTEP TIME_LIMIT]
#
#===============================================================================

cd "$(dirname "$0")"
myname1='cyclebdy'

#===============================================================================
# Configuration

. config.main
res=$? && ((res != 0)) && exit $res
. config.$myname1
res=$? && ((res != 0)) && exit $res

. src/func_distribute.sh
. src/func_datetime.sh
. src/func_util.sh
. src/func_$myname1.sh

#-------------------------------------------------------------------------------

if ((TMPDAT_MODE != 2 || TMPRUN_MODE != 2 || TMPOUT_MODE != 2)); then
  echo "[Error] $0: When using 'micro' resource group," >&2
  echo "        \$TMPDAT_MODE, \$TMPRUN_MODE, \$TMPOUT_MODE all need to be 2." >&2
  exit 1
fi

#-------------------------------------------------------------------------------

setting "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "${10}"

jobscrp="$TMP/${myname1}_job.sh"

#-------------------------------------------------------------------------------

echo "[$(datetime_now)] Start $(basename $0) $@"
echo

for vname in DIR OUTDIR DATA_TOPO DATA_LANDUSE DATA_BDY DATA_BDY_WRF OBS OBSNCEP MEMBER NNODES PPN \
             FCSTLEN FCSTOUT EFSOFLEN EFSOFOUT OUT_OPT \
             STIME ETIME MEMBERS CYCLE CYCLE_SKIP IF_VERF IF_EFSO ISTEP FSTEP; do
  printf '  %-10s = %s\n' $vname "${!vname}"
done

echo

#-------------------------------------------------------------------------------

if [ ${TMP:0:8} != '/scratch' ]; then
  echo "[Error] $0: When using 'micro' resource group, \$TMP will be completely removed." >&2
  echo "        Wrong setting detected:" >&2
  echo "        \$TMP = '$TMP'" >&2
  exit 1
fi
safe_init_tmpdir $TMP

#===============================================================================
# Determine the distibution schemes

# K computer
NNODES_real=$NNODES
PPN_real=$PPN
NNODES=$((NNODES*PPN))
PPN=1

declare -a procs
declare -a mem2node
declare -a node
declare -a name_m
declare -a node_m

safe_init_tmpdir $NODEFILE_DIR
distribute_fcst "$MEMBERS" $CYCLE - $NODEFILE_DIR

#===============================================================================
# Determine the staging list and then stage in

echo "[$(datetime_now)] Initialization (stage in)"

safe_init_tmpdir $STAGING_DIR
staging_list
bash $SCRP_DIR/src/stage_in.sh a

#-------------------------------------------------------------------------------
# stage-in: scripts

cp -L -r $SCRP_DIR/config.main $TMP/config.main
cp -L -r $SCRP_DIR/config.rc $TMP/config.rc
cp -L -r $SCRP_DIR/config.${myname1} $TMP/config.${myname1}
cp -L -r $SCRP_DIR/${myname1}.sh $TMP/${myname1}.sh
cp -L -r $SCRP_DIR/${myname1}_step.sh $TMP/${myname1}_step.sh
mkdir -p $TMP/src
cp -L -r $SCRP_DIR/src/* $TMP/src

echo "SCRP_DIR=\"$TMP\"" >> $TMP/config.main
echo "LOGDIR=\"$TMP/log\"" >> $TMP/config.main

echo "NNODES=$NNODES" >> $TMP/config.main
echo "PPN=$PPN" >> $TMP/config.main
echo "NNODES_real=$NNODES_real" >> $TMP/config.main
echo "PPN_real=$PPN_real" >> $TMP/config.main

#===============================================================================
# Creat a job script

echo "[$(datetime_now)] Create a job script '$jobscrp'"

rscgrp="micro"

cat > $jobscrp << EOF
#!/bin/sh
##PJM -g ra000015
#PJM -N ${myname1}_${SYSNAME}
#PJM -s
#PJM --rsc-list "node=${NNODES_real}"
#PJM --rsc-list "elapse=${TIME_LIMIT}"
#PJM --rsc-list "rscgrp=${rscgrp}"
##PJM --mpi "shape=${NNODES_real}"
#PJM --mpi "proc=$NNODES"
#PJM --mpi assign-online-node

. /work/system/Env_base
export OMP_NUM_THREADS=${THREADS}
export PARALLEL=${THREADS}

./${myname1}.sh "$STIME" "$ETIME" "$MEMBERS" "$CYCLE" "$CYCLE_SKIP" "$IF_VERF" "$IF_EFSO" "$ISTEP" "$FSTEP"
EOF

#===============================================================================
# Run the job

echo "[$(datetime_now)] Run ${myname1} job on PJM"
echo

job_submit_PJM $jobscrp
echo

if ((ONLINE_STGOUT != 1)); then

  job_end_check_PJM $jobid

else # when using online stage-out, check the joub status in a special way.

  loop=1
  while (($(pjstat $jobid | sed -n '2p' | awk '{print $10}') >= 1)); do
    if [ -e "$TMP/loop.${loop}.done" ]; then
      echo "[$(datetime_now)] Online stage out: Loop # $loop"
      bash $SCRP_DIR/src/stage_out.sh a $loop &
      loop=$((loop+1))
    fi
    sleep 5s
  done
  wait

  while [ -e "$TMP/loop.${loop}.done" ]; do
    echo "[$(datetime_now)] Online stage out: Loop # $loop"
    bash $SCRP_DIR/src/stage_out.sh a $loop
    loop=$((loop+1))
  done

fi

#===============================================================================
# Stage out

echo "[$(datetime_now)] Finalization (stage out)"

if ((ONLINE_STGOUT != 1)); then
  bash $SCRP_DIR/src/stage_out.sh a
fi

###### To do: also online staging...
mkdir -p $LOGDIR
cp -f $TMP/log/${myname1}_*.log $LOGDIR
if [ -f "$TMP/log/${myname1}.err" ]; then
  cat $TMP/log/${myname1}.err >> $LOGDIR/${myname1}.err
fi

#safe_rm_tmpdir $TMP

#===============================================================================

echo "[$(datetime_now)] Finish $(basename $0) $@"

exit 0
