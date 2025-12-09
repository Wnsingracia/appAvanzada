import 'package:appavanzada/pantallas/pantalla_areas.dart'; // Para navegar de regreso a la pantalla de áreas
import 'package:flutter/material.dart';
import '../db/database_helper.dart'; // Para actualizar la base de datos
import '../models/tarea.dart'; // Modelo Tarea

// Pantalla que muestra el estado actual de una tarea específica
class PantallaEstadoTarea extends StatefulWidget {
  final Tarea tarea; // La tarea que estamos visualizando/ajustando

  const PantallaEstadoTarea({super.key, required this.tarea});

  @override
  State<PantallaEstadoTarea> createState() => _PantallaEstadoTareaState();
}

class _PantallaEstadoTareaState extends State<PantallaEstadoTarea> {
  int diasPasados = 0; // Cuántos días han pasado desde la última vez que se completó la tarea
  int frecuenciaEnDias = 1; // Frecuencia de la tarea en días
  double progreso = 0.0; // Progreso visual de la barra

  String estadoSeleccionado = ""; // Estado activo mostrado en los chips

  @override
  void initState() {
    super.initState();
    _calcularEstado(); // Calculamos progreso según la fecha y frecuencia
    estadoSeleccionado = estadoTexto; // Inicializamos chip activo según progreso
  }

  // --- Convertir unidad de tiempo a días ---
  int _convertirUnidadADias(String unidad) {
    switch (unidad) {
      case "Semanas":
        return 7;
      case "Meses":
        return 30;
      case "Dias":
      default:
        return 1;
    }
  }

  // --- Calcular progreso y estado de la tarea ---
  void _calcularEstado() {
    final ultima = widget.tarea.ultimaFecha != null
        ? DateTime.tryParse(widget.tarea.ultimaFecha!) ?? DateTime.now()
        : DateTime.now();

    diasPasados = DateTime.now().difference(ultima).inDays;

    final cantidad = widget.tarea.cantidadFrecuencia ?? 1;
    final unidad = widget.tarea.unidadFrecuencia ?? "Dias";

    frecuenciaEnDias = cantidad * _convertirUnidadADias(unidad);

    progreso = frecuenciaEnDias > 0 ? diasPasados / frecuenciaEnDias : 1.0;
    if (progreso > 1) progreso = 1.0; // Limitar progreso a 100%
  }

  // --- Texto del estado según progreso ---
  String get estadoTexto {
    if (progreso < 0.4) return "Hacer ya";
    if (progreso < 0.8) return "Aún no";
    return "Bien";
  }

  // --- Color de la barra según progreso ---
  Color get estadoColor {
    if (progreso < 0.4) return Colors.red;
    if (progreso < 0.8) return Colors.orange;
    return Colors.green;
  }

  // --- Guardar tarea como completada o actualizar última fecha ---
  Future<void> completarTarea() async {
    final fecha = DateTime.now().toIso8601String();

    // Determinar si la barra está completamente pintada
    final cuadrosLlenos = (progreso * 5).round();
    final bool estaCompleta = cuadrosLlenos == 5;

    // Crear nueva instancia de tarea con datos actualizados
    final nuevaTarea = Tarea(
      id: widget.tarea.id,
      areaId: widget.tarea.areaId,
      nombre: widget.tarea.nombre,
      cantidadFrecuencia: widget.tarea.cantidadFrecuencia,
      unidadFrecuencia: widget.tarea.unidadFrecuencia,
      completada: estaCompleta, // Dependiendo del progreso
      ultimaFecha: fecha,
    );

    // Actualizar en la base de datos
    await DatabaseHelper.instance.updateTarea(nuevaTarea);

    // Volver a la pantalla de áreas
    Navigator.push(context, MaterialPageRoute(builder: (_) => PantallaAreas()));
  }

  // --- Chip interactivo para cambiar barra manualmente ---
  Widget _estadoBoton(String texto, double progresoAsociado) {
    final activo = estadoSeleccionado == texto;

    return ChoiceChip(
      selectedColor: const Color(0xFF0095FF),
      backgroundColor: Colors.white,
      label: Text(
        texto,
        style: TextStyle(color: activo ? Colors.white : Colors.black),
      ),
      selected: activo,
      onSelected: (_) {
        setState(() {
          estadoSeleccionado = texto;
          progreso = progresoAsociado; // Actualiza barra visualmente
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuadrosLlenos = (progreso * 5).round(); // Cantidad de cuadros llenos de la barra

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: const Text(
          "Estado actual",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFE0F0FF),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- Barra de progreso ---
            Center(
              child: Column(
                children: [
                  const Text(
                    "Estado",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 30,
                        height: 20,
                        decoration: BoxDecoration(
                          color: i < cuadrosLlenos ? estadoColor : Colors.white,
                          border: Border.all(color: Colors.black54),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // --- Nombre de la tarea ---
            Text(
              widget.tarea.nombre,
              style: const TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // --- Chips para cambiar estado manualmente ---
            Row(
              children: [
                const SizedBox(width: 50),
                _estadoBoton("Hacer ya", 0.2),
                const SizedBox(width: 8),
                _estadoBoton("Aún no", 0.6),
                const SizedBox(width: 8),
                _estadoBoton("Bien", 1.0),
              ],
            ),
            const SizedBox(height: 35),
            // --- Botón para guardar cambios ---
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: completarTarea,
                child: const Text("GUARDAR", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Resumen de la página ---
// Esta pantalla permite ver el estado actual de una tarea específica.
// - Muestra una barra de progreso visual basada en los días pasados vs frecuencia.
// - Permite cambiar manualmente el estado mediante chips interactivos.
// - Guarda los cambios de progreso y última fecha en la base de datos.
// - Permite marcar la tarea como completada si la barra está llena.
// - Después de guardar, regresa a la pantalla de Áreas.
