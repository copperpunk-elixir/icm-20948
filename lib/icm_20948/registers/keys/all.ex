  # defmacro pwr_mgmt_1(),
  #   do: [device_reset(), sleep(), lp_en(), reserved_0(), temp_dis(), clksel()]

  # defmacro lp_config(),
  #   do: [reserved_0(), i2c_mst_cycle(), accel_cycle(), gyro_cycle(), reserved_1()]

# defmacro accel_config(), do: [reserved_0(), accel_dlpfcfg(), accel_fs_sel(), accel_fchoice()]
  # defmacro gyro_config_1(), do: [reserved_0(), gyro_dlpfcfg(), gyro_fs_sel(), gyro_fchoice()]
  # defmacro accel_smplrt_div_1(), do: [reserved_0(), accel_smplrt_div_msb()]
  # defmacro accel_smplrt_div_2(), do: [accel_smplrt_div_lsb()]
  # defmacro gyro_smplrt_div(), do: [gyro_smplrt_div()]
