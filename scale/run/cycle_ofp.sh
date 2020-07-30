#!/bin/bash
#===============================================================================
#
#  Wrap cycle.sh in an OFP job script and run it.
#
#-------------------------------------------------------------------------------
#
#  Usage:
#    cycle_ofp.sh [..]
#
#===============================================================================

cd "$(dirname "$0")"
myname="$(basename "$0")"
job='cycle'

RSCGRP=${RSCGRP:-"regular-flat"}
GNAME=${GNAME:-`id -ng`}

#===============================================================================
# Configuration

. config.main || exit $?
. config.${job} || exit $?

. src/func_distribute.sh || exit $?
. src/func_datetime.sh || exit $?
. src/func_util.sh || exit $?
. src/func_${job}.sh || exit $?

#-------------------------------------------------------------------------------

echo "[$(datetime_now)] Start $myname $@"

setting "$@" || exit $?

if [ "$CONF_MODE" = 'static' ]; then
  . src/func_common_static.sh || exit $?
  . src/func_${job}_static.sh || exit $?
fi

echo
print_setting || exit $?
echo

#===============================================================================
# Create and clean the temporary directory

echo "[$(datetime_now)] Create and clean the temporary directory"

#if [ -e "${TMP}" ]; then
#  echo "[Error] $0: \$TMP will be completely removed." >&2
#  echo "        \$TMP = '$TMP'" >&2
#  exit 1
#fi
safe_init_tmpdir $TMP || exit $?

#===============================================================================
# Determine the distibution schemes

echo "[$(datetime_now)] Determine the distibution schemes"

declare -a node_m
declare -a name_m
declare -a mem2node
declare -a mem2proc
declare -a proc2node
declare -a proc2group
declare -a proc2grpproc

safe_init_tmpdir $NODEFILE_DIR || exit $?
#distribute_da_cycle - $NODEFILE_DIR || exit $?
distribute_da_cycle - - || exit $? # Do not use distr

#===============================================================================
# Determine the staging list

echo "[$(datetime_now)] Determine the staging list"

cat $SCRP_DIR/config.main | \
    sed -e "/\(^DIR=\| DIR=\)/c DIR=\"$DIR\"" \
    > $TMP/config.main

echo "SCRP_DIR=\"\$TMPROOT\"" >> $TMP/config.main
echo "RUN_LEVEL=4" >> $TMP/config.main

echo "PARENT_REF_TIME=$PARENT_REF_TIME" >> $TMP/config.main

safe_init_tmpdir $STAGING_DIR || exit $?
if [ "$CONF_MODE" = 'static' ]; then
  staging_list_static || exit $?
  config_file_list $TMPS/config || exit $?
else
  echo "Error: CONF_MODE should be static!"
  exit
  staging_list || exit $?
fi

#-------------------------------------------------------------------------------
# Add shell scripts and node distribution files into the staging list

cat >> ${STAGING_DIR}/${STGINLIST} << EOF
${SCRP_DIR}/config.rc|config.rc
${SCRP_DIR}/config.${job}|config.${job}
${SCRP_DIR}/${job}.sh|${job}.sh
${SCRP_DIR}/src/|src/
EOF

if [ "$CONF_MODE" != 'static' ]; then
  echo "${SCRP_DIR}/${job}_step.sh|${job}_step.sh" >> ${STAGING_DIR}/${STGINLIST}
fi

#===============================================================================
# Stage in

echo "[$(datetime_now)] Initialization (stage in)"

stage_in server || exit $?

#===============================================================================
# Creat a job script

NPIN=`expr 255 / \( $PPN \) + 1`
jobscrp="$TMP/${job}_job.sh"

echo "[$(datetime_now)] Create a job script '$jobscrp'"

if [ "$RSCGRP" == "" ] ; then
  RSCGRP="regular-cache"
fi


cat > $jobscrp << EOF
#!/bin/sh
#PJM -L rscgrp=${RSCGRP}
#PJM -L node=${NNODES}
#PJM -L elapse=${TIME_LIMIT}
#PJM --mpi proc=$((NNODES*PPN))
##PJM --mpi proc=${totalnp}
#PJM --omp thread=${THREADS}

