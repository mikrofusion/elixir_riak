# ElixirRiak

```
docker-compose exec coordinator riak-admin cluster status
```

riak-explorer:
http://localhost:8098/admin/
http://localhost:8093/internal_solr

references:
https://docs.basho.com/riak/kv/2.1.4/developing/getting-started/erlang/
http://basho.com/posts/technical/running-riak-in-docker/
https://hub.docker.com/r/basho/riak-kv/
https://gist.github.com/angrycub/dcd234068fac23aa6de4 # error messages
https://github.com/basho-labs/docker-images
https://raw.githubusercontent.com/lexlapax/dockerfile-riak/master/fixconfigs.sh
https://github.com/drewkerrigan/riak-elixir-client

iex -S mix
o = Riak.Object.create(bucket: "user", key: "my_key", data: "Han Solo")
Riak.put(o)
Riak.find("user", "my_key")

https://github.com/docker/for-mac/issues/85
http://basho.github.io/riak-erlang-client/

http://www.galdiuz.com/mapred.html

https://docs.basho.com/riak/kv/2.1.3/developing/app-guide/advanced-mapreduce/

http://stackoverflow.com/questions/15950139/completely-confused-about-mapreduce-in-riak-erlangs-riakc-client


https://github.com/drewkerrigan/riak-elixir-client
http://docs.basho.com/riak/kv/2.1.4/configuring/load-balancing-proxy/
http://docs.basho.com/riak/kv/2.1.4/using/reference/secondary-indexes/


```
 ~/d/elixir_riak   master *+…  erl -pa  _build/test/lib/riakc/ebin/ _build/test/lib/riak_pb/ebin/ _build/test/lib/protobuffs/ebin/

Erlang/OTP 19 [erts-8.0.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V8.0.2  (abort with ^G)
1> {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 28087).
{ok,<0.59.0>}
2> riakc_pb_socket:ping(Pid).
pong


Erlang/OTP 19 [erts-8.0.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V8.0.2  (abort with ^G)
1> {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 28087).
{ok,<0.59.0>}
2> riakc_pb_socket:ping(Pid).
pong
3> riakc_pb_socket:get_index(Pid, <<"bucket">>, {binary_index, "name"}, <<"foobar">>).
{error,<<"Error processing incoming message: error:{case_clause,\n                                          {rpbindexre"...>>}
4>
=ERROR REPORT==== 25-Oct-2016::19:46:53 ===
** Generic server <0.59.0> terminating
** Last message in was {tcp_closed,#Port<0.673>}
** When Server state == {state,"127.0.0.1",28087,false,false,undefined,false,
                               gen_tcp,undefined,
                               {[],[]},
                               1,[],infinity,undefined,undefined,undefined,
                               undefined,[],100}
** Reason for termination ==
** disconnected
** exception error: disconnected
4>



Erlang/OTP 19 [erts-8.0.2] [source] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false] [dtrace]

Eshell V8.0.2  (abort with ^G)
1> {ok, Pid} = riakc_pb_socket:start_link("127.0.0.1", 28087).
{ok,<0.59.0>}
2> riakc_pb_socket:ping(Pid).
pong
3> riakc_pb_socket:get_index(Pid, <<"bucket">>, {binary_index, "name"}, <<"foobar">>).
{error,<<"Error processing incoming message: error:{case_clause,\n                                          {rpbindexre"...>>}
4>
=ERROR REPORT==== 25-Oct-2016::19:48:35 ===
** Generic server <0.59.0> terminating
** Last message in was {tcp_closed,#Port<0.673>}
** When Server state == {state,"127.0.0.1",28087,false,false,undefined,false,
                               gen_tcp,undefined,
                               {[],[]},
                               1,[],infinity,undefined,undefined,undefined,
                               undefined,[],100}
** Reason for termination ==
** disconnected
** exception error: disconnected
4>

```

# list keys
iex(22)> {:ok, pid} = Riak.Connection.start_link('127.0.0.1', 8087)
{:ok, #PID<0.238.0>}
iex(23)> :riakc_pb_socket.list_keys(pid, <<"groceries">>)
{:ok, []}
iex(24)> :riakc_pb_socket.list_keys(pid, <<"user">>)
{:ok, ["my_key"]}
iex(25)>


# make sure the server is up
tail -f raik/logs/console.log

# remove docker volumes
docker volume rm (docker volume ls -q -f dangling=true)

Sometimes will not come up:
```
  https://github.com/basho/riak_core/issues/151
  coordinator_1  | + /usr/sbin/riak-admin wait-for-service riak_kv
  coordinator_1  | riak_kv is not up: []
  coordinator_1  | riak_kv is not up: []
  coordinator_1  | riak_kv is not up: []
  coordinator_1  | riak_kv is up
```

If you create a buckettype that already exists:
```
coordinator_1  | ++ echo 'Looking for datatypes in /etc/riak/schemas/...'
coordinator_1  | Looking for datatypes in /etc/riak/schemas/...
coordinator_1  | +++ find /etc/riak/schemas/ -name '*.dt' -print
coordinator_1  | ++ for f in '$(find $SCHEMAS_DIR -name *.dt -print)'
coordinator_1  | +++ basename -s .dt /etc/riak/schemas/counter.dt
coordinator_1  | ++ BUCKET_NAME=counter
coordinator_1  | +++ cat /etc/riak/schemas/counter.dt
coordinator_1  | ++ BUCKET_DT=counter
coordinator_1  | ++ /usr/sbin/riak-admin bucket-type create counter '{"props":{"datatype":"counter"}}'
coordinator_1  | Error creating bucket type counter:
coordinator_1  | already_active
elixirriak_coordinator_1 exited with code 1
```



curl 'localhost:8098/riak/user?keys=true' | prettyjson



##

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `elixir_riak` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:elixir_riak, "~> 0.1.0"}]
    end
    ```

  2. Ensure `elixir_riak` is started before your application:

    ```elixir
    def application do
      [applications: [:elixir_riak]]
    end
    ```

