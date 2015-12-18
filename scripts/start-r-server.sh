#!/bin/bash

cd /home/daniel/Desktop/CategoryCompare-WebApp

# Start the R server, which the rails server communicates with.
# Load the CCWebApp.conf file, which loads libraries used by all connections to the R server.
R CMD Rserve --RS-source /home/daniel/Desktop/CategoryCompare-WebApp/rserve-config/CCWebApp.conf --no-save

return 0
