
create user apollo_prop identified by apollo;
grant connect to apollo_prop;
grant dba to apollo_prop;


CREATE TABLESPACE LOGMINER_TBS DATAFILE '/u01/app/oracle/oradata/XE/logminer_tbs.dbf' SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

CREATE USER c##dbzuser IDENTIFIED BY dbz DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS;
CREATE USER c##logminer IDENTIFIED BY dbz DEFAULT TABLESPACE LOGMINER_TBS QUOTA UNLIMITED ON LOGMINER_TBS;
GRANT CREATE SESSION TO c##dbzuser ;
GRANT CREATE SESSION TO c##logminer;

grant select on v_$database to c##dbzuser;
GRANT FLASHBACK ANY TABLE TO c##dbzuser ;
GRANT SELECT ANY TABLE TO c##dbzuser ;
GRANT SELECT_CATALOG_ROLE TO c##dbzuser ;
GRANT EXECUTE_CATALOG_ROLE TO c##dbzuser ;
GRANT SELECT ANY TRANSACTION TO c##dbzuser ;
GRANT SELECT ANY DICTIONARY TO c##dbzuser ;
-- GRANT LOGMINING TO c##dbzuser ;
GRANT CREATE TABLE TO c##dbzuser ;
GRANT ALTER ANY TABLE TO c##dbzuser ;
GRANT LOCK ANY TABLE TO c##dbzuser ;
GRANT CREATE SEQUENCE TO c##dbzuser ;

-- GRANT LOGMINING TO c##logminer


GRANT CREATE SESSION TO c##logminer;
GRANT SELECT ON V_$DATABASE to c##logminer;
GRANT FLASHBACK ANY TABLE TO c##logminer;
GRANT LOCK ANY TABLE TO c##logminer;
GRANT CREATE TABLE TO c##logminer;
GRANT CREATE SEQUENCE TO c##logminer;
GRANT SELECT ON V_$LOG TO c##logminer;

GRANT LOGMINING TO c##logminer;
GRANT EXECUTE ON DBMS_LOGMNR TO c##logminer;
GRANT EXECUTE ON DBMS_LOGMNR_D TO c##logminer;
GRANT SELECT ON V$LOGMNR_LOGS TO c##logminer;
GRANT SELECT ON V$LOGMNR_CONTENTS TO c##logminer;
GRANT SELECT ON V$LOGFILE TO c##logminer;
GRANT SELECT ON V$ARCHIVED_LOG TO c##logminer;
GRANT SELECT ON V$ARCHIVE_DEST_STATUS TO c##logminer;


GRANT INSERT ANY TABLE TO C##LOGMINER; 
GRANT SELECT ANY TABLE TO C##LOGMINER;
GRANT UPDATE ANY TABLE TO C##LOGMINER;
GRANT DELETE ANY TABLE TO C##LOGMINER;


CREATE USER debezium IDENTIFIED BY dbz;
  GRANT CONNECT TO debezium;
  GRANT CREATE SESSION TO debezium;
  GRANT CREATE TABLE TO debezium;
  GRANT CREATE SEQUENCE to debezium;
  ALTER USER debezium QUOTA 100M on users;

-- añadir redos de tamaño adecuado

set pages 100
col status format a8

select a.group#, b.bytes/1024/1024, b.status
from v$logfile a, v$log b
where a.group#=b.group#;


alter database add logfile group 3 size 200M;
alter database add logfile group 4 size 200M;
alter database add logfile group 5 size 200M;
alter database add logfile group 1 size 200M;
alter database add logfile group 2 size 200M;

ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/fast_recovery_area/XE/onlinelog/02_mf_1_j1t4lc5q_.log' to group 1;
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/fast_recovery_area/XE/onlinelog/02_mf_2_j1t4l5f2_.log' to group 2;
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/fast_recovery_area/XE/onlinelog/02_mf_3_j1t13w5g_.log' to group 3;
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/fast_recovery_area/XE/onlinelog/02_mf_4_j1t13wk0_.log' to group 4;
ALTER DATABASE ADD LOGFILE MEMBER '/u01/app/oracle/fast_recovery_area/XE/onlinelog/02_mf_5_j1t13x3f_.log' to group 5;



select a.group#, b.bytes/1024/1024, b.status
from v$logfile a, v$log b
where a.group#=b.group#;


alter system switch logfile;
alter system switch logfile;
alter system switch logfile;
alter system switch logfile;

select a.group#, b.bytes/1024/1024, b.status
from v$logfile a, v$log b
where a.group#=b.group#;

alter system switch logfile;
alter system switch logfile;

alter database drop logfile group 1;
alter database drop logfile group 2;

select a.group#, b.bytes/1024/1024, b.status
from v$logfile a, v$log b
where a.group#=b.group#;
-- activar archive log mode

shutdown immediate;
startup mount
alter database archivelog;
alter database open;
archive log list;

-- activar log miner
ALTER DATABASE ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;
ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED;

set pages 100
col member format a69
col status format a8

select a.group#, b.bytes/1024/1024, b.status
from v$logfile a, v$log b
where a.group#=b.group#;

grant dba to c##logminer;
grant dba to DBEZIUM;
grant DBA to c##dbzuser;

 @$ORACLE_HOME/rdbms/admin/dbmslm.sql
exit;