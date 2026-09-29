

defmodule Validacion do
  @dias 6
  @max_kilos 250
  @max_porcentaje 100

  def validar_pesaje(pesaje, recolectores_por_codigo, lotes_por_id) do
    with :ok <- validar_recolector(pesaje, recolectores_por_codigo),
         :ok <- validar_lote(pesaje, lotes_por_id),
         :ok <- validar_dia(pesaje),
         :ok <- validar_kilos(pesaje),
         :ok <- validar_porcentaje(pesaje) do
      {:ok, pesaje}
    end
  end

  def validar_pesajes(pesajes, recolectores_por_codigo, lotes_por_id) do
    resultados =
      Enum.map(pesajes, fn pesaje ->
        {pesaje, validar_pesaje(pesaje, recolectores_por_codigo, lotes_por_id)}
      end)

    validos = for {_pesaje, {:ok, valido}} <- resultados, do: valido
    rechazados = for {pesaje, {:error, motivo}} <- resultados, do: {pesaje, motivo}

    {validos, rechazados}
  end

  def parsear_pesaje(linea) do
    campos = linea |> String.split(";") |> Enum.map(&String.trim/1)

    with [recolector, lote, dia, kilos, verdes] <- campos,
         {dia, ""} <- Integer.parse(dia),
         {:ok, kilos} <- parsear_numero(kilos),
         {:ok, verdes} <- parsear_numero(verdes) do
      {:ok, %{recolector: recolector, lote: lote, dia: dia, kilos: kilos, verdes: verdes}}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  defp validar_recolector(pesaje, recolectores_por_codigo) do
    if Map.has_key?(recolectores_por_codigo, Map.get(pesaje, :recolector)) do
      :ok
    else
      {:error, :recolector_desconocido}
    end
  end

  defp validar_lote(pesaje, lotes_por_id) do
    if Map.has_key?(lotes_por_id, Map.get(pesaje, :lote)) do
      :ok
    else
      {:error, :lote_desconocido}
    end
  end

  defp validar_dia(%{dia: dia}) when is_integer(dia) and dia >= 1 and dia <= @dias, do: :ok
  defp validar_dia(_pesaje), do: {:error, :dia_invalido}

  defp validar_kilos(%{kilos: kilos}) when is_number(kilos) and kilos > 0 and kilos <= @max_kilos,
    do: :ok

  defp validar_kilos(_pesaje), do: {:error, :kilos_fuera_de_rango}

  defp validar_porcentaje(%{verdes: verdes})
       when is_number(verdes) and verdes >= 0 and verdes <= @max_porcentaje,
       do: :ok

  defp validar_porcentaje(_pesaje), do: {:error, :porcentaje_invalido}

  defp parsear_numero(texto) do
    case Integer.parse(texto) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> :error
        end
    end
  end
end
