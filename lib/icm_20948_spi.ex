defmodule Icm20948Spi do
  require Logger
  alias Icm20948Spi.SpiDevice, as: SpiDevice
  require Icm20948Spi.Registers, as: Reg
  require Icm20948Spi.Status, as: Status

  @icm_who_am_i 0xEA

  defstruct [:device, :accel_mpss, :gyro_rps, :data_ready]

  def begin(bus_name \\ "spidev1.0", options \\ []) do
    device = SpiDevice.new(bus_name, options)
    icm = %Icm20948Spi{device: device}
    icm = check_id(icm)
    icm
  end

  @spec check_id(struct()) :: struct()
  def check_id(icm) do
    device = SpiDevice.set_bank(icm.device, 0)
    Logger.debug("device: #{inspect(device)}")
    <<who_am_i>> = SpiDevice.read(device, Reg.agb0_reg_who_am_i(), 1)
    if who_am_i != @icm_who_am_i, do: raise("WHO_AM_I returned: #{who_am_i}")

    %{icm | device: device}
  end
end
