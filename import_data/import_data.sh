#!/bin/bash
echo "Importing APOLLO_PROP tables"
$ORACLE_HOME/bin/imp apollo_prop/apollo constraints=N grants=N indexes=N full=Y file=/app/expdat.dmp 