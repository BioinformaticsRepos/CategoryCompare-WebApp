sudo kill $(ps ax | grep "[n]ginx.*passenger" | awk '{ print $1; }')
