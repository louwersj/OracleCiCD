#!/bin/bash
#
# vulScanSafetyLocalRequirements ensures that the pyupio safety tooling is present on the system 
# and that a scan is done based upon the requirments.txt file. This file can be used as part of a 
# standard pipeline, as part of the bootstrap of a docker container or vm which forms part of a 
# pipeline. The assumption is that this script is part of the bootstrap for a volatile VM or a 
# docker container. Based upon this assumption we will not do updates, we will only do installs
#
# In general the idea is that all actions are automated, required for ensuring the tooling, the 
# latest database are present and a scan is executed against the requirements.txt file
#
# The script requires to be started with "-s /path/to/source" to ensure the script can find the 
# requirements.txt file. The output is always stored as a .json file in the source directort and
# named "epoch"_vulScanSafetyLocalRequirements.json
#
# Ensuring the results are shared / exported / handeld are to be handeld outside of this script.  


##########################################################
# CHANGE-LOG
#
# DATE         NAME                  REASON
# 06-APR-2019  johan Louwers         added pip update due to strange "issue" at some pipelines
#
#
##########################################################



sourceDir="null"



##########################################################
# Ensure that the safety tooling is present on the system.
#########################################################  
ensureSafetyPresent () {
  pip install safety > /dev/null 2>&1
  pip install --upgrade safety > /dev/null 2>&1
}



##########################################################
# ensure that the safety-db is (explictly) present on the system
##########################################################
ensureSafetyDbPresent () {
  pip install safety-db > /dev/null 2>&1
  pip install --upgrade safety-db > /dev/null 2>&1
}



#######################################
# Function ShowhelpText will show a standard help text to the user. Prime use
# will be for cases where wrong arguments are passed to the pre-flight check. 
#######################################
showHelpText () {
  echo "Missing or incorrect commandline option. Use: -s (source directory)"
}



#######################################
# function requirmentsPresent checks if requirements.txt is present. if the
# requirements.txt is present true will be returned, if not rturn false 
#######################################
requirmentsPresent () {
  if [ ! -f $1/requirements.txt ]; then
    echo "false"
  else
   echo "true"
  fi
}



# run a getopts check to see if -s is provided with a value, in this case
# value needs to be path to the source directory. We will later check if the 
# provided path exists. Here we will only check if the value is provided and
# we will not check if the value is correct. 
sourceDirFlag=0
while getopts ":s:" opt; do
  case $opt in
    s)
      sourceDir=$OPTARG
      sourceDirFlag=1
      ;;
    \?)
      showHelpText
      exit 1
      ;;
    :)
      showHelpText
      exit 1
      ;;
  esac
done
if [ "$sourceDirFlag" -eq "0" ]; then
  showHelpText
   exit 1;
fi

# check if requirments.txt is found in the source director. If not, there
# is no need to continue and we cancel the rest of the actions. 
requirmentsPresentPassed=$(requirmentsPresent $sourceDir)
if [ $requirmentsPresentPassed == "true" ]; then
  ensureSafetyPresent
  ensureSafetyDbPresent

  if hash safety 2>/dev/null; then
    safety check -r $sourceDir/requirements.txt --json --output $sourceDir/$(date +%s)__vulScanSafetyLocalRequirements.json
  else
    echo "Failed $(date +%s) : safety not found on the system."
    exit 1;
  fi

else
  echo "Failed $(date +%s) : no requirements.txt file found at $sourceDir/requirments.txt"
  exit 1;
fi
