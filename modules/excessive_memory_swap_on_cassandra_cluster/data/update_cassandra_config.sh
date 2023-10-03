

#!/bin/bash



# set the maximum number of concurrent queries

MAX_QUERIES=${MAX_QUERIES}



# set the maximum size of data kept in memory

MAX_MEMORY=${MAX_MEMORY}



# update the Cassandra configuration file to include the new settings

echo "max_concurrent_queries = $MAX_QUERIES" >> /etc/cassandra/cassandra.yaml

echo "max_memory_size = $MAX_MEMORY" >> /etc/cassandra/cassandra.yaml



# restart the Cassandra service to apply the changes

service cassandra restart



# verify that the changes were applied successfully

cqlsh -e "DESCRIBE CONFIG;"