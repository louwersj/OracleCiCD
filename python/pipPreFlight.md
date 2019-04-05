# pipPreFlight
pipPreFlight provides a number of checks that can be used in a deployment pipeline to check pip and requirements.txt availability. pipPreFlight will do the following checks:

- check if pip is available on the system
- check if the source directory is available
- check if the source directory contains a file named requirements.txt

You can use pip to install all mentioned requirements from requirements.txt and it is a good practice to enure your source code distribution contains in all cases a requirements.txt file in the root of the source code directory.
