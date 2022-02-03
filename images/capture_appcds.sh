#!/bin/bash

# Set log dir
export LOG_DIR=/tmp

# Generate cluster id
./bin/kafka-storage.sh random-uuid > /tmp/cluster-id

# Format logs dir for appCDS run
./bin/kafka-storage.sh format -t $(cat /tmp/cluster-id) -c ./config/kraft/server.properties

# Run server for generating appCDS
export KAFKA_OPTS=-XX:ArchiveClassesAtExit=/tmp/app-cds.jsa
./bin/kafka-server-start.sh config/kraft/server.properties &

# Capture broker pid
KAFKA_PID=$!
# Wait for creation of server.log
while [ ! -f "/tmp/server.log" ]; do sleep 0.1; done;
# Wait until broker is started
( tail -f -n0 /tmp/server.log & ) | grep -q "The broker has been unfenced. Transitioning from RECOVERY to RUNNING"
# Stop broker process
kill ${KAFKA_PID};
# Wait until app-cds archive is generated
while [ ! -f "/tmp/app-cds.jsa" ]; do sleep 0.1; done;

# Clean log dir except cluster id & app-cds archive
rm -rf /tmp/kraft-combined-logs /tmp/controller.log /tmp/kafka-authorizer.log /tmp/kafka-request.log /tmp/kafkaServer-gc.log /tmp/server.log /tmp/state-change.log

# Format logs dir again
./bin/kafka-storage.sh format -t $(cat /tmp/cluster-id) -c ./config/kraft/server.properties
