defmodule Icm20948 do
  use GenServer
  require Logger
  require Icm20948.Registers, as: Reg
  require Icm20948.Status, as: Status

  @icm_who_am_i 0xEA

  def start_link_spi() do
    config = [bus_name: "spidev0.0", bus_options: [speed_hz: 1_000_000]]
    start_link(config)
  end

  def start_link_spidriver() do
    config = [bus_name: "spidriver", bus_options: [port_name: "/dev/ttyUSB0"]]
    start_link(config)
  end

  def start_link(config) do
    Logger.debug("Start #{__MODULE__}")
    ViaUtils.Process.start_link_singular(GenServer, __MODULE__, config)
  end

  @impl GenServer
  def init(config) do
    bus_name = Keyword.fetch!(config, :bus_name)
    bus_options = Keyword.get(config, :bus_options, [])

    state = %{
      icm: nil,
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
    GenServer.cast(__MODULE__, {:begin, bus_name, bus_options})
    {:ok, state}
  end

  @impl GenServer
  def handle_cast(:check_id, state) do
    check_id(state.icm)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:begin, bus_name, bus_options}, state) do
    Logger.debug("Begin #{bus_name} with options: #{inspect(bus_options)}")
    icm = begin(bus_name, bus_options)

    {:noreply, %{state | icm: icm}}
  end

  @impl GenServer
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  def begin(bus_name, bus_options) do
    Icm20948.IcmDevice.new(bus_name, bus_options)
    |> check_id()
  end

  @spec check_id(struct()) :: struct()
  def check_id(icm) do
    icm = Icm20948.IcmDevice.set_bank(icm, 0)
    Logger.debug("icm: #{inspect(icm)}")
    <<who_am_i>> = Icm20948.IcmDevice.read(icm, Reg.agb0_reg_who_am_i(), 1)
    Logger.debug("whom am i: #{who_am_i}")
    if who_am_i != @icm_who_am_i, do: raise("WHO_AM_I returned: #{who_am_i}")
    icm
  end

  @spec sw_reset(struct()) :: struct()
  def sw_reset(icm) do
    icm = Icm20948.IcmDevice.set_bank(icm, 0)
    icm
  end

  @spec request_check_id() :: atom
  def request_check_id() do
    GenServer.cast(__MODULE__, :check_id)
  end

end
