defmodule Liquidacion do

  #Tarifa por kilo
  @tarifa_por_kilo 1000.0

  #Ajuste por porcentaje de verdes
  @menor_2_porciento 1.05
  @entre_2_y_5_porciento 0.0
  @entre_5_y_10_porciento 0.9
  @mayor_a_10_porciento 0.7

  #Bonificacion por 120 kilogramos o mas >=
  @bonificacion_120_kg 8_000.0

  #Descuento de alimentacion por dia trabajado (al menos un pesaje valido)
  @descuento_alimentacion 12_000

  def valor_pesaje(kilos, porcentaje_verdes) do
    kilos*@tarifa_por_kilo*ajuste(porcentaje_verdes)
  end

  def ajuste(porcentaje_verdes) when porcentaje_verdes in 1..2, do: @menor_2_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes in 2..5, do: @entre_2_y_5_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes in 5..10, do: @@entre_5_y_10_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes > 10, do: @mayor_a_10_porciento

end
