defmodule Icm20948 do
  use GenServer
  require Logger
  require Icm20948.Registers, as: Reg
  require Icm20948.Status, as: Status
  require Icm20948.Registers.Keys, as: Keys
  alias Icm20948.Registers, as: Registers
  alias Registers.Generic, as: Generic
  alias Icm20948.IcmDevice, as: IcmDevice

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
    icm =
      IcmDevice.new(bus_name, bus_options)
      |> check_id()
      |> sw_reset()

    Process.sleep(250)

    set_sleep(icm, false)
    |> set_low_power(false)
    |> set_sample_mode(true, true, Registers.LpConfig.sample_mode_continuous())
    |> set_accel_full_scale(Registers.AccelConfig.gpm4())
    |> set_gyro_full_scale(Registers.GyroConfig1.dps2000())
    |> set_accel_dlpf_cfg(Registers.AccelConfig.acc_d473bw_n499bw())
    |> set_gyro_dlpf_cfg(Registers.GyroConfig1.gyr_d361bw4_n376bw5())
  end

  @spec check_id(struct()) :: struct()
  def check_id(icm) do
    icm = IcmDevice.set_bank(icm, 0)
    Logger.debug("icm: #{inspect(icm)}")
    <<who_am_i>> = IcmDevice.read(icm, Reg.agb0_reg_who_am_i(), 1)
    Logger.debug("whom am i: #{who_am_i}")
    if who_am_i != @icm_who_am_i, do: raise("WHO_AM_I returned: #{who_am_i}")
    icm
  end

  @spec sw_reset(struct()) :: struct()
  def sw_reset(icm) do
    {icm, pwr_mgmt_1_value} =
      get_new_register_value(
        icm,
        Reg.PwrMgmt1,
        %{Keys.device_reset() => 1},
        Reg.agb0_reg_pwr_mgmt_1(),
        0
      )

    # icm = Icm20948.IcmDevice.set_bank(icm, 0)
    # <<pwr_mgmt_1_value>> = IcmDevice.read(icm, Reg.agb0_reg_pwr_mgmt_1(), 1)

    # pwr_mgmt_1_value_new =
    #   Generic.create_struct(Reg.PwrMgmt1, pwr_mgmt_1_value)
    #   |> Map.put(Keys.device_reset(), 1)
    #   |> Generic.register_value()

    # Logger.debug("PwmMgmt1 value orig/new: #{pwr_mgmt_1_value}/#{pwr_mgmt_1_value_new}")
    Logger.debug("icm: #{inspect(icm)}")

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_sleep(struct(), boolean()) :: struct()
  def set_sleep(icm, sleep \\ false) do
    Logger.debug("Set sleep: #{sleep}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 0)
    # <<pwr_mgmt_1_value>> = IcmDevice.read(icm, Reg.agb0_reg_pwr_mgmt_1(), 1)
    # sleep_value = if sleep, do: 1, else: 0

    # pwr_mgmt_1_value_new =
    #   Generic.create_struct(Reg.PwrMgmt1, pwr_mgmt_1_value)
    #   |> Map.put(Keys.sleep(), sleep_value)
    #   |> Generic.register_value()

    {icm, pwr_mgmt_1_value} =
      get_new_register_value(
        icm,
        Reg.PwrMgmt1,
        %{Keys.sleep() => if(sleep, do: 1, else: 0)},
        Reg.agb0_reg_pwr_mgmt_1(),
        0
      )

    # Logger.debug("PwmMgmt1 value orig/new: #{pwr_mgmt_1_value}/#{pwr_mgmt_1_value_new}")
    Logger.debug("icm: #{inspect(icm)}")

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_low_power(struct(), boolean()) :: struct()
  def set_low_power(icm, low_power \\ false) do
    Logger.debug("Set low power: #{low_power}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 0)
    # <<pwr_mgmt_1_value>> = IcmDevice.read(icm, Reg.agb0_reg_pwr_mgmt_1(), 1)
    low_power_value = if low_power, do: 1, else: 0

    # pwr_mgmt_1_value_new =
    #   Generic.create_struct(Reg.PwrMgmt1, pwr_mgmt_1_value)
    #   |> Map.put(Keys.lp_en(), low_power_value)
    #   |> Generic.register_value()

    {icm, pwr_mgmt_1_value} =
      get_new_register_value(
        icm,
        Reg.PwrMgmt1,
        %{Keys.lp_en() => low_power_value},
        Reg.agb0_reg_pwr_mgmt_1(),
        0
      )

    # Logger.debug("PwmMgmt1 value orig/new: #{pwr_mgmt_1_value}/#{pwr_mgmt_1_value_new}")
    Logger.debug("icm: #{inspect(icm)}")

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_sample_mode(struct(), boolean(), boolean(), integer()) :: struct()
  def set_sample_mode(icm, use_accel, use_gyro, sample_mode) do
    Logger.debug("Set sample mode (accel/gyro/mode): #{use_accel}/#{use_gyro}/#{sample_mode}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 0)
    # <<lp_config_value>> = IcmDevice.read(icm, Reg.agb0_reg_lp_config(), 1)

    # lp_config = Generic.create_struct(Reg.LpConfig, lp_config_value)

    new_lp_config =
      if use_accel do
        %{Keys.accel_cycle() => sample_mode}
      else
        %{}
      end

    new_lp_config =
      if use_gyro do
        Map.put(new_lp_config, Keys.gyro_cycle(), sample_mode)
      else
        new_lp_config
      end

    # lp_config_value_new = Generic.register_value(lp_config)

    {icm, lp_config_value} =
      get_new_register_value(
        icm,
        Reg.LpConfig,
        new_lp_config,
        Reg.agb0_reg_lp_config(),
        0
      )

    # Logger.debug("LpConfig value orig/new: #{lp_config_value}/#{lp_config_value_new}")
    Logger.debug("icm: #{inspect(icm)}")

    write_and_verify(icm, Reg.agb0_reg_lp_config(), lp_config_value, "sample mode")
    icm
  end

  @spec set_accel_full_scale(struct(), integer()) :: struct()
  def set_accel_full_scale(icm, accel_fs_value) do
    Logger.debug("Set accel full scale: #{accel_fs_value}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 2)
    # <<accel_config_value>> = IcmDevice.read(icm, Reg.agb2_reg_accel_config(), 1)

    # accel_config =
    #   Generic.create_struct(Reg.AccelConfig, accel_config_value)
    #   |> Map.put(Keys.accel_fs_sel(), accel_fs_value)

    # accel_config_value_new = Generic.register_value(accel_config)

    # Logger.debug("AccelConfig value orig/new: #{accel_config_value}/#{accel_config_value_new}")

    {icm, accel_config_value} =
      get_new_register_value(
        icm,
        Reg.AccelConfig,
        %{Keys.accel_fs_sel() => accel_fs_value},
        Reg.agb2_reg_accel_config(),
        2
      )

    Logger.debug("icm: #{inspect(icm)}")

    write_and_verify(
      icm,
      Reg.agb2_reg_accel_config(),
      accel_config_value,
      "accel full scale"
    )

    icm
  end

  @spec set_gyro_full_scale(struct(), integer()) :: struct()
  def set_gyro_full_scale(icm, gyro_fs_value) do
    # Logger.debug("Set gyro full scale: #{gyro_fs_value}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 2)
    # <<gyro_config_value>> = IcmDevice.read(icm, Reg.agb2_reg_gyro_config_1(), 1)

    # gyro_config_1 =
    #   Generic.create_struct(Reg.GyroConfig1, gyro_config_value)
    #   |> Map.put(Keys.gyro_fs_sel(), gyro_fs_value)

    # gyro_config_1_value_new = Generic.register_value(gyro_config_1)

    # Logger.debug("Config value orig/new: #{gyro_config_value}/#{gyro_config_1_value_new}")
    {icm, gyro_config_1_value} =
      get_new_register_value(
        icm,
        Reg.GyroConfig1,
        %{Keys.gyro_fs_sel() => gyro_fs_value},
        Reg.agb2_reg_gyro_config_1(),
        2
      )

    Logger.debug("icm: #{inspect(icm)}")

    write_and_verify(
      icm,
      Reg.agb2_reg_gyro_config_1(),
      gyro_config_1_value,
      "gyro full scale"
    )

    icm
  end

  @spec set_accel_dlpf_cfg(struct(), integer()) :: struct()
  def set_accel_dlpf_cfg(icm, accel_dlpf_cfg) do
    Logger.debug("Set accel dlpf cfg : #{accel_dlpf_cfg}")
    # icm = Icm20948.IcmDevice.set_bank(icm, 2)
    # <<accel_config_value>> = IcmDevice.read(icm, Reg.agb2_reg_accel_config(), 1)

    # accel_config =
    #   Generic.create_struct(Reg.AccelConfig, accel_config_value)
    #   |> Map.put(Keys.accel_dlpfcfg(), accel_dlpf_cfg)

    # accel_config_value_new = Generic.register_value(accel_config)

    # Logger.debug("AccelConfig value orig/new: #{accel_config_value}/#{accel_config_value_new}")

    {icm, accel_config_value} =
      get_new_register_value(
        icm,
        Reg.AccelConfig,
        %{Keys.accel_dlpfcfg() => accel_dlpf_cfg},
        Reg.agb2_reg_accel_config(),
        2
      )

    Logger.debug("icm: #{inspect(icm)}")

    write_and_verify(
      icm,
      Reg.agb2_reg_accel_config(),
      accel_config_value,
      "accel dlpf cfg"
    )

    icm
  end

  @spec set_gyro_dlpf_cfg(struct(), integer()) :: struct()
  def set_gyro_dlpf_cfg(icm, gyro_dlpf_cfg) do
    Logger.debug("Set gyro dlpf cfg: #{gyro_dlpf_cfg}")

    # icm = Icm20948.IcmDevice.set_bank(icm, 2)
    # <<gyro_config_value>> = IcmDevice.read(icm, Reg.agb2_reg_gyro_config_1(), 1)

    # gyro_config_1 =
    #   Generic.create_struct(Reg.GyroConfig1, gyro_config_value)
    #   |> Map.put(Keys.gyro_dlpfcfg(), gyro_dlpf_cfg)

    # gyro_config_1_value_new = Generic.register_value(gyro_config_1)

    # Logger.debug("Config value orig/new: #{gyro_config_value}/#{gyro_config_1_value_new}")

    {icm, gyro_config_1_value} =
      get_new_register_value(
        icm,
        Reg.GyroConfig1,
        %{Keys.gyro_dlpfcfg() => gyro_dlpf_cfg},
        Reg.agb2_reg_gyro_config_1(),
        2
      )

    Logger.debug("icm: #{inspect(icm)}")

    write_and_verify(
      icm,
      Reg.agb2_reg_gyro_config_1(),
      gyro_config_1_value,
      "gyro full scale"
    )

    icm
  end

  @spec request_check_id() :: atom
  def request_check_id() do
    GenServer.cast(__MODULE__, :check_id)
  end

  @spec write_and_verify(struct(), integer(), integer(), binary()) :: atom()
  def write_and_verify(icm, register, value, register_name \\ "") do
    IcmDevice.write(icm, register, <<value>>)
    verify_register(icm, register, value, register_name)
  end

  @spec verify_register(struct(), integer(), integer(), binary()) :: atom()
  def verify_register(icm, register, expected_value, register_name) do
    <<actual_value>> = IcmDevice.read(icm, register, 1)

    if actual_value != expected_value do
      raise "Error setting #{register_name} (exp/act):#{expected_value}/#{actual_value}"
    end

    :ok
  end

  @spec get_new_register_value(struct(), module(), map(), integer(), integer()) :: tuple()
  def get_new_register_value(icm, struct_module, updated_struct_map, register, register_bank) do
    icm = Icm20948.IcmDevice.set_bank(icm, register_bank)
    <<register_value>> = IcmDevice.read(icm, register, 1)

    register_struct =
      Generic.create_struct(struct_module, register_value)
      |> Map.merge(updated_struct_map)

    new_register_value = Generic.register_value(register_struct)
    Logger.debug("#{Module.split(struct_module)|>List.last()} value old/new: #{register_value}/#{new_register_value}")
    {icm, new_register_value}
  end
end
