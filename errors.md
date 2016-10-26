

```
curl localhost:28098/buckets/bucket/index/name_bin/foobar
{"keys":[]}
```


```
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

From the crash log:  http://localhost:28098/admin/#/cluster/default/ops/nodes/riak@172.17.0.2/logs/crash.log

```
Offender:   [{pid,<0.1806.1>},{name,undefined},{mfargs,{riak_api_pb_server,start_link,undefined}},{restart_type,temporary},{shutdown,brutal_kill},{child_type,worker}]
Reason:     {error,{case_clause,{rpbindexreq,<<"bucket">>,<<"name_bin">>,eq,<<"foobar">>,undefined,undefined,undefined,false,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined}},[{riak_kv_pb_index,decode,2,[{file,"src/riak_kv_pb_index.erl"},{line,62}]},{riak_api_pb_server,connected,2,[{file,"src/riak_api_pb_server.erl"},{line,219}]},{riak_api_pb_server,decode_buffer,2,[{file,"src/riak_api_pb_server.erl"},{line,364}]},{gen_fsm,handle_msg,7,[{file,"gen_fsm.erl"},{line,505}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,239}]}]}
Context:    child_terminated
Supervisor: {local,riak_api_pb_sup}
2016-10-26 02:48:35 =SUPERVISOR REPORT====
neighbours:
reductions: 6874
stack_size: 27
heap_size: 987
status: running
trap_exit: false
dictionary: []
links: [<0.312.0>,#Port<0.414523>]
messages: []
ancestors: [riak_api_pb_sup,riak_api_sup,<0.305.0>]
exception exit: {{error,{case_clause,{rpbindexreq,<<"bucket">>,<<"name_bin">>,eq,<<"foobar">>,undefined,undefined,undefined,false,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined}},[{riak_kv_pb_index,decode,2,[{file,"src/riak_kv_pb_index.erl"},{line,62}]},{riak_api_pb_server,connected,2,[{file,"src/riak_api_pb_server.erl"},{line,219}]},{riak_api_pb_server,decode_buffer,2,[{file,"src/riak_api_pb_server.erl"},{line,364}]},{gen_fsm,handle_msg,7,[{file,"gen_fsm.erl"},{line,505}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,239}]}]},[{gen_fsm,terminate,7,[{file,"gen_fsm.erl"},{line,622}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,239}]}]}
registered_name: []
pid: <0.1806.1>
initial call: riak_api_pb_server:init/1
crasher:
2016-10-26 02:48:35 =CRASH REPORT====
** {error,{case_clause,{rpbindexreq,<<"bucket">>,<<"name_bin">>,eq,<<"foobar">>,undefined,undefined,undefined,false,undefined,undefined,undefined,undefined,undefined,undefined,undefined,undefined}},[{riak_kv_pb_index,decode,2,[{file,"src/riak_kv_pb_index.erl"},{line,62}]},{riak_api_pb_server,connected,2,[{file,"src/riak_api_pb_server.erl"},{line,219}]},{riak_api_pb_server,decode_buffer,2,[{file,"src/riak_api_pb_server.erl"},{line,364}]},{gen_fsm,handle_msg,7,[{file,"gen_fsm.erl"},{line,505}]},{proc_lib,init_p_do_apply,3,[{file,"proc_lib.erl"},{line,239}]}]}
** Reason for termination =
**      Data  == {state,{gen_tcp,inet},#Port<0.414523>,undefined,[{riak_api_basic_pb_service,undefined},{riak_core_pb_bucket,undefined},{riak_core_pb_bucket_type,undefined},{riak_kv_pb_bucket,{state,{riak_client,['riak@172.17.0.2',undefined]},undefined,undefined}},{riak_kv_pb_counter,{state,{riak_client,['riak@172.17.0.2',undefined]}}},{riak_kv_pb_crdt,{state,{riak_client,['riak@172.17.0.2',undefined]},undefined,undefined,undefined,undefined,undefined,undefined,undefined}},{riak_kv_pb_csbucket,{state,{riak_client,['riak@172.17.0.2',undefined]},undefined,undefined,undefined,0}},{riak_kv_pb_index,{state,{riak_client,['riak@172.17.0.2',undefined]},undefined,undefined,undefined,0}},{riak_kv_pb_mapred,{state,undefined,undefined}},{riak_kv_pb_object,{state,{riak_client,['riak@172.17.0.2',undefined]},undefined,undefined,<<0,0,0,0>>}},{yz_pb_admin,no_state},{yz_pb_search,no_state}],{{172,17,0,1},48510},undefined,undefined,3,<<0,0,0,31,25,10,6,98,117,99,107,101,116,18,8,110,97,109,101,95,98,105,110,24,0,34,6,102,111,111,98,97,114,64,0>>,{buffer,[],0,1024}}
** When State == connected
** Last message in was {tcp,#Port<0.414523>,<<0,0,0,31,25,10,6,98,117,99,107,101,116,18,8,110,97,109,101,95,98,105,110,24,0,34,6,102,111,111,98,97,114,64,0>>}
** State machine <0.1806.1> terminating
2016-10-26 02:48:35 =ERROR REPORT====
```

Configuration:

```
storage_backend 	leveldb
strong_consistency 	off
```

Riak running a local copy of:
```
https://hub.docker.com/r/basho/riak-kv/
```

Using the following erlang libraries:

```
  "protobuffs": :protobuffs, "0.8.4"
  "riak_pb": :riak_pb, "2.1.4"
  "riakc": :riakc, "2.4.1"
```
