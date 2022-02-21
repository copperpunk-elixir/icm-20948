defmodule Icm20948.Registers.PwrMgmt1 do
  require Icm20948.Registers.Keys, as: Keys
  require Icm20948.Registers.Bits, as: Bits
  use Bitwise
  require Logger

  # @spec new(integer()) :: struct()
  # def new(value) do

  #   <<clksel::3, temp_dis::1, reserved_0::1, lp_en::1, sleep::1, device_reset::1>> = <<value>>

  #   %Icm20948.Registers.PwrMgmt1{
  #     Keys.clksel() => clksel,
  #     Keys.temp_dis() => temp_dis,
  #     Keys.reserved_0() => reserved_0,
  #     Keys.lp_en() => lp_en,
  #     Keys.sleep() => sleep,
  #     Keys.device_reset() => device_reset
  #   }
  # end

  # @spec value(struct()) :: integer()
  # def value(pwr_mgmt_1) do
  #   # <<clksel::3, temp_dis::1, reserved_0::1, lp_en::1, sleep::1, device_reset::1>> = <<pwr_mgmt_1>>
  # end

  defstruct Keys.pwr_mgmt_1()
  def keys(), do: Keys.pwr_mgmt_1()
  def bits(), do: Bits.pwr_mgmt_1()
end
