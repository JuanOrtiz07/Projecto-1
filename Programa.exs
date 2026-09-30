defmodule Programa do
  @tarifa_por_kilo 1000
  @meta_diaria_finca_kilos 400
  @dias_de_cosecha [1,2,3,4,5,6]

  def main do
    recolectores = Datos.recolectores()
    lotes = Datos.lotes()
    pesajes_base = Datos.pesajes()

    entrada = Util.leer("Ingrese un pesaje adicional (recolector;lote;dia;kilos;verdes) o Enter para omitir: ", :string)

    pesajes_totales = case Validacion.parsear_pesaje(entrada) do
      {:ok, nuevo_p} ->
        Util.imprimir_mensaje("Pesaje agregado con éxito.")
        pesajes_base ++ [nuevo_p]
      {:error, :formato_invalido} ->
        if entrada != "", do: Util.imprimir_mensaje("Pesaje rechazado: formato_invalido")
        pesajes_base
    end

    # 2. Indexación a mapas para optimizar las búsquedas (Parte A)
    recolectores_map = Map.new(recolectores, fn r -> {r.codigo, r} end)
    lotes_map = Map.new(lotes, fn l -> {l.id, l} end)

    # 3. Llamada al validador
    {pesajes_validos, pesajes_rechazados} = Validacion.validar_pesajes(pesajes_totales, recolectores_map, lotes_map)











    # --- IMPRESIÓN DE LOS 8 REPORTES ---

    # R1. Pesajes rechazados
    {lista_rechazados, conteos_motivos} = Reportes.generar_r1(pesajes_rechazados)
    Util.imprimir_mensaje("\nR1. Pesajes rechazados")
    for {p, motivo} <- lista_rechazados do
      Util.imprimir_mensaje("#{p.recolector} | #{p.lote} | día #{p.dia} | #{p.kilos} kg | #{p.verdes} % -> #{motivo}")
    end
    Util.imprimir_mensaje("\nRechazos por motivo")
    for {motivo, cantidad} <- conteos_motivos do
      Util.imprimir_mensaje("#{motivo}: #{cantidad}")
    end

    # R2. Kilos por lote y rendimiento
    lista_r2 = Reportes.generar_r2(pesajes_validos, lotes)
    Util.imprimir_mensaje("\nR2. Kilos por lote")
    for lote <- lista_r2 do
      rend_formateado = Util.formatear_decimal(lote.rendimiento)
      Util.imprimir_mensaje("#{String.pad_trailing(lote.nombre, 12)} | #{lote.kilos} kg | #{lote.hectareas} ha | #{rend_formateado} kg/ha")
    end

    # R3. Kilos por día frente a la meta
    {reporte_r3, todos_dias, al_menos_uno} = Reportes.generar_r3(pesajes_validos, @dias_de_cosecha, @meta_diaria_finca_kilos)
    Util.imprimir_mensaje("\nR3. Kilos por día (meta: #{@meta_diaria_finca_kilos} kg)")
    for r <- reporte_r3 do
      indicador = if r.cumplio_meta, do: "-> cumplió la meta", else: "-> no cumplió la meta"
      Util.imprimir_mensaje("Día #{r.dia}: #{r.kilos} kg #{indicador}")
    end
    Util.imprimir_mensaje("¿Se cumplió la meta todos los días? #{if todos_dias, do: "Sí", else: "No"}")
    Util.imprimir_mensaje("¿Se cumplió la meta al menos un día? #{if al_menos_uno, do: "Sí", else: "No"}")

    # R4. Liquidación de la semana ordenada por neto (Simulado con los datos de tus compañeros)
    @doc """
    llista_r4 = Reportes.generar_r4(liquidaciones_calculadas)
    Util.imprimir_mensaje("\nR4. Liquidación de la semana")
    Util.imprimir_mensaje("#   | Recolector          | Kilos    | Pesajes     | Bonificaciones | Alimentación | Neto")

    Enum.with_index(lista_r4, 1)
    |> Enum.each(fn {liq, indice} ->
      nombre_espacio = String.pad_trailing(liq.nombre, 20)
      kilos_espacio = String.pad_trailing("#{liq.kilos} kg", 8)
      Util.imprimir_mensaje("#{indice}. | #{nombre_espacio} | #{kilos_espacio} | $#{liq.pesajes_formateado}  | $#{liq.bono_formateado}      | $#{liq.alimentacion_formateada}    | $#{liq.neto_formateado}")
    end)
    """

    # R5. Mejor recolector diario y líder semanal
    {reporte_r5, lideres_semana, max_dias} = Reportes.generar_r5(pesajes_validos, @dias_de_cosecha, recolectores)
    Util.imprimir_mensaje("\nR5. Mejor recolector de cada día")
    for r <- reporte_r5 do
      case r.ganadores do
        :sin_pesajes -> Util.imprimir_mensaje("Día #{r.dia}: sin pesajes")
        lista_codigos ->
          nombres = for cod <- lista_codigos, do: Enum.find(recolectores, fn rec -> rec.codigo == cod end).nombre
          Util.imprimir_mensaje("Día #{r.dia}: #{Enum.join(nombres, ", ")} (#{r.kilos} kg)")
      end
    end
    nombres_lideres = for {cod, _dias} <- lideres_semana, do: Enum.find(recolectores, fn rec -> rec.codigo == cod end).nombre
    Util.imprimir_mensaje("Más días como mejor recolector: #{Enum.join(nombres_lideres, ", ")} (#{max_dias} días)")
    # 6. Impresión de R6 (Mejor calidad - Porcentaje ponderado mínimo)
    case Reportes.generar_r6(pesajes_validos, recolectores) do
      :no_aplica ->
        Util.imprimir_mensaje("\nR6. Mejor calidad (mínimo 3 pesajes válidos): N/A")
      mejor_c ->
        persona = Enum.find(recolectores, fn r -> r.codigo == mejor_c.codigo end)
        calidad_formateada = Util.formatear_decimal(mejor_c.porcentaje_ponderado)
        Util.imprimir_mensaje("\nR6. Mejor calidad (mínimo 3 pesajes válidos)\n#{persona.nombre}, con #{calidad_formateada} % de verdes ponderado por kilos")
    end

    # 7. Impresión de R7 (Totales financieros de la semana)
    # (Pasamos liquidaciones_calculadas provista por tus compañeros)
    {total_pago, kilos_v, costo_prom} = Reportes.generar_r7(liquidaciones_calculadas, pesajes_validos)
    Util.imprimir_mensaje("\nR7. Totales de la semana")
    Util.imprimir_mensaje("Total a pagar: $#{Util.formatear_decimal(total_pago)}")
    Util.imprimir_mensaje("Kilos válidos: #{kilos_v} kg")
    Util.imprimir_mensaje("Costo promedio por kilo: $#{Util.formatear_decimal(costo_prom)}")

    # 8. Impresión de R8 (Recolectores con cobertura en todos los lotes)
    lista_r8 = Reportes.generar_r8(pesajes_validos, lotes, recolectores)
    Util.imprimir_mensaje("\nR8. Recolectores que trabajaron en todos los lotes")
    if lista_r8 == [] do
      Util.imprimir_mensaje("No hay ningún recolector que haya trabajado en todos los lotes.")
    else
      for cod <- lista_r8 do
        nombre_rec = Enum.find(recolectores, fn r -> r.codigo == cod end).nombre
        Util.imprimir_mensaje(nombre_rec)
      end
    end

    # --- B.5 INTERACCIÓN FINAL: DESPRENDIBLE DE PAGO ---
    Util.imprimir_mensaje("")
    cod_consulta = Util.leer("Ingrese el código del recolector para ver su desprendible: ", :string)
    imprimir_desprendible(cod_consulta, recolectores, pesajes_validos)

    # --- PARTE C: EJECUCIÓN DE CONSULTAS DE INVESTIGACIÓN ---
    Util.imprimir_mensaje("\n--- PARTE C: PRUEBAS DE RANKING E INVESTIGACIÓN ---")
    Util.imprimir_mensaje("Prueba 1 (Vacía):")
    IO.inspect(Reportes.ranking(liquidaciones_calculadas, []))
  end

  # Función auxiliar interactiva para renderizar el desprendible individual
  defp imprimir_desprendible(codigo, recolectores, pesajes_validos) do
    recolector = Enum.find(recolectores, fn r -> r.codigo == codigo end)
    if is_nil(recolector) do
      Util.imprimir_mensaje("No existe un recolector con el código #{codigo}.")
    else
      Util.imprimir_mensaje("\nDesprendible de pago - #{recolector.nombre} (#{recolector.codigo})")
      por_dia = Enum.group_by(Enum.filter(pesajes_validos, fn p -> p.recolector == codigo end), fn p -> p.dia end)

      for {dia, lista_p} <- por_dia do
        kilos_dia = Enum.sum(for p <- lista_p, do: p.kilos)
        valor_dia = Enum.sum(for p <- lista_p, do: Liquidacion.valor_pesaje(p.kilos, p.verdes))
        bono_dia = Liquidacion.bonificacion(kilos_dia)

        Util.imprimir_mensaje("Día #{dia}: #{kilos_dia} kg | pesajes $#{Util.formatear_decimal(valor_dia)} | bonificación $#{Util.formatear_decimal(bono_dia)}")
      end
    end
  end
end
