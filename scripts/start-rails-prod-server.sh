#!/bin/bash

# Make sure we're in the application directory - otherwise
# rails server doesn't work.
cd ~/SourceCode/CategoryCompare-WebApp-Application

# Start the rails server, which hosts the web app.
bundle exec passenger start
