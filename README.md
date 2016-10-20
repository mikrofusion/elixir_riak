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

