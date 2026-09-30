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

  # Tarifa por kilo
  @tarifa_por_kilo 1000.0

  # Ajuste por porcentaje de verdes
  @menor_2_porciento 1.05
  @entre_2_y_5_porciento 1.0
  @entre_5_y_10_porciento 0.9
  @mayor_a_10_porciento 0.7

  # Atributo de los kilos a alcanzar para obtener la bonificacion por kg
  @kilos_para_bonificacion 120.0

  # Bonificacion por 120 kilogramos o mas >=
  @bonificacion_120_kg 8_000.0

  # Descuento de alimentacion por dia trabajado (al menos un pesaje valido)
  @descuento_alimentacion 12_000.0

  # Calcula y devuelve el valor del pesaje multiplicando los kilos por la tarifa del Kg por el ajuste por porcentaje de verdes
  def valor_pesaje(kilos, porcentaje_verdes) do
    kilos * @tarifa_por_kilo * ajuste(porcentaje_verdes)
  end

  # Funcion ajuste devuelve el multiplicador para calcular el valor del pesaje definido porcentaje el de verdes
  def ajuste(porcentaje_verdes) when porcentaje_verdes <= 2, do: @menor_2_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <= 5, do: @entre_2_y_5_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes <= 10, do: @entre_5_y_10_porciento
  def ajuste(porcentaje_verdes) when porcentaje_verdes > 10, do: @mayor_a_10_porciento

  # Funcion para devolver la bonificacion dependiendo el los kilos del dia
  def bonificacion(kilos) when kilos >= @kilos_para_bonificacion, do: @bonificacion_120_kg
  def bonificacion(_kilos), do: 0.0

  # Funcion para devolver el numero a descontar segun la alimentacion y los dias trabajados
  def descuento_alimentacion(true, dias_trabajados), do: dias_trabajados * @descuento_alimentacion
  def descuento_alimentacion(false, _dias_trabajados), do: 0.0

  # Funcion de liquidacion total
  def liquidar(recolector, pesajes_validos) do
    # se crea una "lista_kilos" recibe solo los kilos del pesaje
    lista_kilos = Enum.map(pesajes_validos, fn pesaje -> pesaje.kilos end)

    # Esta funcion suma la lista de Kg
    kilos_totales = Enum.sum(lista_kilos)

    # Esta funcion calcula la lista de valores por cada pesaje usando la funcion de valor_pesaje()
    lista_de_valores =
      Enum.map(pesajes_validos, fn pesaje -> valor_pesaje(pesaje.kilos, pesaje.verdes) end)

    # Esta funcion calcula la sumatoria de los valores del pesaje
    bruto = Enum.sum(lista_de_valores)

    kilos_por_dia = sumar_kilos_por_dia(pesajes_validos)

    lista_kilos_por_dia = Map.values(kilos_por_dia)

    # Lista con la bonificación de cada día, por ejemplo [8000.0, 0.0]
    lista_bonificaciones =
      Enum.map(lista_kilos_por_dia, fn kilos_del_dia -> bonificacion(kilos_del_dia) end)

    # Un solo número: la suma de las bonificaciones
    bonificaciones = Enum.sum(lista_bonificaciones)

    # Esta funcion calcula los dias trabajados
    dias_trabajados = map_size(kilos_por_dia)

    alimentacion = descuento_alimentacion(recolector.alimentacion, dias_trabajados)

    neto = bruto + bonificaciones - alimentacion

    %{
      codigo: recolector.codigo,
      nombre: recolector.nombre,
      kilos: kilos_totales,
      bruto: bruto,
      bonificaciones: bonificaciones,
      alimentacion: alimentacion,
      neto: neto,
      kilos_por_dia: kilos_por_dia
    }
  end

  # Funcion que calcula los kilos por dia, extrayendo de pesajes_validos
  def sumar_kilos_por_dia(pesajes_validos) do
    Enum.reduce(pesajes_validos, %{}, fn pesaje, acumulador ->
      Map.update(acumulador, pesaje.dia, pesaje.kilos, fn total ->
        total + pesaje.kilos
      end)
    end)
  end
end