#PJM -g ${GNAME}

#PJM -s

module unload impi
module unload intel
module load intel/2019.5.281

source /work/opt/local/cores/intel/performance_snapshots_2019.6.0.602217/apsvars.sh
export MPS_STAT_LEVEL=4
 
module load hdf5/1.10.5
module load netcdf/4.7.0
module load netcdf-fortran/4.4.5

export FORT_FMT_RECL=400

export HFI_NO_CPUAFFINITY=1
export I_MPI_PIN_PROCESSOR_EXCLUDE_LIST=0,1,68,69,136,137,204,205
export I_MPI_HBW_POLICY=hbw_preferred,,
export I_MPI_FABRICS_LIST=tmi
unset KMP_AFFINITY
#export KMP_AFFINITY=verbose
#export I_MPI_DEBUG=5

export OMP_NUM_THREADS=1
export I_MPI_PIN_DOMAIN=${NPIN}
export I_MPI_PERHOST=${PPN}
export KMP_HW_SUBSET=1t

export PSM2_CONNECT_WARN_INTERVAL=2400
export TMI_PSM2_CONNECT_TIMEOUT=2000


#export OMP_STACKSIZE=128m
ulimit -s unlimited


export JITCLIENT_LOGFILE="jitclient-log.txt"

umask 0007

./${job}.sh "$STIME" "$ETIME" "$ISTEP" "$FSTEP" "$CONF_MODE" || exit \$?
EOF

#===============================================================================
# Run the job

echo "[$(datetime_now)] Run ${job} job on PJM"
echo

job_submit_PJM $jobscrp
echo

job_end_check_PJM $jobid
res=$?

#===============================================================================
# Stage out

echo "[$(datetime_now)] Finalization (stage out)"

stage_out server || exit $?

#if ((DACYCLE_RUN_FCST == 1)); then
#  echo
#  echo "[$(datetime_now)] Start: store images"
#
#  for z in `seq 0 10`; do
#    ZLEV="z"$(printf %02d $z)
#    find ${TMP}/[a,f,o]*_${ZLEV}[0-9][0-9][0-9]m_*.png -type f | xargs mv -t ${OUTDIR}/${STIME}/dafcst/ > /dev/null
#
#    cd ${OUTDIR}/dafcst
#    tar -zcf anal_${ZLEV}000m.tar.gz anal_*.png > /dev/null 
#    tar -zcf fcst_${ZLEV}000m.tar.gz fcst_*.png > /dev/null 
#    tar -zcf obs_${ZLEV}000m.tar.gz obs_*.png > /dev/null 
#
#    find [a,o,f]*_${ZLEV}[0-9][0-9][0-9]m_*.png -type f | xargs rm -f  > /dev/null
#
#    cd - > /dev/null
#  done
#
#  #mkdir -p ${TMP}/png
#  #mv ${TMP}/*.png ${TMP}/png/
#  echo "[$(datetime_now)] End: store images"
#fi

#===============================================================================
# Finalization

echo "[$(datetime_now)] Finalization"
echo

if ((OBS_USE_JITDT == 1)) ; then
  if ((OBS_USE_JITDT_OFFLINE == 1)) ; then
    echo "Stop JIT-DT Offline!"
    ${SCRP_DIR}/src/jitdt-lwatch-offline stop
  elif ((OBS_USE_JITDT_OFFLINE == 0)) ; then
    echo "Stop JIT-DT Online!"
    ${SCRP_DIR}/src/jit-lwatch stop
  fi
fi


backup_exp_setting $job $TMP $jobid ${job}_job.sh 'o e'

if [ "$CONF_MODE" = 'static' ]; then
  config_file_save $TMPS/config || exit $?
fi

archive_log

#if ((CLEAR_TMP == 1)); then
#  safe_rm_tmpdir $TMP
#fi

#===============================================================================

[ "`tail -n 1 ${jobscrp}.e${jobid} | cut -c 23-28`" == 'Finish' ] && result=0 || result=1

echo "result" `tail -n 1 ${jobscrp}.e${jobid} | cut -c 23-28` 

mv $TMP ${TMP}_$STIME

echo "[$(datetime_now)] Finish $myname $@"

exit $result
