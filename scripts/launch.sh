##Creating Users
echo "Entering Launch"
$ORACLE_HOME/bin/sqlplus sys/oracle as sysdba @/app/setup_database.sql

## Importing apollo_prop tables
echo "Importing APOLLO_PROP tables"
$ORACLE_HOME/bin/imp apollo_prop/apollo constraints=N grants=N indexes=N full=Y file=/app/exp_apollo.dmp 

echo "Change apollo_prop table logging"
$ORACLE_HOME/bin/sqlplus sys/oracle as sysdba @/app/apollo_prop_logging.sql