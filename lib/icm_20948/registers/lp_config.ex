defmodule Icm20948.Registers.LpConfig do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [
    Keys.reserved_0(),
    Keys.i2c_mst_cycle(),
    Keys.accel_cycle(),
    Keys.gyro_cycle(),
    Keys.reserved_1()
  ]

  def keys(),
    do: [
      Keys.reserved_0(),
      Keys.i2c_mst_cycle(),
      Keys.accel_cycle(),
      Keys.gyro_cycle(),
      Keys.reserved_1()
    ]

  def bits(), do: [1, 1, 1, 1, 4]

  def sample_mode_continuous(), do: 0
  def sample_mode_cycled(), do: 1
end
