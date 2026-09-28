defmodule Programa do
  @tarifa_por_kilo 1000
  @meta_diaria_finca_kilos 400
  @dias_de_cosecha [1,2,3,4,5,6]
  @maximo_kilo_por_pesaje 250
  @kilo_diario_bonificacion 120
  @descuento_de_alimentacion 12000
  @bonificacion_diaria_productividad 8000
  @bonificacion_calidad 0.05
  @descuento_calidad_hasta_10 0.10
  @descuento_calidad_mayor_10 0.30


  def main do

  end

  def errores_validacion_pesajes do
    {:error, :recolector_desconocido} #El código del recolector existe
    {:error, :lote_desconocido} #El lote existe
    {:error, :dia_invalido} #El día es un entero entre 1 y 6
    {:error, :kilos_fuera_de_rango} #Los kilos son un número mayor que 0 y como máximo 250
    {:error, :porcentaje_invalido} #El porcentaje de verdes es un número entre 0 y 100
  end

end
