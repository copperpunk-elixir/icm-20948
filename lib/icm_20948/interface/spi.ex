defmodule Icm20948.Interface.Spi do
  require Icm20948.Registers, as: Reg
  alias Circuits.GPIO, as: Gpio
  use Bitwise
  require Logger

  defstruct [:spi_ref]

  @spec new() :: struct()
  def new() do
    bus_name = "spidev0.0"
    options = [mode: 0, speed_hz: 1_000_000]
    new(bus_name, options)
  end

  @spec new(binary(), list()) :: struct()
  def new(bus_name, options) do
    {:ok, spi_ref} = Circuits.SPI.open(bus_name, options)
    %Icm20948.Interface.Spi{spi_ref: spi_ref}
  end

  @spec write(struct(), integer(), binary()) :: binary()
  def write(device, register, data) do
    # Logger.debug("write: #{inspect(<<register>> <> data)}")
    {:ok, response} = Circuits.SPI.transfer(device.spi_ref, <<register>> <> data)
    response
  end

  @spec read(struct(), integer(), integer()) :: binary()
  def read(device, register, bytes_to_read) do
    # Required to signal a read request
    register = register ||| 0x80

    # Logger.debug(
    #   "read. Write: #{inspect(<<register>> <> String.duplicate(<<0>>, bytes_to_read))}"
    # )

    %{spi_ref: spi_ref} = device

    {:ok, <<_first_byte, response::binary>>} =
      Circuits.SPI.transfer(
        spi_ref,
        <<register>> <> String.duplicate(<<0>>, bytes_to_read)
      )

    # Logger.debug("response: #{inspect(response)}")
    response
  end
end
