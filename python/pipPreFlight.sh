#!/bin/bash
#
# Perform checks on all required for installing Python dependencies. The main
# driver will be the requirements.txt file which is used by pip to do the 
# actual installation of the required python packages. For this a number of 
# checks need to be passed to ensure a propper working of the requirment 
# installation. This code will perform the required checks and can be used in 
# a pipeline as a pre-flight check. If the pip pre-flight check fails there is 
# no need to start the build phase of the pipeline and you can already abort 
# the pipeline during the pre-flight instead of running into a error state 
# during the build or deploy phase of the pipeline

sourceDir="null"
preFligt="passed"

#######################################
# function sourceDirPresent checks if the provided source directory is indeed
# present. return true/false 
#######################################
sourceDirPresent () {
  if [ ! -d "$1" ]; then
    echo "false"
  else
    echo "true"
  fi

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



#######################################
# function pipPresent checks if pip is present on the build system. If pip 
# is not present on the build system the build / deploy stage will fail.
# return true if present, return false if not present. 
#######################################
pipPresent () {
  if hash pip 2>/dev/null; then
    echo "true"
  else
    echo "false"
  fi
}



#######################################
# Function ShowhelpText will show a standard help text to the user. Prime use
# will be for cases where wrong arguments are passed to the pre-flight check. 
#######################################
showHelpText () {
  echo "Missing or incorrect commandline option. Use: -s (source directory)"
}



#######################################
# function checkFailed is used to handle the situation where a check has
# not been passed. We will use a function to handle this as this will make
# it more easy to implement this logic in another pipeline system.  
#######################################
checkFailed () {
  echo "Failed $(date +%s) : $1"
  preFlight="failed"
}



#######################################
# function checkPassed us used to handle thesituation where a check has passed
# with succes. We will use a function to handle this as this will make it more
# easy to implement this logic in another pipeline system.
#######################################
checkPassed () {
  echo "Passed $(date +%s) : $1"
}



#######################################
# function preFligtFailed is used to handle the situation where one or more
# checks have failed. If one or more checks failed the entire pre-flight 
# check has failed and we exit with a none-zeroe xit code to indicate that 
# the pre-flight check has failed. 
#######################################
preFlightFailed () {
  checkFailed "pipPreFlight failed on one or more checks"
  exit 1
}



#######################################
# function preFlightPassed is used to handle the situation where all the 
# checks have passed and no failed checks have been detected. If all the
# checks have passed we use an exit code 0 to indicate nothing is wrong. 
#######################################
preFlightPassed () {
  checkPassed "pipPreFlight passed all checks."
  exit 0
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


# check if the provide source directory is present on the build system. The -s
# flag is used to pass the source directpry location to the pipPreflight script.
sourceDirPresentPassed=$(sourceDirPresent $sourceDir)
if [ $sourceDirPresentPassed == "true" ]; then
  checkPassed "check - Source directory found at $sourceDir"
else
  checkFailed "check - Source directory not found at $sourceDir"
fi


# check if requirments.txt is found in the source director. This will be required
# for pip to install the required python packages
requirmentsPresentPassed=$(requirmentsPresent $sourceDir)
if [ $sourceDirPresentPassed == "true" ]; then
  checkPassed "Check - Requirments file found at $sourceDir/requirments.txt"
else
  checkFailed "Check - Requirments file not found at $sourceDir/requirments.txt"
fi


pipPresentPassed=$(pipPresent)
if [ $pipPresentPassed == "true" ]; then
  checkPassed "Check - pip command found at $(which pip)"
else
  checkFailed "Check - pip command not found"
fi
  


if [ "$preFlight" == "failed" ]; then
  preFlightFailed
else
  preFlightPassed
fi
