defmodule Liquidacion do
  @moduledoc """
  Módulo Liquidacion con reglas de 2 a 5
  2- valor del pesaje
  3- Bonificacion por productividad
  4- descuento de alimentacion
  5- liquidacion total
  - autores: Juan Camilo Ortiz Garcia, Juan Idarraga, Juan Pablo Larrea
  - fecha: Junio 2026
  - licencia: GNU GPL v3
  """

  #Tarifa por kilo
  @tarifa_por_kilo 1000.0

  #Ajuste por porcentaje de verdes
  @menor_2_porciento 1.05
  @entre_2_y_5_porciento 1.0
  @entre_5_y_10_porciento 0.9
  @mayor_a_10_porciento 0.7

  #Bonificacion por 120 kilogramos o mas >=
  @bonificacion_120_kg 8_000.0

  #Descuento de alimentacion por dia trabajado (al menos un pesaje valido)
  @descuento_alimentacion 12_000.0

  #Calcula y devuelve el valor del pesaje considerando el porcentaje de verdes
  def valor_pesaje(kilos, porcentaje_verdes) do
    kilos*@tarifa_por_kilo*ajuste(porcentaje_verdes)
  end

  #Funcion ajuste devuelve el multiplicador para calcular por porcentaje de verdes
  def ajuste(porcentaje_verdes) when porcentaje_verdes <= 2, do: @menor_2_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <=5, do: @entre_2_y_5_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <=10, do: @entre_5_y_10_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes > 10, do: @mayor_a_10_porciento

end
