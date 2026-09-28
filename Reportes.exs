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
end
