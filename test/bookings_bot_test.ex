defmodule BookingsBotTest do
  use ExUnit.Case
  doctest BookingsBot

  test "greets the world" do
    assert BookingsBot.hello() == :world
  end
end
