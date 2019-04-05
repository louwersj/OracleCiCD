# pipPreFlight
pipPreFlight provides a number of checks that can be used in a deployment pipeline to check pip and requirements.txt availability. pipPreFlight will do the following checks:

- check if pip is available on the system
- check if the source directory is available
- check if the source directory contains a file named requirements.txt

You can use pip to install all mentioned requirements from requirements.txt and it is a good practice to enure your source code distribution contains in all cases a requirements.txt file in the root of the source code directory.

## running pipPreFlight
pipPreFlight.sh is a bash script tested on Oracle Linux 7. Starting / calling pipPreFlight.sh can be done as shown below from the Linux commandline

```
./pipPreFlight.sh -s /some/path/to/sourcecode
```

## Passed and failed checks
The checks performed by pipPreFlight are all reported as shown in the examples below.

Example of all checks passed. In this situation the script will have an zero exit code. 
```
Passed 1554458943 : check - Source directory found at /tmp/pipPreFlight/source
Passed 1554458943 : Check - Requirments file found at /tmp/pipPreFlight/source/requirments.txt
Passed 1554458943 : Check - pip command found at /usr/bin/pip
Passed 1554458943 : pipPreFlight passed all checks.
```

in case on ore more checks fail this is also shown in the output and the script will have a none-zero exit code. 
```
Failed 1554458935 : check - Source directory not found at /tmp/pipPreFlight/sourc
Failed 1554458935 : Check - Requirments file not found at /tmp/pipPreFlight/sourc/requirments.txt
Passed 1554458935 : Check - pip command found at /usr/bin/pip
Failed 1554458935 : pipPreFlight failed on one or more checks
```

## making changes
The below section provides some pointers to making changes to the logic to make this more integrated in your own specific pipeline.

### changing failed check handling
In case you do want to handle failed checks in a different manner you can change the below mentioned function to include your own logic. Do note that the value of the preFlight variable is set to failed and that this is used in the logic for calling the preFligtFailed function or the preFlightPassed function. 
```
#######################################
# function checkFailed is used to handle the situation where a check has
# not been passed. We will use a function to handle this as this will make
# it more easy to implement this logic in another pipeline system.  
#######################################
checkFailed () {
  echo "Failed $(date +%s) : $1"
  preFlight="failed"
}
```

### changing passed check handling
In case you do want to handle passed checks in a different manner you can change the below mentioned function to include your own logic:
```
#######################################
# function checkPassed us used to handle thesituation where a check has passed
# with succes. We will use a function to handle this as this will make it more
# easy to implement this logic in another pipeline system.
#######################################
checkPassed () {
  echo "Passed $(date +%s) : $1"
}
```

### Using none-zero exit code
You can use the none-zero exit code to indicate that pipPreFlight failed and that your stage (or the entire pipeline) should be marked as failed. The function preFlightFailed is used to handle the situation in which one or more checks failed. In cases where you need to change the way this is handeld you can edit the preFlightFailed function. 
```
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
```
