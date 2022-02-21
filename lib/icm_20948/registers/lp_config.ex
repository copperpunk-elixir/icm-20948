defmodule Icm20948.Registers.LpConfig do
  require Icm20948.Registers.Keys, as: Keys
  require Icm20948.Registers.Bits, as: Bits

  defstruct Keys.lp_config()
  def keys(), do: Keys.lp_config()
  def bits(), do: Bits.lp_config()

  def sample_mode_continuous(), do: 0
  def sample_mode_cycled(), do: 1

end
