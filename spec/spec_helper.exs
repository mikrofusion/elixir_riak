ESpec.configure fn(config) ->
  config.before fn() ->
    {me, se, mi} = :erlang.timestamp

    riak_env = Application.get_env(:elixir_riak, :riak)
    {:ok, pid} = :riakc_pb_socket.start_link(riak_env[:address], riak_env[:port])

    {
      :shared,
      pid: pid,
      bucket: "bucket",
      key: "#{me}#{se}#{mi}"
    }
  end

  config.finally fn(_shared) ->
    :ok
  end
end
