defmodule Icm20948.Registers.Generic do
  require Logger
  use Bitwise

  def create_struct(struct_module, value) do
    keys = apply(struct_module, :keys, [])
    bit_list = apply(struct_module, :bits, [])
    value_base2_binary = Integer.to_string(value, 2) |> String.pad_leading(8, "0")

    {struct_map, _} =
      Enum.reduce(Enum.zip(keys, bit_list), {%{}, value_base2_binary}, fn {key, bits},
                                                                          {map_acc,
                                                                           binary_remaining} ->
        {bits_value, binary_remaining} = String.split_at(binary_remaining, bits)
        {Map.put(map_acc, key, String.to_integer(bits_value, 2)), binary_remaining}
      end)

    struct(struct_module, struct_map)
  end

  def put_value(register_struct, key, value) do
    struct_module = register_struct.__struct__
    keys = apply(struct_module, :keys, [])
    bits_list = apply(struct_module, :bits, [])
    num_bits = Enum.zip(keys, bits_list) |> Keyword.fetch!(key)
    max_value = ViaUtils.Math.integer_power(2, num_bits) - 1

    if value > max_value,
      do: raise("#{key} occupies #{num_bits} bit(s) and cannot be larger than #{max_value}")

    Map.put(register_struct, key, value)
  end

  def register_value(register_struct) do
    struct_module = register_struct.__struct__
    keys = apply(struct_module, :keys, [])
    bits_list = apply(struct_module, :bits, [])

    {byte_value, _} =
    Enum.reduce(Enum.zip(keys, bits_list) |> Enum.reverse(), {0, 0}, fn {key, bits},
                                                                        {acc, index} ->
      value = Map.fetch!(register_struct, key)
      {acc + (value <<< index), index + bits}
    end)
    byte_value
  end
end
