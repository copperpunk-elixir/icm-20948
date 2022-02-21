defmodule Icm20948.Registers.Keys do
  # Generic
  defmacro reserved_0(), do: :reserved_0
  defmacro reserved_1(), do: :reserved_1
  # PwrMgmt1
  defmacro clksel(), do: :clksel
  defmacro temp_dis(), do: :temp_dis
  defmacro lp_en(), do: :lp_en
  defmacro sleep(), do: :sleep
  defmacro device_reset(), do: :device_reset
  # LP Config
  defmacro gyro_cycle(), do: :gyro_cycle
  defmacro accel_cycle(), do: :accel_cycle
  defmacro i2c_mst_cycle(), do: :i2c_mst_cycle
  # Accel Config
  defmacro accel_fchoice(), do: :accel_fchoice
  defmacro accel_fs_sel(), do: :accel_fs_sel
  defmacro accel_dlpfcfg(), do: :accel_dlpfcfg
  # Gyro Config 1
  defmacro gyro_fchoice(), do: :gyro_fchoice
  defmacro gyro_fs_sel(), do: :gyro_fs_sel
  defmacro gyro_dlpfcfg(), do: :gyro_dlpfcfg

  defmacro pwr_mgmt_1(),
    do: [device_reset(), sleep(), lp_en(), reserved_0(), temp_dis(), clksel()]

  defmacro lp_config(),
    do: [reserved_0(), i2c_mst_cycle(), accel_cycle(), gyro_cycle(), reserved_1()]

  defmacro accel_config(), do: [reserved_0(), accel_dlpfcfg(), accel_fs_sel(), accel_fchoice()]
  defmacro gyro_config_1(), do: [reserved_0(), gyro_dlpfcfg(), gyro_fs_sel(), gyro_fchoice()]
end
