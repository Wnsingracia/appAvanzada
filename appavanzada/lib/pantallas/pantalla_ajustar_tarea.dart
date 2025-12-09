import 'package:flutter/material.dart'; // Importa Flutter para widgets, UI y Material Design
import '../db/database_helper.dart'; // Importa nuestro helper para la base de datos SQLite
import '../models/tarea.dart'; // Modelo de Tarea
import 'pantalla_estado_tarea.dart'; // Otra pantalla a la que navegamos después de guardar

// -----------------------------
// Widget principal: Ajustar Tarea
// -----------------------------
class PantallaAjustarTarea extends StatefulWidget {
  final int areaId; // ID del área a la que pertenece la tarea
  final String nombreTarea; // Nombre de la tarea que vamos a ajustar

  const PantallaAjustarTarea({
    super.key,
    required this.areaId,
    required this.nombreTarea,
  });

  @override
  State<PantallaAjustarTarea> createState() => _PantallaAjustarTareaState();
}

// -----------------------------
// Estado de la pantalla
// -----------------------------
class _PantallaAjustarTareaState extends State<PantallaAjustarTarea> {
  int cantidad = 5; // Valor inicial de frecuencia (cantidad)
  String unidad = "Dias"; // Unidad inicial: Dias, Semanas o Meses

  // -----------------------------
  // Funciones para aumentar o disminuir la cantidad
  // -----------------------------
  void aumentar() {
    setState(() {
      cantidad++; // Incrementa la cantidad
    });
  }

  void disminuir() {
    setState(() {
      if (cantidad > 1) cantidad--; // Decrementa la cantidad pero no menos de 1
    });
  }

  // -----------------------------
  // Función para guardar la frecuencia en la DB
  // -----------------------------
  Future<void> guardarFrecuencia() async {
    // Creamos un objeto Tarea con los valores ingresados
    final tarea = Tarea(
      areaId: widget.areaId, // Área a la que pertenece
      nombre: widget.nombreTarea, // Nombre de la tarea
      cantidadFrecuencia: cantidad, // Cantidad seleccionada
      unidadFrecuencia: unidad, // Unidad seleccionada
      completada: false, // Inicialmente no completada
      ultimaFecha: null, // Sin fecha aún
    );

    // Insertamos la tarea en la DB y obtenemos el ID generado
    final idGenerado = await DatabaseHelper.instance.insertTarea(tarea);

    // Creamos un nuevo objeto Tarea ya con el ID asignado por la DB
    final tareaGuardada = Tarea(
      id: idGenerado,
      areaId: tarea.areaId,
      nombre: tarea.nombre,
      cantidadFrecuencia: tarea.cantidadFrecuencia,
      unidadFrecuencia: tarea.unidadFrecuencia,
      completada: tarea.completada,
      ultimaFecha: tarea.ultimaFecha,
    );

    // Navegamos a la pantalla de estado de la tarea, pasando la tarea recién guardada
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaEstadoTarea(tarea: tareaGuardada),
      ),
    );
  }

  // -----------------------------
  // UI principal
  // -----------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF), // Azul de la app
        title: const Text(
          "Ajustar Tarea",
          style: TextStyle(color: Colors.black), // Texto del AppBar negro
        ),
        iconTheme: const IconThemeData(color: Colors.black), // Iconos del AppBar negros
      ),
      body: Column(
        children: [
          const SizedBox(height: 20), // Espacio superior
          Text(
            widget.nombreTarea, // Muestra el nombre de la tarea
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // -----------------------------
                // Columna de CANTIDAD
                // -----------------------------
                Expanded(
                  child: Column(
                    children: [
                      const Text("Frecuencia"), // Título de columna
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: disminuir, // Botón de restar
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            cantidad.toString(), // Muestra cantidad actual
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: aumentar, // Botón de sumar
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // -----------------------------
                // Columna de UNIDAD
                // -----------------------------
                Expanded(
                  child: Column(
                    children: [
                      const Text("Unidad"), // Título de columna
                      DropdownButton<String>(
                        value: unidad, // Valor seleccionado actualmente
                        items: ["Dias", "Semanas", "Meses"]
                            .map(
                              (u) => DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          setState(() {
                            unidad = v!; // Actualiza la unidad al seleccionar
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40), // Espacio entre controles y botón
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0095FF),
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: guardarFrecuencia, // Guarda la tarea y navega a siguiente pantalla
            child: const Text(
              "¡SE VE BIEN!",
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

