#!/bin/bash
# Start the rails server, which hosts the web app.
rails server &

# Start the R server, which the rails server communicates with.
R CMD Rserve
