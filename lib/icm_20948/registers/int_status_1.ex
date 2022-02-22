defmodule Icm20948.Registers.IntStatus1 do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.raw_data_0_rdy_int()]

  def keys(), do: [Keys.reserved_0(), Keys.raw_data_0_rdy_int()]
  def bits(), do: [7, 1]
end
