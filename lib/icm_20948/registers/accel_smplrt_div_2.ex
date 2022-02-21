defmodule Icm20948.Registers.AccelSmplrtDiv2 do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.accel_smplrt_div_lsb()]

  def keys(), do: [Keys.accel_smplrt_div_lsb()]
  def bits(), do: [8]
end
