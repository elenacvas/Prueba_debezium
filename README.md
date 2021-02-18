# Steps to Deploy Debezium with docker images.

# 1)  Docker-Compose

- Prerequisite:  Oracle Instant Client. 

some files are compressed. Have to decompress after download
```
gzip -x 
```

1.  Launch Docker Images

```
docker-compose -f docker-compose.yaml up --build
```

2. Get assigned IP 
```
docker network ls --> network list

docker network inspect -f '{{json .Containers}}' debezium_apollo_last_default | jq '.[] | .Name + ":" + .IPv4Address' 

```
3.  Start Debezium Oracle Connector
```
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-oracle.json
```
### STOP Debezium Connector
```
curl -i -X DELETE  http://localhost:8083/connectors/apollo_logmnr-connector
```
## Launch Topic "listener"
```
docker-compose -f docker-compose.yaml exec kafka /kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic dbz_oracle.APOLLO_PROP.PACKAGETYPE
```
## List Created topics (inside kafka container)
```
docker exec -it kafka /kafka/bin/kafka-topics.sh --bootstrap-server kafka:9092 --list
```
## Check if topics have healthy leader 
```
docker exec -it kafka /kafka/bin/kafka-topics.sh --describe --zookeeper zookeeper --topic dbz_oracle.APOLLO_PROP.PACKAGETYPE
```
##  Connect to database and launch inserts
```
docker exec -it dbz_oracle /bin/bash


insert into packagetype values (1001, 'Elena 1', sysdate);
insert into apollo_prop.packagetype values (1002, 'Elena 2', sysdate);
insert into apollo_prop.packagetype values (1003, 'Elena 3', sysdate);
insert into apollo_prop.packagetype values (1005, 'Elena 5', sysdate);
insert into apollo_prop.packagetype values (1006, 'Elena 6', sysdate);
insert into apollo_prop.packagetype values (1007, 'Elena 7', sysdate); @ORACLE_HOME/rdbms/admin/dbmslm.sql
insert into apollo_prop.packagetype values (1008, 'Elena 8', sysdate);
alter table apollo_prop.packagetype add birthdate date;
alter table apollo_prop.packagetype drop column birthdate;
```

## MANAGE CONNECTOR (REST_API)

### "Debug" Mode
```
  curl -s "http://localhost:8083/connectors?expand=info&expand=status"
  jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
  column -s : -t| sed 's/\"//g'|sort
```

### Status
```
 curl -s "http://localhost:8083/connectors?expand=info&expand=status" | \
       jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state,.value.status.tasks[].state,.value.info.config."connector.class"]|join(":|:")' | \
       column -s : -t| sed 's/\"//g'| sort

curl http://localhost:8083/connectors/apollo_logmnr-connector | jq
```

### Restart
```
 curl -i -X POST  http://localhost:8083/connectors/apollo_logmnr-connector/restart
```
### Stop
```
curl -i -X DELETE  http://localhost:8083/connectors/apollo_logmnr-connector
```
 select grantee, granted_role
from dba_role_privs
where granted_role='DBA'


# DEPLOY WITH DOCKER

## 1) Starting Zookeeper   
ZooKeeper is the first service you must start.
Procedure
Open a terminal and use it to start ZooKeeper in a container.
This command runs a new container using version 1.4 of the debezium/zookeeper image:
```
$ docker run -it --rm --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper:1.4
```

Verify that ZooKeeper started and is listening on port 2181.
You should see output similar to the following:
```
Starting up in standalone mode
ZooKeeper JMX enabled by default
Using config: /zookeeper/conf/zoo.cfg
2017-09-21 07:15:55,417 - INFO  [main:QuorumPeerConfig@134] - Reading configuration from: /zookeeper/conf/zoo.cfg
2017-09-21 07:15:55,419 - INFO  [main:DatadirCleanupManager@78] - autopurge.snapRetainCount set to 3
2017-09-21 07:15:55,419 - INFO  [main:DatadirCleanupManager@79] - autopurge.purgeInterval set to 1
...
port 0.0.0.0/0.0.0.0:2181 
``` 
This line indicates that ZooKeeper is ready and listening on port 2181. The terminal will continue to show additional output as ZooKeeper generates it.

