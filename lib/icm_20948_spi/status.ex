defmodule Icm20948Spi.Status do
  defmacro ok(), do: 0x00
  defmacro error(), do: 0x01
  defmacro not_impl(), do: 0x02
  defmacro param_err(), do: 0x03
  defmacro wrong_id(), do: 0x04
  defmacro invalid_sensor(), do: 0x05
  defmacro no_data(), do: 0x06
  defmacro sensor_not_supported(), do: 0x07
  defmacro dmp_not_supported(), do: 0x08
  defmacro dmp_verify_fail(), do: 0x09
  defmacro fifo_no_data_available(), do: 0x0A
  defmacro fifo_incomplete_data(), do: 0x0B
  defmacro fifo_more_data_available(), do: 0x0C
  defmacro unrecognized_dmp_header(), do: 0x0D
  defmacro unrecognized_dmp_header_2(), do: 0x0E
  defmacro invalid_dmp_register(), do: 0x0F
  defmacro num(), do: 0x10
  defmacro unknown(), do: 0x11
end
