defmodule Util do
  @moduledoc """
  Módulo con funciones que se reutilizan
  - autor: Juan Camilo Ortiz
  - fecha: Junio 2026
  - licencia: GNU GPL v3
  """

  def leer(mensaje, :string) do
    IO.gets(mensaje)
    |> String.trim()
  end

  def leer(mensaje, :integer) do
    leer_con_parser(mensaje, &Integer.parse/1, 0) # Se pasa la función de parseo y el valor por defecto
  end

  def leer(mensaje, :float) do
    leer_con_parser(mensaje, &Float.parse/1, 0.0) # Para flotantes el valor por defecto es 0.0
  end

  def leer(_mensaje, _tipo) do
    imprimir_error("Tipo de dato no valido.")
  end

  defp leer_con_parser(mensaje, funcion, valor_defecto) do
    valor = IO.gets(mensaje)
    |> String.trim()
    |> funcion.() # Se ejecuta la función de parseo

    case valor do
      {numero, _} -> numero
      :error ->
        imprimir_error("Error. Se utilizará #{valor_defecto} como valor predeterminado.")
        valor_defecto
    end
  end

  def imprimir_error(mensaje) do
    IO.puts(:standard_error, mensaje)
  end

  def imprimir_mensaje(mensaje) do
    IO.puts(mensaje)
  end
  # Parsea de forma segura a entero validando con Integer.parse
  def parsear_entero(string) do
    case Integer.parse(string) do
      {numero, ""} -> {:ok, numero}
      _ -> {:error, :formato_invalido}
    end
  end

  # Parsea de forma segura a flotante aceptando enteros o decimales
  def parsear_flotante(string) do
    case Float.parse(string) do
      {numero, ""} -> {:ok, numero}
      _ ->
        case Integer.parse(string) do
          {numero, ""} -> {:ok, numero * 1.0}
          _ -> {:error, :formato_invalido}
        end
    end
  end

  def formatear_decimal(valor) do
    :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

end