## 2) Starting Kafka
After starting ZooKeeper, you can start Kafka in a new container.

Open a new terminal and use it to start Kafka in a container.
This command runs a new container using version 1.4 of the debezium/kafka image:
```
$ docker run -it --rm --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka:1.4
```

Verify that Kafka started.
You should see output similar to the following:
```
...
2017-09-21 07:16:59,085 - INFO  [main-EventThread:ZkClient@713] - zookeeper state changed (SyncConnected)
2017-09-21 07:16:59,218 - INFO  [main:Logging$class@70] - Cluster ID = LPtcBFxzRvOzDSXhc6AamA
...
2017-09-21 07:16:59,649 - INFO  [main:Logging$class@70] - [Kafka Server 1], started  
```
The Kafka broker has successfully started and is ready for client connections. The terminal will continue to show additional output as Kafka generates it.

## 3) Start an Oracle Database
```
docker run -it --rm --name dbz_oracle -p 1521:1521 -p 5500:5500 -e GROUP_ID=1 -e ORACLE_ALLOW_REMOTE=YES -e RACLE_HOME=/u01/app/oracle/product/11.2.0/xe   -v /Users/elena.cuevas/workspaces/docker/debezium_apollo_last:/app -v /Users/elena.cuevas/workspaces/docker/debezium_apollo_last/scripts:/docker-entrypoint-initdb.d oracleinanutshell/oracle-xe-11g:latest
```
## 4) Starting Kafka Connect
After starting Oracle DB, you start the Kafka Connect service. This service exposes a REST API to manage the Debezium Oracle connector.
Procedure
Open a new terminal, and use it to start the Kafka Connect service in a container.
This command runs a new container using the 1.4 version of the debezium/connect image:
```
$ docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link dbz_oracle:dbz_oracle debezium/connect:1.4
```

Verify that Kafka Connect started and is ready to accept connections.
You should see output similar to the following:
```
...
2020-02-06 15:48:33,939 INFO   ||  Kafka version: 2.4.0   [org.apache.kafka.common.utils.AppInfoParser]
...
2020-02-06 15:48:34,485 INFO   ||  [Worker clientId=connect-1, groupId=1] Starting connectors and tasks using config offset -1   [org.apache.kafka.connect.runtime.distributed.DistributedHerder]
2020-02-06 15:48:34,485 INFO   ||  [Worker clientId=connect-1, groupId=1] Finished starting connectors and tasks   [org.apache.kafka.connect.runtime.distributed.DistributedHerder]
Use the Kafka Connect REST API to check the status of the Kafka Connect service.
```
Kafka Connect exposes a REST API to manage Debezium connectors. To communicate with the Kafka Connect service, you can use the curl command to send API requests to port 8083 of the Docker host (which you mapped to port 8083 in the connect container when you started Kafka Connect).

Open a new terminal and check the status of the Kafka Connect service:
```
$ curl -H "Accept:application/json" localhost:8083/
{"version":"2.6.1","commit":"cb8625948210849f"}  
```
The response shows that Kafka Connect version 2.6.1 is running.
Check the list of connectors registered with Kafka Connect:
```
$ curl -H "Accept:application/json" localhost:8083/connectors/
[]  
```
No connectors are currently registered with Kafka Connect.

## Deploy Oracle Connector
```
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @register-oracle.json
```

## Deploy watch_topic tool

docker run -it --rm --name watcher --link zookeeper:zookeeper --link kafka:kafka debezium/kafka:1.4 watch-topic -a -k dbz_oracle.APOLLO_PROP.PACKAGETYPE


 container_name: dbz_oracle
    image: oracleinanutshell/oracle-xe-11g:latest
    ports:
      - 1521:1521
      - 5500:5500
    volumes:
      - /Users/elena.cuevas/workspaces/docker/debezium_apollo_last:/app
      - /Users/elena.cuevas/workspaces/docker/debezium_apollo_last/scripts:/docker-entrypoint-initdb.d 
    environment:
    - ORACLE_ALLOW_REMOTE=YES
    - ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe