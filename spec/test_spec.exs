defmodule ElixirRiakSpec do
  use ESpec

  import ElixirRiak.Factory

  import :riakc_pb_socket
  require IEx

  @user build(:user)

  subject do
    :riakc_obj.new(shared.bucket, :undefined, @user, "application/json")
  end

  context "riakc_obj" do
    # http://basho.github.io/riak-erlang-client/riakc_obj.html

    it "contains methods to get riakc object values" do
      expect :riakc_obj.bucket(subject) |> to(eq shared.bucket)
      expect :riakc_obj.bucket_type(subject) |> to(eq :undefined)
      expect :riakc_obj.key(subject) |> to(eq :undefined)
      expect :riakc_obj.get_update_value(subject) |> to(eq @user)
      expect :riakc_obj.vclock(subject) |> to(eq :undefined)
      expect :dict.to_list(:riakc_obj.get_update_metadata(subject)) |> to(eq [{"content-type", 'application/json'}])
      expect :riakc_obj.get_update_content_type(subject) |> to(eq 'application/json')
    end
  end

  context "riakc_pb_socket#put && riakc_pb_socket#get" do
    # http://basho.github.io/riak-erlang-client/riakc_pb_socket.html

    before do
      {:ok, id} = :riakc_pb_socket.put(shared.pid, subject)

      {:shared, key: id}
    end

    it "will return the result" do
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)

      val = :riakc_obj.get_update_value(obj) |> :erlang.binary_to_term
      expect val |> to(eq :riakc_obj.get_update_value(subject))
    end
  end

  context "riakc_pb_socket#update with a map" do
    # note: erlang protocol buffers client treats all values as binaries
    before do
      updated_val = %{data: "updated data."}

      {:ok, id} = :riakc_pb_socket.put(shared.pid, subject)
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, id)

      :riakc_pb_socket.put(shared.pid, :riakc_obj.update_value(obj, updated_val))

      {:shared, updated_val: updated_val, key: id}
    end

    it "will return a binary result that needs to be decoded" do
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      val = :riakc_obj.get_update_value(obj) |> :erlang.binary_to_term
      expect val |> to(eq shared.updated_val)
    end
  end

  context "riakc_pb_socket#update with a string" do
    before do
      updated_val = "updated data."

      {:ok, id} = :riakc_pb_socket.put(shared.pid, subject)
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, id)

      :riakc_pb_socket.put(shared.pid, :riakc_obj.update_value(obj, updated_val))

      {:shared, updated_val: updated_val, key: id}
    end

    it "will return a string that doesn't need to be decoded" do
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      val = :riakc_obj.get_update_value(obj)
      expect val |> to(eq shared.updated_val)
    end
  end

  context "riakc_pb_socket#delete" do
    before do
      {:ok, id} = :riakc_pb_socket.put(shared.pid, subject)
      :riakc_pb_socket.delete(shared.pid, shared.bucket, id)

      {:shared, key: id}
    end

    it "will delete the object" do
      result = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      expect result |> to(eq {:error, :notfound})
    end
  end


  context "secondary indexes (2i)" do
    # http://docs.basho.com/riak/kv/2.1.4/developing/usage/secondary-indexes/

    before do
      meta = :riakc_obj.get_update_metadata(subject)

      meta = :riakc_obj.set_secondary_index(meta, [
        {{:integer_index, 'age'}, [25]},
        {{:binary_index, 'name'}, ["John", "Doe"]}
      ])

      obj = :riakc_obj.update_metadata(subject, meta)

      {:ok, id} = :riakc_pb_socket.put(shared.pid, obj)

      {:shared, key: id}
    end

    it "fetches the key by name" do
      # this is similar to the following curl request
      # curl localhost:28098/buckets/bucket/index/name_bin/John
      # {"keys":["PgT0vZYyiX1ZvJd5xTzrtFQqHUB","C7epl8loIbJUj4cvvOUYZXqZX6w"]}

      {:ok, results} = :riakc_pb_socket.get_index_eq(shared.pid, shared.bucket, {:binary_index, 'name'}, "John")
      {:index_results_v1, keys, _, _} = results

      expect Enum.member?(keys, shared.key) |> to(eq true)
    end
  end

  context "links" do
    @friend1 build(:user)
    @friend2 build(:user)
    @sibling build(:user)

    before do
      # insert friends and siblings into the DB
      :ok = :riakc_pb_socket.put(shared.pid, :riakc_obj.new("user", @friend1.name, @friend1, "application/json"))
      :ok = :riakc_pb_socket.put(shared.pid, :riakc_obj.new("user", @friend2.name, @friend2, "application/json"))
      :ok = :riakc_pb_socket.put(shared.pid, :riakc_obj.new("user", @sibling.name, @sibling, "application/json"))

      # update links
      meta = :riakc_obj.get_update_metadata(subject)
      meta = :riakc_obj.set_link(meta, [{"friend", [{"user", @friend1.name},{"user", @friend2.name}]}])
      meta = :riakc_obj.add_link(meta, [{"sibling", [{"user", @sibling.name}]}])
      obj = :riakc_obj.update_metadata(subject, meta)

      {:ok, id} = :riakc_pb_socket.put(shared.pid, obj)

      {:shared, key: id}
    end

    it "allows you to fetch the links" do
      # tip: from command line can do curl -I address:<port>/riak/<shared.bucket>/<shared.key>/<shared.bucket>,friend,_/
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      meta = :riakc_obj.get_update_metadata(obj)

      expect :riakc_obj.get_all_links(meta) |> to(eq [{"friend", [{"user", @friend1.name}, {"user", @friend2.name}]}, {"sibling", [{"user", @sibling.name}]}])
      expect :riakc_obj.get_links(meta, "sibling") |> to(eq [{"user", @sibling.name}])
    end

    it "fetches the links via map reduce" do
      # build in mapreduce https://github.com/basho/riak_kv/blob/master/src/riak_kv_mapreduce.erl
      # http://basho.github.io/riak-erlang-client/riakc_map.html

      {:ok, [{0, _}, {1, [result1, result2]}]} = :riakc_pb_socket.mapred(shared.pid,
         [{shared.bucket, shared.key}],
         [
           {:link, "user", "friend", true},
           {:map, {:modfun, :riak_kv_mapreduce, :map_identity}, :none, true}
         ]
       )

      # note: every once in a while result1 and result2 are swaped - which causes the spec to fail.  fix this.
      {:r_object, bucket1, key1, [{:r_content, dict1, data1}], _, _, _} = result1
      expect bucket1 |> to(eq "user")
      expect key1 |> to(eq @friend1.name)
      expect :erlang.binary_to_term(data1) |> to(eq @friend1)
      expect :dict.fetch_keys(dict1) |> to(eq ["X-Riak-VTag", "content-type", "index", "X-Riak-Last-Modified"])

      {:r_object, bucket2, key2, [{:r_content, dict2, data2}], _, _, _} = result2
      expect bucket2 |> to(eq "user")
      expect key2 |> to(eq @friend2.name)
      expect :erlang.binary_to_term(data2) |> to(eq @friend2)
      expect :dict.fetch_keys(dict2) |> to(eq ["X-Riak-VTag", "content-type", "index", "X-Riak-Last-Modified"])
    end

    # X-Riak-Deleted in the object metadata with a value of true.
  end

  context "search" do
    # http://docs.basho.com/riak/kv/2.1.4/developing/usage/search/

    before do
      :ok = :riakc_pb_socket.create_search_index(shared.pid, "famous")
      :ok = :riakc_pb_socket.set_search_index(shared.pid, shared.bucket, "famous")

      co = :riakc_obj.new(shared.bucket, "liono",
          "{\"name_s\":\"Lion-o\", \"age_i\":30, \"leader_b\":true}",
          "application/json")
      :ok = :riakc_pb_socket.put(shared.pid, co)

      c1 = :riakc_obj.new(shared.bucket, "cheetara",
          "{\"name_s\":\"Cheetara\", \"age_i\":28, \"leader_b\":false}",
          "application/json")
      :ok = :riakc_pb_socket.put(shared.pid, c1)

      c2 = :riakc_obj.new(shared.bucket, "snarf",
          "{\"name_s\":\"Snarf\", \"age_i\":43}",
          "application/json")
      :ok = :riakc_pb_socket.put(shared.pid, c2)

      c3 = :riakc_obj.new(shared.bucket, "panthro",
          "{\"name_s\":\"Panthro\", \"age_i\":36}",
          "application/json")
      :ok = :riakc_pb_socket.put(shared.pid, c3)

    end

    it "search by index" do
      {:ok, {:search_results, [{index,result}|_], _, _}} = :riakc_pb_socket.search(shared.pid, "famous", "name_s:Lion*")

      type  = :proplists.get_value("_yz_rt", result)
      bucket = :proplists.get_value("_yz_rb", result)
      key    = :proplists.get_value("_yz_rk", result)

      {:ok, obj} = :riakc_pb_socket.get(shared.pid, {type, bucket}, key)

      expect :riakc_obj.get_value(obj) |> to(eq "{\"name_s\":\"Lion-o\", \"age_i\":30, \"leader_b\":true}")
    end
  end

  context "Conflict-free replicated data types" do
    # Note: these test require that make test-init is ran prior

    context "counters" do

      before do
        {me, se, mi} = :erlang.timestamp
        key = "#{me}#{se}#{mi}"

        counter = :riakc_counter.new()
        counter = :riakc_counter.increment(10, counter)
        :ok = :riakc_pb_socket.update_type(shared.pid, {"counters", shared.bucket}, key, :riakc_counter.to_op(counter))

        # note value is equivalent to the server value
        0 = :riakc_counter.value(counter)

        {:shared, key: key}
      end

      it "able to fetch the updated value" do
        {:ok, counter} = :riakc_pb_socket.fetch_type(shared.pid, {"counters", shared.bucket}, shared.key)

        expect :riakc_counter.value(counter) |> to(eq 10)
      end
    end

    context "sets" do
      # http://basho.github.io/riak-erlang-client/riakc_set.html

      before do
        {me, se, mi} = :erlang.timestamp
        key = "#{me}#{se}#{mi}"

        set = :riakc_set.new()
        set = :riakc_set.add_element("foo", set)
        set = :riakc_set.add_element("bar", set)

        :ok = :riakc_pb_socket.update_type(shared.pid, {"sets", shared.bucket}, key, :riakc_set.to_op(set))

        {:shared, key: key}
      end

      it "able to fetch the updated value" do
        {:ok, set} = :riakc_pb_socket.fetch_type(shared.pid, {"sets", shared.bucket}, shared.key)

        expect :riakc_set.value(set) |> to(eq ["bar", "foo"])
      end
    end

    context "maps" do
      context "with flags" do
        # flags contain enable / disable  must be stored within maps
      end

      context "with registers" do
      end
    end

    context "searching CRDTs" do
      # searching CRDTs http://docs.basho.com/riak/kv/2.1.4/developing/usage/searching-data-types/

    end

    # flags, registers, sets, maps
  end
end
