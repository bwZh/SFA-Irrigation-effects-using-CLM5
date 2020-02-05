#!/bin/sh 
# Script to create a 1km watershed case, using clm5 in constance.
# Different grids between atm and land, with landuse timeseries map.
# Bowen Zhu, 01/14/2019


# Module load
module load intel
module load ncl
module load netcdf
module load mvapich2/2.1
module load python

# Set path
export CCSMUSER=zhub210
export BASE_DIR=/pic/projects/landuq/${CCSMUSER}
export CESM_CASE_DIR=${BASE_DIR}/cases
export CESM_SRC_DIR=/people/${CCSMUSER}/clm5.0
export INPUTDATA_DIR=${BASE_DIR}/IM3_CLM5/inputdata
export CESM_INPUTDATA_DIR=${INPUTDATA_DIR}/cesm_inputdata
export ARCHIVE_DIR=/pic/scratch/${CCSMUSER}/cesm_archive
export CIME_OUTPUT_ROOT=/pic/scratch/${CCSMUSER}/csmruns

# This I1PtClm50SpGs compset needs 17 PFT types
# I1850Clm50Bgc, I2000Clm50Cn, I2000Clm50Fates, I1850Clm50BgcCrop, I1PtClm50SpGs, I1850Clm50BgcSpinup, I2000Clm40SpCruGs, ADSOM, I2000Clm50Vic
# I1850Clm45BgcGs: 1850_DATM%GSWP3v1_CLM45%BGC_SICE_SOCN_RTM_SGLC_SWAV
export CESM_COMPSET=I2000Clm50SpGs
export CLM_USRDAT_NAME=1kmx1km_UCPR
export ATM_NAME=hanford_00625x00625
export DOMAINFILE_CYYYYMMDD=c190605
export SURFFILE_CYYYYMMDD=c190605
export SIMYR=2010
export CESM_CASE_NAME=${CLM_USRDAT_NAME}-${CESM_COMPSET}-UCPR-RCP45Nfixed-`date "+%Y-%m-%d"`

# delete the old casedir/rundir
rm -rf ${CESM_CASE_DIR}/${CESM_CASE_NAME}
rm -rf ${CIME_OUTPUT_ROOT}/${CESM_CASE_NAME}

