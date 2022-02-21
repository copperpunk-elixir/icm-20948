defmodule Icm20948.Registers.AccelSmplrtDiv1 do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.reserved_0(), Keys.accel_smplrt_div_msb()]

  def keys(), do: [Keys.reserved_0(), Keys.accel_smplrt_div_msb()]
  def bits(), do: [4, 4]
end
