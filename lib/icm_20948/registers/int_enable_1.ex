
defmodule Icm20948.Registers.IntEnable1 do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.reserved_0(), Keys.raw_data_0_rdy_en()]

  def keys(), do: [Keys.reserved_0(), Keys.raw_data_0_rdy_en()]
  def bits(), do: [7, 1]
end
