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

## passed and failed checks
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

## usign none-zero exit code
You can use the none-zero exit code to indicate that pipPreFlight failed and that your stage (or the entire pipeline) should be marked as failed. 
