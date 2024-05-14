#!/bin/sh


# Usage: ./run-script-sql.sh script query


echo "$(date) $0 $@" >> run-script.log

psql -d researchdata_test -c "SELECT signature FROM complexes WHERE $2" | grep '^ g' | sed 's/ //g' | parallel --progress ./time-wrapper.pl $1 {} '2>/dev/null'
