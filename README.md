# Parcial 1: Sistema de Liquidación de Cosecha Cafetera

**Curso:** Programación 3  
**Lenguaje:** Elixir  
**Plataforma / Máquina Virtual:** Erlang BEAM  

---

## 👥 Integrantes del Grupo
- **Estudiante 1:** [Nombre Completo del Integrante 1]
- **Estudiante 2:** [Nombre Completo del Integrante 2]
- **Estudiante 3:** [Nombre Completo del Integrante 3]

---

## 📂 Estructura del Repositorio

El proyecto está organizado en módulos desacoplados y puros para cumplir con las reglas del paradigma funcional:

- **`datos.exs`**: Módulo `Datos`. Contiene los datos crudos de recolectores, lotes y pesajes.
- **`util.exs`**: Módulo `Util`. Funciones puras e impuras auxiliares para lectura por consola, mensajes y formateo de decimales.
- **`validacion.exs`**: Módulo `Validacion`. Validación con la expresión `with` y filtrado seguro de pesajes.
- **`liquidacion.exs`**: Módulo `Liquidacion`. Cálculo de tarifas por calidad, bonificaciones por meta diaria y descuentos de alimentación.
- **`reportes.exs`**: Módulo `Reportes`. Generación funcional de los reportes R1 a R8, ranking dinámico (`ranking/2`) y fusión de producción (`combinar_fincas/2`).
- **`programa.exs`**: Módulo `Programa`. Orquestador principal (`main/0`), interacción por teclado y despliegue de consola.

---

## 🚀 Instrucciones de Compilación y Ejecución

Debido a las restricciones de la máquina virtual (BEAM), los módulos de apoyo se deben compilar primero para generar sus binarios virtuales (`.beam`).

### Paso 1: Abrir la terminal
Abre la consola de comandos o terminal en la ruta raíz donde se encuentran los archivos `.exs`.

### Paso 2: Compilar los módulos de apoyo
Ejecuta los siguientes comandos en este **orden estricto**:

```bash
elixirc util.exs
elixirc datos.exs
elixirc validacion.exs
elixirc liquidacion.exs
elixirc reportes.exs