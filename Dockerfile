FROM basho/riak-kv
MAINTAINER Mike Groseclose <mike.groseclose@gmail.com>

ADD riak/riak.conf /etc/riak/riak.conf
ADD riak/advanced.conf /etc/riak/advanced.config
