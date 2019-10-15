defmodule Math.RandTest do
  use ExUnit.Case

  setup_all do
    %{
      # Set VM with fake txid
      vm: FBAgent.VM.init |> FBAgent.VM.set!("tx", %{txid: "abcdef"}),
      script: File.read!("src/math/rand.lua")
    }
  end
  
  test "must create n unique numbers", ctx do
    res = %FBAgent.Cell{script: ctx.script, params: ["6"]}
    |> FBAgent.Cell.exec!(ctx.vm)
    assert is_list(res)
    assert length(res) == 6
    assert Enum.uniq(res) |> length == 6
  end

  test "must create 1 random number of no params given", ctx do
    res = %FBAgent.Cell{script: ctx.script, params: []}
    |> FBAgent.Cell.exec!(ctx.vm)
    assert length(res) == 1
  end

end
