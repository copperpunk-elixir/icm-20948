defmodule Icm20948 do
  use GenServer
  use Bitwise
  require Logger
  require Icm20948.Registers, as: Reg
  require Icm20948.Registers.Keys, as: Keys
  alias Icm20948.Registers.Generic, as: Generic
  alias Icm20948.IcmDevice, as: IcmDevice

  @accel_x_raw :accel_x_raw
  @accel_y_raw :accel_y_raw
  @accel_z_raw :accel_z_raw
  @gyro_x_raw :gyro_x_raw
  @gyro_y_raw :gyro_y_raw
  @gyro_z_raw :gyro_z_raw
  @temp_raw :temp_raw

  @icm_who_am_i 0xEA
  def go() do
    start_link_spidriver()
  end

  def start_link_spi() do
    config = [bus_name: "spidev0.0", bus_options: [speed_hz: 1_000_000]]
    start_link(config)
  end

  def start_link_spidriver() do
    RingLogger.attach()
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
    ViaUtils.Process.start_loop(self(), 5, :check_for_data)
    {:noreply, %{state | icm: icm}}
  end

  @impl GenServer
  def handle_info(:check_for_data, state) do
    Logger.debug("check")
    {icm, data_ready} = is_data_ready(state.icm)

    icm =
      if data_ready do
        # Logger.debug("Data is ready")
        {icm, data_raw} = read_accel_gyro_temp(icm)

        %{
          @accel_x_raw => accel_x_raw,
          @accel_y_raw => accel_y_raw,
          @accel_z_raw => accel_z_raw,
          @gyro_x_raw => gyro_x_raw,
          @gyro_y_raw => gyro_y_raw,
          @gyro_z_raw => gyro_z_raw,
          @temp_raw => temp_raw
        } = data_raw

        Logger.debug("accel raw: #{accel_x_raw}/#{accel_y_raw}/#{accel_z_raw}")
        # Logger.debug("gyro raw: #{gyro_x_raw}/#{gyro_y_raw}/#{gyro_z_raw}")
        # Logger.debug("temp raw: #{temp_raw}")
        icm
      else
        Logger.debug(".")
        icm
      end

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
    |> set_sample_mode(true, true, Reg.LpConfig.sample_mode_continuous())
    |> set_accel_full_scale(Reg.AccelConfig.gpm4())
    |> set_gyro_full_scale(Reg.GyroConfig1.dps2000())
    |> set_accel_dlpf_cfg(Reg.AccelConfig.acc_d473bw_n499bw())
    |> set_gyro_dlpf_cfg(Reg.GyroConfig1.gyr_d361bw4_n376bw5())
    |> set_accel_dlpf_enable(true)
    |> set_gyro_dlpf_enable(true)
    |> set_accel_sample_rate(100)
    |> set_gyro_sample_rate(100)
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

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_sleep(struct(), boolean()) :: struct()
  def set_sleep(icm, sleep \\ false) do
    Logger.debug("Set sleep: #{sleep}")

    {icm, pwr_mgmt_1_value} =
      get_new_register_value(
        icm,
        Reg.PwrMgmt1,
        %{Keys.sleep() => bool_to_int(sleep)},
        Reg.agb0_reg_pwr_mgmt_1(),
        0
      )

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_low_power(struct(), boolean()) :: struct()
  def set_low_power(icm, low_power \\ false) do
    Logger.debug("Set low power: #{low_power}")
    low_power_value = if low_power, do: 1, else: 0

    {icm, pwr_mgmt_1_value} =
      get_new_register_value(
        icm,
        Reg.PwrMgmt1,
        %{Keys.lp_en() => low_power_value},
        Reg.agb0_reg_pwr_mgmt_1(),
        0
      )

    IcmDevice.write(icm, Reg.agb0_reg_pwr_mgmt_1(), <<pwr_mgmt_1_value>>)
    icm
  end

  @spec set_sample_mode(struct(), boolean(), boolean(), integer()) :: struct()
  def set_sample_mode(icm, use_accel, use_gyro, sample_mode) do
    Logger.debug("Set sample mode (accel/gyro/mode): #{use_accel}/#{use_gyro}/#{sample_mode}")

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

    set_register_value(
      icm,
      Reg.LpConfig,
      new_lp_config,
      Reg.agb0_reg_lp_config(),
      0,
      "sample mode"
    )
  end

  @spec set_accel_full_scale(struct(), integer()) :: struct()
  def set_accel_full_scale(icm, accel_fs_value) do
    Logger.debug("Set accel full scale: #{accel_fs_value}")

    set_register_value(
      icm,
      Reg.AccelConfig,
      %{Keys.accel_fs_sel() => accel_fs_value},
      Reg.agb2_reg_accel_config(),
      2,
      "accel full scale"
    )
  end

  @spec set_gyro_full_scale(struct(), integer()) :: struct()
  def set_gyro_full_scale(icm, gyro_fs_value) do
    Logger.debug("Set gyro full scale: #{gyro_fs_value}")

    set_register_value(
      icm,
      Reg.GyroConfig1,
      %{Keys.gyro_fs_sel() => gyro_fs_value},
      Reg.agb2_reg_gyro_config_1(),
      2,
      "gyro full scale"
    )
  end

  @spec set_accel_dlpf_cfg(struct(), integer()) :: struct()
  def set_accel_dlpf_cfg(icm, accel_dlpf_cfg) do
    Logger.debug("Set accel dlpf cfg : #{accel_dlpf_cfg}")

    set_register_value(
      icm,
      Reg.AccelConfig,
      %{Keys.accel_dlpfcfg() => accel_dlpf_cfg},
      Reg.agb2_reg_accel_config(),
      2,
      "accel dlpf cfg"
    )
  end

  @spec set_gyro_dlpf_cfg(struct(), integer()) :: struct()
  def set_gyro_dlpf_cfg(icm, gyro_dlpf_cfg) do
    Logger.debug("Set gyro dlpf cfg: #{gyro_dlpf_cfg}")

    set_register_value(
      icm,
      Reg.GyroConfig1,
      %{Keys.gyro_dlpfcfg() => gyro_dlpf_cfg},
      Reg.agb2_reg_gyro_config_1(),
      2,
      "gyro dlpf cfg"
    )
  end

  @spec set_accel_dlpf_enable(struct(), boolean()) :: struct()
  def set_accel_dlpf_enable(icm, enable_accel_dlpf) do
    Logger.debug("Set accel dlpf enable : #{enable_accel_dlpf}")

    set_register_value(
      icm,
      Reg.AccelConfig,
      %{Keys.accel_fchoice() => bool_to_int(enable_accel_dlpf)},
      Reg.agb2_reg_accel_config(),
      2,
      "accel dlpf enable"
    )
  end

  @spec set_gyro_dlpf_enable(struct(), boolean()) :: struct()
  def set_gyro_dlpf_enable(icm, enable_gyro_dlpf) do
    Logger.debug("Set gyro dlpf enable: #{enable_gyro_dlpf}")

    set_register_value(
      icm,
      Reg.GyroConfig1,
      %{Keys.gyro_fchoice() => bool_to_int(enable_gyro_dlpf)},
      Reg.agb2_reg_gyro_config_1(),
      2,
      "gyro dlpf enable"
    )
  end

  @spec set_accel_sample_rate(struct(), number()) :: struct()
  def set_accel_sample_rate(icm, accel_sample_rate) do
    Logger.debug("Set accel sample rate (desired): #{accel_sample_rate}")
    Logger.debug("Accel ODR = 1125/(1+accel_sample_rate_div)")
    if accel_sample_rate > 1125, do: raise("Accel sample rate must be <= 1125Hz")
    sample_rate_div = ceil(1125 / accel_sample_rate - 1)
    actual_sample_rate = 1125 / (1 + sample_rate_div)
    Logger.debug("accel smplrt_div: #{sample_rate_div}")
    Logger.debug("Actual accel sample rate: #{actual_sample_rate}")

    div1 = sample_rate_div >>> 8 &&& 0xFF
    div2 = sample_rate_div &&& 0xFF

    Logger.debug("div1/div2: #{div1}/#{div2}")

    set_register_value(
      icm,
      Reg.AccelSmplrtDiv1,
      %{Keys.accel_smplrt_div_msb() => div1},
      Reg.agb2_reg_accel_smplrt_div_1(),
      2,
      "accel smplrt div 1"
    )

    set_register_value(
      icm,
      Reg.AccelSmplrtDiv2,
      %{Keys.accel_smplrt_div_lsb() => div2},
      Reg.agb2_reg_accel_smplrt_div_2(),
      2,
      "accel smplrt div 2"
    )
  end

  @spec set_gyro_sample_rate(struct(), number()) :: struct()
  def set_gyro_sample_rate(icm, gyro_sample_rate) do
    Logger.debug("Set gyro sample rate (desired): #{gyro_sample_rate}")
    Logger.debug("Gyro ODR = 1100/(1+gyro_sample_rate_div)")
    if gyro_sample_rate > 1100, do: raise("Gyro sample rate must be <= 1100")
    sample_rate_div = ceil(1100 / gyro_sample_rate - 1)

    sample_rate_div =
      if sample_rate_div > 255 do
        Logger.warn("Gyro sample rate div must be <= 255. Setting to 255.")
        255
      else
        sample_rate_div
      end

    actual_sample_rate = 1100 / (1 + sample_rate_div)
    Logger.debug("gyro smplrt_div: #{sample_rate_div}")
    Logger.debug("Actual gyro sample rate: #{actual_sample_rate}")

    set_register_value(
      icm,
      Reg.GyroSmplrtDiv,
      %{Keys.gyro_smplrt_div() => sample_rate_div},
      Reg.agb2_reg_gyro_smplrt_div(),
      2,
      "gyro smplrt div"
    )
  end

  @spec is_data_ready(struct()) :: tuple()
  def is_data_ready(icm) do
    {icm, int_status_1} = get_register_struct(icm, Reg.IntStatus1, Reg.agb0_reg_int_status_1(), 0)

    {icm, Map.fetch!(int_status_1, Keys.raw_data_0_rdy_int()) == 1}
  end

  @spec read_accel_gyro_temp(struct()) :: tuple()
  def read_accel_gyro_temp(icm) do
    icm = Icm20948.IcmDevice.set_bank(icm, 0)

    <<accel_x::binary-size(2), accel_y::binary-size(2), accel_z::binary-size(2),
      gyro_x::binary-size(2), gyro_y::binary-size(2), gyro_z::binary-size(2),
      temp::binary-size(2)>> =
      IcmDevice.read(icm, Reg.agb0_reg_accel_xout_h(), 14)

    raw_output = %{
      @accel_x_raw => ViaUtils.Math.twos_comp_16_bin(accel_x),
      @accel_y_raw => ViaUtils.Math.twos_comp_16_bin(accel_y),
      @accel_z_raw => ViaUtils.Math.twos_comp_16_bin(accel_z),
      @gyro_x_raw => ViaUtils.Math.twos_comp_16_bin(gyro_x),
      @gyro_y_raw => ViaUtils.Math.twos_comp_16_bin(gyro_y),
      @gyro_z_raw => ViaUtils.Math.twos_comp_16_bin(gyro_z),
      @temp_raw => ViaUtils.Math.twos_comp_16_bin(temp)
    }

    {icm, raw_output}
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

  @spec get_register_struct(struct(), module(), integer(), integer()) :: tuple()
  def get_register_struct(icm, struct_module, register, register_bank) do
    icm = Icm20948.IcmDevice.set_bank(icm, register_bank)
    <<register_value>> = IcmDevice.read(icm, register, 1)

    # Logger.debug("#{Module.split(struct_module) |> List.last()} currnet value: #{register_value}")
    register_struct = Generic.create_struct(struct_module, register_value)
    {icm, register_struct}
  end

  @spec get_new_register_value(struct(), module(), map(), integer(), integer()) :: tuple()
  def get_new_register_value(icm, struct_module, updated_struct_map, register, register_bank) do
    {icm, register_struct} = get_register_struct(icm, struct_module, register, register_bank)

    new_register_value = Generic.register_value(Map.merge(register_struct, updated_struct_map))

    Logger.debug("#{Module.split(struct_module) |> List.last()} new value: #{new_register_value}")

    {icm, new_register_value}
  end

  @spec set_register_value(struct, module(), map(), integer(), integer(), binary()) :: struct()
  def set_register_value(icm, register_module, new_values, register, bank, id \\ "") do
    {icm, struct_value} =
      get_new_register_value(
        icm,
        register_module,
        new_values,
        register,
        bank
      )

    write_and_verify(
      icm,
      register,
      struct_value,
      id
    )

    icm
  end

  @spec bool_to_int(boolean()) :: integer()
  def bool_to_int(value) do
    if value, do: 1, else: 0
  end
end
