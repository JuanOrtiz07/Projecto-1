defmodule Reportes do

  def generar_r1(pesajes_evaluados) do
    rechazados = Enum.filter(pesajes_evaluados, fn pesaje ->
      case pesaje do
        {:error, _motivo} -> true
        _ -> false
      end
    end)

    conteos = Enum.frequencies_by(rechazados, fn {:error, motivo} ->
      motivo
    end)

    {rechazados, conteos}
  end

  def generar_r2(pesajes_validos, lista_lotes) do
    pesajes_por_lote = Enum.group_by(pesajes_validos, fn pesaje ->
      pesaje.lote
    end)

    lista_rendimientos = for lote <- lista_lotes do
      pesajes = Map.get(pesajes_por_lote, lote.id, [])
      total_kilos = Enum.sum(for p <- pesajes, do: p.kilos)
      rendimiento = if lote.hectareas > 0, do: total_kilos / lote.hectareas, else: 0.0
      %{
        nombre: lote.nombre,
        kilos: total_kilos,
        hectareas: lote.hectareas,
        rendimiento: rendimiento
      }
    end

    Enum.sort_by(lista_rendimientos, fn lote_procesado ->
      lote_procesado.rendimiento
    end, :desc)
  end


  def generar_r3(pesajes_validos, dias_de_cosecha, meta_diaria) do
    pesajes_por_dia = Enum.group_by(pesajes_validos, fn pesaje -> pesaje.dia end)

    reporte_dias = for dia <- dias_de_cosecha do
      pesajes_del_dia = Map.get(pesajes_por_dia, dia, [])
      total_kilos = Enum.sum(for p <- pesajes_del_dia, do: p.kilos)

      %{
        dia: dia,
        kilos: total_kilos,
        cumplio_meta: total_kilos >= meta_diaria
      }
    end

    cumplio_todos = Enum.all?(reporte_dias, fn r -> r.cumplio_meta == true end)
    cumplio_al_menos_uno = Enum.any?(reporte_dias, fn r -> r.cumplio_meta == true end)

    {reporte_dias, cumplio_todos, cumplio_al_menos_uno}
  end

  def generar_r4(liquidaciones_recolectores) do
    lista_ordenada = Enum.sort_by(liquidaciones_recolectores, fn liq -> liq.neto end, :desc)

    for liq <- lista_ordenada do
      %{
        nombre: liq.nombre,
        kilos: liq.kilos,
        pesajes_formateado: :erlang.float_to_binary(liq.pesajes_total * 1.0, decimals: 2),
        bono_formateado: :erlang.float_to_binary(liq.bonificaciones * 1.0, decimals: 2),
        alimentacion_formateada: :erlang.float_to_binary(liq.alimentacion * 1.0, decimals: 2),
        neto_formateado: :erlang.float_to_binary(liq.neto * 1.0, decimals: 2)
      }
    end
  end

  def generar_r5(pesajes_validos, dias_de_cosecha, lista_recolectores) do
    pesajes_por_dia = Enum.group_by(pesajes_validos, fn p -> p.dia end)
    reporte_diario = for dia <- dias_de_cosecha do
      pesajes_del_dia = Map.get(pesajes_por_dia, dia, [])
      if pesajes_del_dia == [] do
        %{dia: dia, ganadores: :sin_pesajes, kilos: 0}
      else
        por_recolector = Enum.group_by(pesajes_del_dia, fn p -> p.recolector end)
        kilos_recolector = for {codigo, lista_p} <- por_recolector do
          total_k = Enum.sum(for p <- lista_p, do: p.kilos)
          %{codigo: codigo, kilos: total_k}
        end
        max_kilos = Enum.max_by(kilos_recolector, fn rec -> rec.kilos end).kilos
        empatados = Enum.filter(kilos_recolector, fn rec -> rec.kilos == max_kilos end)
        codigos_ganadores = for g <- empatados, do: g.codigo
        %{dia: dia, ganadores: codigos_ganadores, kilos: max_kilos}
      end
    end

    dias_ganados = Enum.filter(reporte_diario, fn r -> r.ganadores != :sin_pesajes end)
    todos_los_ganadores = List.flatten(for r <- dias_ganados, do: r.ganadores)
    frecuencias = Enum.frequencies(todos_los_ganadores)
    if frecuencias == %{} do
      {:sin_ganadores, 0}
    else
      max_dias = Enum.max_by(Map.to_list(frecuencias), fn {_cod, dias} -> dias end) |> elem(1)
      mejores_semana = Enum.filter(Map.to_list(frecuencias), fn {_cod, dias} -> dias == max_dias end)
      {mejores_semana, max_dias}
    end
  end


  def generar_r6(pesajes_validos, lista_recolectores) do
    por_recolector = Enum.group_by(pesajes_validos, fn p -> p.recolector end)
    calidades = for {codigo, pesajes} <- por_recolector, length(pesajes) >= 3 do
      suma_productos = Enum.sum(for p <- pesajes, do: p.verdes * p.kilos)
      total_kilos = Enum.sum(for p <- pesajes, do: p.kilos)
      ponderado = if total_kilos > 0, do: suma_productos / total_kilos, else: 100.0
      %{codigo: codigo, porcentaje_ponderado: ponderado}
    end
    if calidades == [] do
      :no_aplica
    else
      Enum.min_by(calidades, fn c -> c.percentage_ponderado end)
    end
  end

  def generar_r7(liquidaciones, pesajes_validos) do
    total_pagado = Enum.sum(for l <- liquidaciones, do: l.neto)
    total_kilos_validos = Enum.sum(for p <- pesajes_validos, do: p.kilos)
    promedio_kilo = if total_kilos_validos > 0, do: total_pagado / total_kilos_validos, else: 0.0
    {total_pagado, total_kilos_validos, promedio_kilo}
  end


  def generar_r8(pesajes_validos, lista_lotes, lista_recolectores) do
    total_lotes_finca = length(lista_lotes)
    por_recolector = Enum.group_by(pesajes_validos, fn p -> p.recolector end)
    cumplen = for {codigo, pesajes} <- por_recolector do
      lotes_visitados = Enum.uniq(for p <- pesajes, do: p.lote)
      if length(lotes_visitados) == total_lotes_finca, do: codigo, else: nil
    end
    Enum.reject(cumplen, fn x -> is_nil(x) end)
  end
end
