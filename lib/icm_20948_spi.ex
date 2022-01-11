defmodule Icm20948Spi do
  use GenServer
  require Logger
  alias Icm20948Spi.SpiDevice, as: SpiDevice
  require Icm20948Spi.Registers, as: Reg
  require Icm20948Spi.Status, as: Status

  @icm_who_am_i 0xEA

  def start_link(config \\ []) do
    Logger.debug("Start #{__MODULE__}")
    ViaUtils.Process.start_link_singular(GenServer, __MODULE__, config)
  end

  @impl GenServer
  def init(config) do
    bus_name = Keyword.get(config, :spi_bus_name, "spidev0.0")
    bus_options = Keyword.get(config, :spi_bus_options, [speed_hz: 4000000, delay_us: 100])

    icm = begin(bus_name, bus_options)

    state = %{
      icm: icm,
      accel_mpss: %{},
      gyro_rps: %{},
      data_ready: false
    }

    # ViaUtils.Process.start_loop(
    #   self(),
    #   Keyword.fetch!(config, :refresh_groups_loop_interval_ms),
    #   :refresh_groups
    # )

    Logger.debug("#{__MODULE__} started at #{inspect(self())}")
    {:ok, state}
  end

  def begin(bus_name, options) do
    SpiDevice.new(bus_name, options)
    |> check_id()
  end

  @spec check_id(struct()) :: struct()
  def check_id(icm) do
    icm = SpiDevice.set_bank(icm, 0)
    Logger.debug("icm: #{inspect(icm)}")
    <<who_am_i>> = SpiDevice.read(icm, Reg.agb0_reg_who_am_i(), 1)
    if who_am_i != @icm_who_am_i, do: raise("WHO_AM_I returned: #{who_am_i}")
    icm
  end
end
