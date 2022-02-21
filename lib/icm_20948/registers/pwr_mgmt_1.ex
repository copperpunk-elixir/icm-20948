defmodule Icm20948.Registers.PwrMgmt1 do
  require Icm20948.Registers.Keys, as: Keys

  defstruct [
    Keys.device_reset(),
    Keys.sleep(),
    Keys.lp_en(),
    Keys.reserved_0(),
    Keys.temp_dis(),
    Keys.clksel()
  ]

  def keys(),
    do: [
      Keys.device_reset(),
      Keys.sleep(),
      Keys.lp_en(),
      Keys.reserved_0(),
      Keys.temp_dis(),
      Keys.clksel()
    ]

  def bits(), do: [1, 1, 1, 1, 1, 3]
end
