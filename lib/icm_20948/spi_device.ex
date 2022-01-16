defmodule Icm20948.SpiDevice do
  require Icm20948.Registers, as: Reg
  alias Circuits.GPIO, as: Gpio
  use Bitwise
  require Logger

  defstruct [
    :spi_ref,
    :last_bank,
    :last_mems_bank,
    :gyro_sf,
    :data_ready_status
  ]

  @spec new() :: struct()
  def new() do
    bus_name = "spidev0.0"
    options = [mode: 0, speed_hz: 1_000_000]
    new(bus_name, options)
  end

  @spec new(binary(), list()) :: struct()
  def new(bus_name, options) do
    # {:ok, cs_pin} = Gpio.open(25, :output)
    # Gpio.write(cs_pin, 1)
    {:ok, spi_ref} = Circuits.SPI.open(bus_name, options)
    %Icm20948.SpiDevice{spi_ref: spi_ref}
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
    Logger.debug("write: #{inspect(<<register>> <> data)}")

    %{spi_ref: spi_ref} = device
    # Kick the tires
    {:ok, response} = Circuits.SPI.transfer(spi_ref, <<register>> <> data)
    response
  end

  @spec read(struct(), integer(), integer()) :: binary()
  def read(device, register, bytes_to_read) do
    # Required to singal a read request
    register = register ||| 0x80

    Logger.debug(
      "read. Write: #{inspect(<<register>> <> String.duplicate(<<0>>, bytes_to_read))}"
    )

    %{spi_ref: spi_ref} = device

    {:ok, <<_first_byte, response::binary>>} =
      Circuits.SPI.transfer(
        spi_ref,
        <<register>> <> String.duplicate(<<0>>, bytes_to_read)
      )

    Logger.debug("response: #{inspect(response)}")
    response
  end
end
