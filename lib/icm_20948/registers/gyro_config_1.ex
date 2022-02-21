defmodule Icm20948.Registers.GyroConfig1 do
  require Icm20948.Registers.Keys, as: Keys
  require Icm20948.Registers.Bits, as: Bits

  defstruct Keys.gyro_config_1()
  def keys(), do: Keys.gyro_config_1()
  def bits(), do: Bits.gyro_config_1()

  # Full Scale
  def dps250(), do: 0x00
  def dps500(), do: 0x01
  def dps1000(), do: 0x02
  def dps2000(), do: 0x03

  # DLPF CFG
  def gyr_d196bw6_n229bw8(), do: 0x00
  def gyr_d151bw8_n187bw6(), do: 0x01
  def gyr_d119bw5_n154bw3(), do: 0x02
  def gyr_d51bw2_n73bw3(), do: 0x03
  def gyr_d23bw9_n35bw9(), do: 0x04
  def gyr_d11bw6_n17bw8(), do: 0x05
  def gyr_d5bw7_n8bw9(), do: 0x06
  def gyr_d361bw4_n376bw5(), do: 0x07
end
