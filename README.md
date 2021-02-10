
##
Los ficheros del instan_client están subidos comprimidos. Hay que descomprimirlos para poder tener la funcionalidad completa: 

## Arrancar imagenes

docker-compose -f docker-compose.yaml up --build

## sacar ip asignada a la imagen de oracle
docker network ls --> listado de redes creadas

docker network inspect -f '{{json .Containers}}' debezium_apollo_last_default | jq '.[] | .Name + ":" + .IPv4Address' 


## Start Oracle Connector

curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-oracle.json

## 
docker-compose -f docker-compose.yaml exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic dbz_oracle.APOLLO_PROP.PACKAGETYPE
## Ver topics creados (dentro de la imagen de kafka)
docker exec -it kafka /bin/bash

kafka-topics.sh --bootstrap-server kafka:9092 --list
##  Entrar en la imagen de oracle y hacer los inserts
docker exec -it dbz_oracle /bin/bash


insert into packagetype values (1001, 'Elena 1', sysdate);
insert into apollo_prop.packagetype values (1002, 'Elena 2', sysdate);
insert into apollo_prop.packagetype values (1003, 'Elena 3', sysdate);
ex
insert into apollo_prop.packagetype values (1005, 'Elena 5', sysdate);
insert into apollo_prop.packagetype values (1006, 'Elena 6', sysdate);
insert into apollo_prop.packagetype values (1007, 'Elena 7', sysdate); @ORACLE_HOME/rdbms/admin/dbmslm.sql
insert into apollo_prop.packagetype values (1008, 'Elena 8', sysdate);


CREATE TABLESPACE xstream_adm_tbs DATAFILE '/u01/app/oracle/oradata/XE/xstream_adm_tbs.dbf'
  SIZE 25M REUSE AUTOEXTEND ON MAXSIZE UNLIMITED;

## MANAGE CONNECTOR (REST_API)

### debugmode

  curl -s "http://localhost:8083/connectors?expand=info&expand=status"
  jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
  column -s : -t| sed 's/\"//g'|sort


### STATUS

 curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort

curl http://localhost:8083/connectors/apollo_logmnr-connector | jq


### RESTART
 curl -i -X POST  http://localhost:8083/connectors/apollo_logmnr-connector/restart

### STOP
curl -i -X DELETE  http://localhost:8083/connectors/apollo_logmnr-connector

 select grantee, granted_role
from dba_role_privs
where granted_role='DBA'