# copy the machine files 
cp -f user_machines/config_machines_constance.xml ${CESM_SRC_DIR}/cime/config/cesm/machines/config_machines.xml
cp -f user_machines/config_batch_constance.xml ${CESM_SRC_DIR}/cime/config/cesm/machines/config_batch.xml

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Create soft links for CESM inputdata
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Link forcing data file
mkdir -p ${CESM_INPUTDATA_DIR}/atm/datm7/${CLM_USRDAT_NAME}/CLM1PT_data
rm -f ${CESM_INPUTDATA_DIR}/atm/datm7/${CLM_USRDAT_NAME}/CLM1PT_data/*.nc
#ls -l ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/clmforc/*.nc | awk '{ print $9}' | awk -F'.' '{print $3}' | \
#awk -v INPUTDATA_DIR=${INPUTDATA_DIR} -v CLM_USRDAT_NAME=${CLM_USRDAT_NAME} \
#'{ system( "ln -s " INPUTDATA_DIR "/user_inputdata/" CLM_USRDAT_NAME "/clmforc/clmforc.hanford." $1 ".nc " INPUTDATA_DIR"/cesm_inputdata/atm/datm7/" CLM_USRDAT_NAME "/CLM1PT_data/" $1 ".nc") }'


# Link the RCP4.5 and RCP8.5 forcing data
ls -l /pic/projects/landuq/liuy716/liuy716_constance_sbr_task1/clmforc_hanford_PRIMA_rcp45_0.0625_20191125/*.nc | awk '{ print $9}' | awk -F'.' '{print $4}' | \
awk -v INPUTDATA_DIR=${INPUTDATA_DIR} -v CLM_USRDAT_NAME=${CLM_USRDAT_NAME} \
'{ system( "ln -s /pic/projects/landuq/liuy716/liuy716_constance_sbr_task1/clmforc_hanford_PRIMA_rcp45_0.0625_20191125/clmforc.hanford." $1 ".nc " INPUTDATA_DIR"/cesm_inputdata/atm/datm7/" CLM_USRDAT_NAME "/CLM1PT_data/" $1 ".nc") }'


# Link land domain data file
rm -f ${CESM_INPUTDATA_DIR}/share/domains/domain.lnd.${CLM_USRDAT_NAME}_navy.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/domain.lnd.${CLM_USRDAT_NAME}_${DOMAINFILE_CYYYYMMDD}.nc ${CESM_INPUTDATA_DIR}/share/domains/domain.lnd.${CLM_USRDAT_NAME}_navy.nc

# link atm domain data file
rm -f ${CESM_INPUTDATA_DIR}/share/domains/domain.atm.${ATM_NAME}_navy.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/domain.atm.${ATM_NAME}_${DOMAINFILE_CYYYYMMDD}.nc ${CESM_INPUTDATA_DIR}/share/domains/domain.atm.${ATM_NAME}_navy.nc

# Link surface data file
mkdir -p ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map
rm -f ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
rm -f ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/landuse.timeseries_UCPR.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/surfdata.${CLM_USRDAT_NAME}_wwfertilizer_${SURFFILE_CYYYYMMDD}.nc ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
ln -s ${INPUTDATA_DIR}/user_inputdata/${CLM_USRDAT_NAME}/landuse.timeseries_UCPR.nc ${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/landuse.timeseries_UCPR.nc
 

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Now do the CLM stuff
# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

cd ${CESM_SRC_DIR}/cime/scripts
./create_newcase --case ${CESM_CASE_DIR}/${CESM_CASE_NAME} --res CLM_USRDAT --compset ${CESM_COMPSET} --mach constance --run-unsupported

# Configuring case :
cd ${CESM_CASE_DIR}/${CESM_CASE_NAME}

# Modifying : env_batch.xml, if debugging
./xmlchange  --file env_batch.xml --id JOB_QUEUE --val "slurm" --force

# Modifying : env_mach_pes.xml
./xmlchange  --file env_mach_pes.xml --id NTASKS_LND --val 250

# Modifying : env_build.xml
./xmlchange  --file env_build.xml --id CIME_OUTPUT_ROOT --val ${CIME_OUTPUT_ROOT}
#./xmlchange  --file env_build.xml --id ATM_NX --val 87
#./xmlchange  --file env_build.xml --id ATM_NY --val 71
#./xmlchange  --file env_build.xml --id LND_NX --val 3600
#./xmlchange  --file env_build.xml --id LND_NY --val 1

# Modifying : env_run.xml
./xmlchange --file env_run.xml --id CLM_BLDNML_OPTS --val "-bgc bgc -crop" 
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val 2100
./xmlchange --file env_run.xml --id DATM_MODE --val CLM1PT
./xmlchange --file env_run.xml --id ATM_DOMAIN_FILE --val domain.atm.${ATM_NAME}_navy.nc
./xmlchange --file env_run.xml --id LND_DOMAIN_FILE --val domain.lnd.${CLM_USRDAT_NAME}_navy.nc
#./xmlchange --file env_run.xml --id ATM2LND_FMAPNAME --val cpl/gridmaps/${CLM_USRDAT_NAME}/map_atm_TO_1km_aave.190103.nc
#./xmlchange --file env_run.xml --id ATM2LND_SMAPNAME --val cpl/gridmaps/${CLM_USRDAT_NAME}/map_atm_TO_1km_aave.190103.nc
#./xmlchange --file env_run.xml --id LND2ATM_FMAPNAME --val cpl/gridmaps/${CLM_USRDAT_NAME}/map_1km_TO_atm_aave.190122.nc
#./xmlchange --file env_run.xml --id LND2ATM_SMAPNAME --val cpl/gridmaps/${CLM_USRDAT_NAME}/map_1km_TO_atm_aave.190122.nc
./xmlchange --file env_run.xml --id STOP_N --val 86
./xmlchange --file env_run.xml --id REST_N --val 1
./xmlchange --file env_run.xml --id RUN_STARTDATE --val 2015-01-01
./xmlchange --file env_run.xml --id STOP_OPTION --val nyears
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 2015
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_ALIGN --val 2015
./xmlchange --file env_run.xml --id DIN_LOC_ROOT --val ${CESM_INPUTDATA_DIR}
./xmlchange --file env_run.xml --id DIN_LOC_ROOT_CLMFORC --val "\$DIN_LOC_ROOT/atm/datm7"
./xmlchange --file env_run.xml --id CLM_USRDAT_NAME --val ${CLM_USRDAT_NAME}
./xmlchange --file env_run.xml --id CLM_FORCE_COLDSTART --val off
./xmlchange --file env_run.xml --id DOUT_S_ROOT --val ${ARCHIVE_DIR}/${CESM_CASE_NAME}
./xmlchange CLM_NML_USE_CASE=20thC_transient

./xmlchange CCSM_BGC=CO2A
./xmlchange CLM_CO2_TYPE=diagnostic
./xmlchange DATM_CO2_TSERIES=rcp4.5

# Modifying the TIME LIMIT
./xmlchange JOB_WALLCLOCK_TIME=45:00:00

./case.setup

# Modify user_nl_clm
export paramfile=${CESM_INPUTDATA_DIR}/lnd/clm2/paramdata/clm5_params_calibration3_wwrainfed_UCPRvcmax.c171117.nc
export fsurdat=${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/surfdata.${CLM_USRDAT_NAME}_simyr${SIMYR}.nc
export flanduse_timeseries=${CESM_INPUTDATA_DIR}/lnd/clm2/surfdata_map/landuse.timeseries_UCPRfuture.nc
export finidat=/pic/scratch/zhub210/csmruns/1kmx1km_UCPR-I2000Clm50SpGs-UCPR-historical-2019-12-26/run/1kmx1km_UCPR-I2000Clm50SpGs-UCPR-historical-2019-12-26.clm2.r.2015-01-01-00000.nc


cat >> user_nl_clm << EOF
fsurdat = '$fsurdat'
finidat = '$finidat'
paramfile = '$paramfile'
use_init_interp = .true.
flanduse_timeseries = '$flanduse_timeseries'
model_year_align_ndep = 2015
stream_year_first_ndep = 2015
stream_year_last_ndep = 2015
ndep_taxmode = 'cycle'
EOF


# Modify user_nl_datm
cat >> user_nl_datm << EOF
domainfile="/pic/projects/landuq/zhub210/IM3_CLM5/inputdata/cesm_inputdata/share/domains/domain.lnd.1kmx1km_UCPR_navy.nc"   
taxmode = 'cycle', 'cycle', 'cycle', 'extend'
streams = "datm.streams.txt.CLM1PT.CLM_USRDAT 2015 2015 2100",
     "datm.streams.txt.presaero.clim_2000 1 1 1",
     "datm.streams.txt.topo.observed 1 1 1",
     "datm.streams.txt.co2tseries.rcp4.5 2015 2015 2100"
EOF



# Configuring case :
cd ${CESM_CASE_DIR}/${CESM_CASE_NAME}
./case.build
echo ''
echo 'case build finished'
echo ''

# Modify datm streams
cp -f ${CESM_CASE_DIR}/${CESM_CASE_NAME}/CaseDocs/datm.streams.txt.co2tseries.rcp4.5 ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.co2tseries.rcp4.5
chmod +rw ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.co2tseries.rcp4.5

cp -f ${CESM_CASE_DIR}/${CESM_CASE_NAME}/CaseDocs/datm.streams.txt.CLM1PT.CLM_USRDAT ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
chmod +rw ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
perl -w -i -p -e 's@QBOT     shum@RH       rh@' ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT
sed -i '/ZBOT/d' ${CESM_CASE_DIR}/${CESM_CASE_NAME}/user_datm.streams.txt.CLM1PT.CLM_USRDAT

# Running case :
#./case.submit
#echo ''
#echo 'case submitted'
#echo ''
