defmodule Icm20948.Interface.SpiDriver do
  require Icm20948.Registers, as: Reg
  use Bitwise
  require Logger

  defstruct [:port_name]

  @spec new() :: struct()
  def new() do
    options = [port_name: "/dev/ttyUSB0"]
    new("", options)
  end

  @spec new(binary(), list()) :: struct()
  def new(_bus_name, options) do
    port_name = Keyword.fetch!(options, :port_name)
    # {:ok, cs_pin} = Gpio.open(25, :output)
    # Gpio.write(cs_pin, 1)
    %Icm20948.Interface.SpiDriver{port_name: port_name}
  end

  @spec write(struct(), integer(), binary()) :: binary()
  def write(device, register, data) do
    Logger.debug("write: #{inspect(<<register>> <> data)}")

    %{port_name: port_name} = device

    cmd_string =
      :io_lib.format("./spicl ~s s w ~s u", [port_name, binary_to_string(<<register>> <> data)])
      |> :lists.flatten()

    # Logger.debug("flat cmd string: #{inspect(cmd_string)}")

    :os.cmd(cmd_string)
    ""
  end

  @spec read(struct(), integer(), integer()) :: binary()
  def read(device, register, bytes_to_read) do
    # Required to singal a read request
    register = register ||| 0x80

    # Logger.debug(
    #   "read. Write: #{inspect(<<register>> <> String.duplicate(<<0>>, bytes_to_read))}"
    # )

    %{port_name: port_name} = device

    cmd_string =
      :io_lib.format("./spicl ~s s w ~s r ~s u", [
        port_name,
        binary_to_string(<<register>>),
        "#{bytes_to_read}"
      ])
      |> :lists.flatten()

    # Logger.debug("flat cmd string: #{inspect(cmd_string)}")

    response_char_list = :os.cmd(cmd_string)
    # Logger.debug("response: #{inspect(response_char_list)}")
    response_to_binary(response_char_list)
  end

  def response_to_binary(response) do
    to_string(response)
    |> String.trim()
    |> String.replace("0x", "")
    |> String.replace(",", "")
    |> String.upcase()
    |> Base.decode16!()
  end

  def binary_to_string(bin) do
    Enum.reduce(:binary.bin_to_list(bin), "", fn val, acc ->
      "#{acc},0x#{Base.encode16(<<val>>)}"
    end)
    |> String.trim_leading(",")
  end
end
