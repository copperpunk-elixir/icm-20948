defmodule Icm20948Spi.SpiDevice do
  require Icm20948Spi.Registers, as: Reg
  use Bitwise
  require Logger
  defstruct [:spi_ref, :last_bank, :last_mems_bank, :gyro_sf, :data_ready_status]

  @spec new(binary(), list()) :: struct()
  def new(bus_name \\ "spidev1.0", options \\ []) do
    {:ok, ref} = Circuits.SPI.open(bus_name, options)
    %Icm20948Spi.SpiDevice{spi_ref: ref}
  end

  @spec set_bank(struct(), integer()) :: struct()
  def set_bank(device, bank) do
    if bank > 3, do: raise("Bank of #{inspect(bank)} must be less than 4")

    if bank == device.last_bank do
      device
    else
      device = %{device | last_bank: bank}
      bank = bank <<< 4 &&& 0x30
      response = write(device, Reg.reg_bank_sel(), <<bank>>)
      Logger.debug("set bank: #{inspect(response)}")
      device
    end
  end

  @spec write(struct(), integer(), binary()) :: binary()
  def write(device, register, data) do
    {:ok, response} = Circuits.SPI.transfer(device.spi_ref, <<register>> <> data)
    response
  end

  @spec read(struct(), integer(), integer()) :: binary()
  def read(device, register, bytes_to_read) do
    {:ok, <<_, response::binary>>} =
      Circuits.SPI.transfer(
        device.spi_ref,
        <<register>> <> String.duplicate(<<0>>, bytes_to_read)
      )
    response
  end
end
