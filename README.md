# ElixirRiak
This repo uses the erlang-riak-client to test out Riak functionality.

## Getting Started

Clone this repo locally.  From within the repo:

First, run Riak locally:

1. Install the docker platform: http://www.docker.com/products/overview
2. Run ``` make start-all ``` (or ```make dev-start``` and ```make test-start```.  See below for more about the make commands.
3. Wait ~15-30 seconds for the cluster to stabilize.  Then run ```make test-init``` to create bucket-types required for the specs.

Next, lets run the specs to see that everything is working right:

```mix deps.get```

```mix espec```

## Make commands

### start-all
Runs ```dev-start / test-start```

### stop-all
Runs ```dev-stop / test-stop```

### dev-start / test-start
Starts a Riak cluster (dev or test mode)

### dev-stop / test-stop
Stops a Riak cluster (dev or test mode)

### dev-status / test-status
Runs ```riak-admin cluster status``` on the coordinator for the cluster

### dev-logs / test-logs
Tails the logs for the cluster

### dev-init / test-init
Initializes the container with some default CRDT bucket types (counter, maps, and sets)

### clean
Removes all dangling docker volumes.

## Container Ports
The easiest way to get the ports for the running containers is to run ```docker ps```

## Explorers and dashboards
riak explorer:
http://localhost:<port|8098>/admin/

solr dashboard:
http://localhost:<port|8093>/internal_solr

http:
curl 'localhost:<8098>/riak/user?keys=true' | prettyjson

## Issues
Sometimes docker for mac ends up leaving the containers in a bad state when the computer hibernates.
If you have issues connecting after a hibernation, stop and restart the containers.
https://github.com/docker/for-mac/issues/85

## TODO
Put Riak docker instances behind an nginx or HAproxy load balancer
http://docs.basho.com/riak/kv/2.1.4/configuring/load-balancing-proxy/

# References
https://docs.basho.com/riak/kv/2.1.4/developing/getting-started/erlang/
http://basho.com/posts/technical/running-riak-in-docker/
https://hub.docker.com/r/basho/riak-kv/
https://gist.github.com/angrycub/dcd234068fac23aa6de4 # error messages
https://github.com/basho-labs/docker-images
https://raw.githubusercontent.com/lexlapax/dockerfile-riak/master/fixconfigs.sh
https://github.com/drewkerrigan/riak-elixir-client
http://basho.github.io/riak-erlang-client/
http://www.galdiuz.com/mapred.html
https://docs.basho.com/riak/kv/2.1.3/developing/app-guide/advanced-mapreduce/
http://stackoverflow.com/questions/15950139/completely-confused-about-mapreduce-in-riak-erlangs-riakc-client
https://github.com/drewkerrigan/riak-elixir-client
http://docs.basho.com/riak/kv/2.1.4/using/reference/secondary-indexes/
http://docs.basho.com/riak/1.2.1/tutorials/fast-track/Loading-Data-and-Running-MapReduce-Queries/
