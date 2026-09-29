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

  #atributo de los kilos a alcanzar para obtener la bonificacion por kg
  @kilos_para_bonificacion 120

  #Bonificacion por 120 kilogramos o mas >=
  @bonificacion_120_kg 8_000.0

  #Descuento de alimentacion por dia trabajado (al menos un pesaje valido)
  @descuento_alimentacion 12_000.0

  #Calcula y devuelve el valor del pesaje considerando el porcentaje de verdes
  def valor_pesaje(kilos, porcentaje_verdes) do
    kilos*@tarifa_por_kilo*ajuste(porcentaje_verdes)
  end

  #Funcion ajuste devuelve el multiplicador para calcular el valor del pesaje definido porcentaje el de verdes
  def ajuste(porcentaje_verdes) when porcentaje_verdes <= 2, do: @menor_2_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <=5, do: @entre_2_y_5_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <=10, do: @entre_5_y_10_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes > 10, do: @mayor_a_10_porciento

  #Funcion para devolver la bonificacion dependiendo el los kilos del dia
  def bonificacion(kilos) when kilos >= @kilos_para_bonificacion, do: @bonificacion_120_kg
  def bonificacion(_kilos), do: 0.0

  #Funcion para devolver el numero a descontar segun la alimentacion y los dias trabajados
  def descuento_alimentacion(true, dias_trabajados), do: dias_trabajados*@descuento_alimentacion
  def descuento_alimentacion(false, _dias_trabajados), do: 0.0

  #Funcion de liquidacion total
  #%{codigo: "R01", nombre: "Luz Marina Ospina", alimentacion: true},
  #%{recolector: "R01", lote: "L3", dia: 1, kilos: 40, verdes: 5},
  def liquidar(recolector, pesajes_validos) do

  end
end
