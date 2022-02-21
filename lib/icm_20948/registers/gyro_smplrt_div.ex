defmodule Icm20948.Registers.GyroSmplrtDiv do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.gyro_smplrt_div()]

  def keys(), do: [Keys.gyro_smplrt_div()]
  def bits(), do: [8]
end
