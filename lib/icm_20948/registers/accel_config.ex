defmodule Icm20948.Registers.AccelConfig do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [Keys.reserved_0(), Keys.accel_dlpfcfg(), Keys.accel_fs_sel(), Keys.accel_fchoice()]

  def keys(),
    do: [Keys.reserved_0(), Keys.accel_dlpfcfg(), Keys.accel_fs_sel(), Keys.accel_fchoice()]

  def bits(), do: [2, 3, 2, 1]

  # Full Scale
  def gpm2(), do: 0x00
  def gpm4(), do: 0x01
  def gpm8(), do: 0x02
  def gpm16(), do: 0x03

  # DLPF CFG
  def acc_d246bw_n265bw(), do: 0x00
  def acc_d246bw_n265bw_1(), do: 0x01
  def acc_d111bw4_n136bw(), do: 0x02
  def acc_d50bw4_n68bw8(), do: 0x03
  def acc_d23bw9_n34bw4(), do: 0x04
  def acc_d11bw5_n17bw(), do: 0x05
  def acc_d5bw7_n8bw3(), do: 0x06
  def acc_d473bw_n499bw(), do: 0x07
end
