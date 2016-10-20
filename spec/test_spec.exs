defmodule ElixirRiakSpec do
  use ESpec

  subject do
    :riakc_obj.new(shared.bucket, shared.key, "all the datas!", "application/json")
  end

  require IEx
  context "riakc_obj" do
    it "contains methods to get riakc object values" do
      expect :riakc_obj.bucket(subject) |> to(eq shared.bucket)
      expect :riakc_obj.bucket_type(subject) |> to(eq :undefined)
      expect :riakc_obj.key(subject) |> to(eq shared.key)
      expect :riakc_obj.get_update_value(subject) |> to(eq "all the datas!")
      expect :riakc_obj.vclock(subject) |> to(eq :undefined)
      expect :dict.to_list(:riakc_obj.get_update_metadata(subject)) |> to(eq [{"content-type", 'application/json'}])
      expect :riakc_obj.get_update_content_type(subject) |> to(eq 'application/json')
    end
  end

  context "riakc_pb_socket#put && riakc_pb_socket#get" do
    before do
      :riakc_pb_socket.put(shared.pid, subject)
    end

    it "will return the result" do
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      expect :riakc_obj.get_update_value(obj) |> to(eq :riakc_obj.get_update_value(subject))
    end
  end

  context "riakc_pb_socket#update" do
    before do
      updated_val = "updated data."

      :riakc_pb_socket.put(shared.pid, subject)
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)

      :riakc_pb_socket.put(shared.pid, :riakc_obj.update_value(obj, updated_val))
      {:shared, updated_val: updated_val}
    end

    it "will return the result" do
      {:ok, obj} = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      expect :riakc_obj.get_update_value(obj) |> to(eq shared.updated_val)
    end
  end

  context "riakc_pb_socket#delete" do
    before do
      :riakc_pb_socket.put(shared.pid, subject)
      :riakc_pb_socket.delete(shared.pid, shared.bucket, shared.key)
    end

    it "will delete the object" do
      result = :riakc_pb_socket.get(shared.pid, shared.bucket, shared.key)
      expect result |> to(eq {:error, :notfound})
    end
  end
end
