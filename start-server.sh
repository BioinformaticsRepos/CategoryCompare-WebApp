#!/bin/bash
# Start the rails server, which hosts the web app.
rails server &

# Start the R server, which the rails server communicates with.
# Load the CCWebApp.conf file, which loads libraries used by all connections to the R server.
R CMD Rserve --RS-source ~/Desktop/CategoryCompare-WebApp/rserve-config/CCWebApp.conf
