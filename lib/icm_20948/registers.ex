defmodule Icm20948.Registers do
  defmacro reg_bank_sel(), do: 0x7F
  # Gyroscope and Accelerometer
  # User Bank 0
  defmacro agb0_reg_who_am_i(), do: 0x00
  defmacro agb0_reg_lpf(), do: 0x01
  defmacro agb0_reg_user_ctrl(), do: 0x03
  defmacro agb0_reg_lp_config(), do: 0x05
  defmacro agb0_reg_pwr_mgmt_1(), do: 0x06
  defmacro agb0_reg_pwr_mgmt_2(), do: 0x07
  defmacro agb0_int_pin_config(), do: 0x0F
  defmacro agb0_int_enable(), do: 0x10
  defmacro agb0_int_enable_1(), do: 0x11
  defmacro agb0_int_enable_2(), do: 0x12
  defmacro agb0_int_enable_3(), do: 0x13
  # AGB0_REG_I2C_MST_STATUS = 0x17,
  # AGB0_REG_DMP_INT_STATUS,
  defmacro agb0_reg_int_status(), do: 0x19
  defmacro agb0_reg_int_status_1(), do: 0x1A
  defmacro agb0_reg_int_status_2(), do: 0x1B
  defmacro agb0_reg_int_status_3(), do: 0x1C
  defmacro agb0_reg_single_fifo_priority_sel(), do: 0x26

  #  // Break
  #   AGB0_REG_DELAY_TIMEH = 0x28,
  #   AGB0_REG_DELAY_TIMEL,
  #   // Break
  #   AGB0_REG_ACCEL_XOUT_H = 0x2D,
  #   AGB0_REG_ACCEL_XOUT_L,
  #   AGB0_REG_ACCEL_YOUT_H,
  #   AGB0_REG_ACCEL_YOUT_L,
  #   AGB0_REG_ACCEL_ZOUT_H,
  #   AGB0_REG_ACCEL_ZOUT_L,
  #   AGB0_REG_GYRO_XOUT_H,
  #   AGB0_REG_GYRO_XOUT_L,
  #   AGB0_REG_GYRO_YOUT_H,
  #   AGB0_REG_GYRO_YOUT_L,
  #   AGB0_REG_GYRO_ZOUT_H,
  #   AGB0_REG_GYRO_ZOUT_L,
  #   AGB0_REG_TEMP_OUT_H,
  #   AGB0_REG_TEMP_OUT_L,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_00,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_01,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_02,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_03,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_04,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_05,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_06,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_07,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_08,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_09,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_10,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_11,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_12,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_13,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_14,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_15,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_16,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_17,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_18,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_19,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_20,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_21,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_22,
  #   AGB0_REG_EXT_PERIPH_SENS_DATA_23,
  #   // Break
  #   AGB0_REG_TEMP_CONFIG = 0x53,
  #   // Break
  #   AGB0_REG_FIFO_EN_1 = 0x66,
  #   AGB0_REG_FIFO_EN_2,
  #   AGB0_REG_FIFO_RST,
  #   AGB0_REG_FIFO_MODE,
  #   // Break
  #   AGB0_REG_FIFO_COUNT_H = 0x70,
  #   AGB0_REG_FIFO_COUNT_L,
  #   AGB0_REG_FIFO_R_W,
  #   // Break
  #   AGB0_REG_DATA_RDY_STATUS = 0x74,
  #   AGB0_REG_HW_FIX_DISABLE,
  #   AGB0_REG_FIFO_CFG,
  #   // Break
  #   AGB0_REG_MEM_START_ADDR = 0x7C, // Hmm, Invensense thought they were sneaky not listing these locations on the datasheet...
  #   AGB0_REG_MEM_R_W = 0x7D,        // These three locations seem to be able to access some memory within the device
  #   AGB0_REG_MEM_BANK_SEL = 0x7E,   // And that location is also where the DMP image gets loaded
  #   AGB0_REG_REG_BANK_SEL = 0x7F,

  #   // Bank 1
  #   AGB1_REG_SELF_TEST_X_GYRO = 0x02,
  #   AGB1_REG_SELF_TEST_Y_GYRO,
  #   AGB1_REG_SELF_TEST_Z_GYRO,
  #   // Break
  #   AGB1_REG_SELF_TEST_X_ACCEL = 0x0E,
  #   AGB1_REG_SELF_TEST_Y_ACCEL,
  #   AGB1_REG_SELF_TEST_Z_ACCEL,
  #   // Break
  #   AGB1_REG_XA_OFFS_H = 0x14,
  #   AGB1_REG_XA_OFFS_L,
  #   // Break
  #   AGB1_REG_YA_OFFS_H = 0x17,
  #   AGB1_REG_YA_OFFS_L,
  #   // Break
  #   AGB1_REG_ZA_OFFS_H = 0x1A,
  #   AGB1_REG_ZA_OFFS_L,
  #   // Break
  #   AGB1_REG_TIMEBASE_CORRECTION_PLL = 0x28,
  #   // Break
  #   AGB1_REG_REG_BANK_SEL = 0x7F,

  #   // Bank 2
  defmacro agb2_reg_gyro_smplrt_div(), do: 0x00
  defmacro agb2_reg_gyro_config_1(), do: 0x01
  #   AGB2_REG_GYRO_CONFIG_2,
  #   AGB2_REG_XG_OFFS_USRH,
  #   AGB2_REG_XG_OFFS_USRL,
  #   AGB2_REG_YG_OFFS_USRH,
  #   AGB2_REG_YG_OFFS_USRL,
  #   AGB2_REG_ZG_OFFS_USRH,
  #   AGB2_REG_ZG_OFFS_USRL,
  #   AGB2_REG_ODR_ALIGN_EN,
  #   // Break
  defmacro agb2_reg_accel_smplrt_div_1(), do: 0x10
  defmacro agb2_reg_accel_smplrt_div_2(), do: 0x11
  #   AGB2_REG_ACCEL_INTEL_CTRL,
  #   AGB2_REG_ACCEL_WOM_THR,
  defmacro agb2_reg_accel_config(), do: 0x14
  #   AGB2_REG_ACCEL_CONFIG_2,
  #   // Break
  #   AGB2_REG_PRS_ODR_CONFIG = 0x20,
  #   // Break
  #   AGB2_REG_PRGM_START_ADDRH = 0x50,
  #   AGB2_REG_PRGM_START_ADDRL,
  #   AGB2_REG_FSYNC_CONFIG,
  #   AGB2_REG_TEMP_CONFIG,
  #   AGB2_REG_MOD_CTRL_USR,
  #   // Break
  #   AGB2_REG_REG_BANK_SEL = 0x7F,

  #   // Bank 3
  #   AGB3_REG_I2C_MST_ODR_CONFIG = 0x00,
  #   AGB3_REG_I2C_MST_CTRL,
  #   AGB3_REG_I2C_MST_DELAY_CTRL,
  #   AGB3_REG_I2C_PERIPH0_ADDR,
  #   AGB3_REG_I2C_PERIPH0_REG,
  #   AGB3_REG_I2C_PERIPH0_CTRL,
  #   AGB3_REG_I2C_PERIPH0_DO,
  #   AGB3_REG_I2C_PERIPH1_ADDR,
  #   AGB3_REG_I2C_PERIPH1_REG,
  #   AGB3_REG_I2C_PERIPH1_CTRL,
  #   AGB3_REG_I2C_PERIPH1_DO,
  #   AGB3_REG_I2C_PERIPH2_ADDR,
  #   AGB3_REG_I2C_PERIPH2_REG,
  #   AGB3_REG_I2C_PERIPH2_CTRL,
  #   AGB3_REG_I2C_PERIPH2_DO,
  #   AGB3_REG_I2C_PERIPH3_ADDR,
  #   AGB3_REG_I2C_PERIPH3_REG,
  #   AGB3_REG_I2C_PERIPH3_CTRL,
  #   AGB3_REG_I2C_PERIPH3_DO,
  #   AGB3_REG_I2C_PERIPH4_ADDR,
  #   AGB3_REG_I2C_PERIPH4_REG,
  #   AGB3_REG_I2C_PERIPH4_CTRL,
  #   AGB3_REG_I2C_PERIPH4_DO,
  #   AGB3_REG_I2C_PERIPH4_DI,
  #   // Break
  #   AGB3_REG_REG_BANK_SEL = 0x7F,
end
