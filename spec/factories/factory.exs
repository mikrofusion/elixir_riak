defmodule ElixirRiak.Factory do
  use ExMachina

  def user_factory do
    %{
      name: sequence(:name, &"user_name#{&1}"),
    }
  end

end
