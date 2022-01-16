defmodule Icm20948.IcmDevice do
  require Icm20948.Registers, as: Reg
  alias Circuits.GPIO, as: Gpio
  use Bitwise
  require Logger

  defstruct [
    :interface,
    :last_bank,
    :last_mems_bank,
    :gyro_sf,
    :data_ready_status
  ]

  @spec new(binary(), list()) :: struct()
  def new(bus_name, bus_options) do
    interface =
      cond do
        String.contains?(bus_name, "spidev") -> Icm20948.Interface.Spi.new(bus_name, bus_options)
        String.contains?(bus_name, "i2c") -> raise "I2C not supported yet"
        String.contains?(bus_name, "spidriver") -> Icm20948.Interface.SpiDriver.new("", bus_options)
        true -> raise "Bus name must contain 'spi' or 'i2c'"
      end

    %Icm20948.IcmDevice{interface: interface}
  end

  @spec write(struct(), integer(), binary()) :: binary()
  def write(device, register, data) do
    apply(device.interface.__struct__, :write, [device, register, data])
  end

  @spec read(struct(), integer(), integer()) :: binary()
  def read(device, register, bytes_to_read) do
    %{interface: interface} = device
    apply(interface.__struct__, :read, [interface, register, bytes_to_read])
  end

  @spec set_bank(struct(), integer()) :: struct()
  def set_bank(device, bank) do
    %{last_bank: last_bank, interface: interface} = device
    if bank > 3, do: raise("Bank of #{inspect(bank)} must be less than 4")

    if bank == last_bank do
      device
    else
      bank = bank <<< 4 &&& 0x30
      response = apply(interface.__struct__, :write, [interface, Reg.reg_bank_sel(), <<bank>>])
      Logger.debug("set bank: #{inspect(response)}")
      %{device | last_bank: bank}
    end
  end
end
