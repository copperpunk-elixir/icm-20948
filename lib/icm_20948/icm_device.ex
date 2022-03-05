defmodule Icm20948.IcmDevice do
  require Icm20948.Registers, as: Reg
  alias Circuits.GPIO, as: Gpio
  require Icm20948.Registers.AccelConfig, as: AC
  require Icm20948.Registers.GyroConfig1, as: GC
  require ViaUtils.Constants, as: VC

  use Bitwise
  require Logger

  defstruct [
    :interface,
    :last_bank,
    :last_mems_bank,
    :gyro_sf,
    :data_ready_status,
    :accel_divisor,
    :gyro_divisor
  ]

  @spec new(binary(), list()) :: struct()
  def new(bus_name, bus_options) do
    interface =
      cond do
        String.contains?(bus_name, "spidev") ->
          Icm20948.Interface.Spi.new(bus_name, bus_options)

        String.contains?(bus_name, "i2c") ->
          raise "I2C not supported yet"

        String.contains?(bus_name, "spidriver") ->
          Icm20948.Interface.SpiDriver.new("", bus_options)

        true ->
          raise "Bus name must contain 'spi' or 'i2c'"
      end

    %Icm20948.IcmDevice{interface: interface}
  end

  @spec write(struct(), integer(), binary()) :: binary()
  def write(device, register, data) do
    %{interface: interface} = device
    apply(interface.__struct__, :write, [interface, register, data])
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
      # Logger.debug("Desired bank (#{bank}) is same as current bank. No action necessary.")
      device
    else
      # Logger.debug("set bank new/old: #{bank}/#{last_bank}")
      bank = bank <<< 4 &&& 0x30
      # Logger.debug("write to bank reg: #{bank}")
      _response = apply(interface.__struct__, :write, [interface, Reg.reg_bank_sel(), <<bank>>])
      # Logger.debug("set bank: #{inspect(response)}")
      %{device | last_bank: bank}
    end
  end

  @spec set_accel_divisor(struct(), integer()) :: struct()
  def set_accel_divisor(device, accel_fs) do
    accel_divisor =
      case accel_fs do
        AC.gpm2() -> 16384 / VC.gravity()
        AC.gpm4() -> 8192 / VC.gravity()
        AC.gpm8() -> 4096 / VC.gravity()
        AC.gpm16() -> 2048 / VC.gravity()
        true -> raise "Improper Accel FS value used: #{inspect(accel_fs)}"
      end

    Logger.debug("Set accel divisor to: #{accel_divisor}")
    %{device | accel_divisor: accel_divisor}
  end

  @spec set_gyro_divisor(struct(), integer()) :: struct()
  def set_gyro_divisor(device, gyro_fs) do
    gyro_divisor =
      case gyro_fs do
        GC.dps250() -> 131 / VC.deg2rad()
        GC.dps500() -> 65.5 / VC.deg2rad()
        GC.dps1000() -> 32.8 / VC.deg2rad()
        GC.dps2000() -> 16.4 / VC.deg2rad()
        true -> raise "Improper Gyro FS value used: #{inspect(gyro_fs)}"
      end

    Logger.debug("Set gyro divisor to: #{gyro_divisor}")

    %{device | gyro_divisor: gyro_divisor}
  end

  @spec get_accel_mpss(struct(), number()) :: number()
  def get_accel_mpss(device, accel_raw) do
    accel_raw / device.accel_divisor
  end

  @spec get_gyro_rps(struct(), number()) :: number()
  def get_gyro_rps(device, gyro_raw) do
    gyro_raw / device.gyro_divisor
  end

  @spec get_temp_c(number()) :: number()
  def get_temp_c(temp_raw) do
    (temp_raw - 21) / 333.87 + 21
  end
end
