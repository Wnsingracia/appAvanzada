import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/tarea.dart';

class PantallaEstadoTarea extends StatefulWidget {
  final Tarea tarea;

  const PantallaEstadoTarea({super.key, required this.tarea});

  @override
  State<PantallaEstadoTarea> createState() => _PantallaEstadoTareaState();
}

class _PantallaEstadoTareaState extends State<PantallaEstadoTarea> {
  int diasPasados = 0;
  int frecuenciaEnDias = 1;
  double progreso = 0.0;

  String estadoSeleccionado = ""; // Estado actual mostrado en la barra

  @override
  void initState() {
    super.initState();
    _calcularEstado();
    estadoSeleccionado = estadoTexto; // Inicializamos el chip activo según el progreso real
  }

  // Convertir unidad a días
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

  void _calcularEstado() {
    final ultima = widget.tarea.ultimaFecha != null
        ? DateTime.tryParse(widget.tarea.ultimaFecha!) ?? DateTime.now()
        : DateTime.now();

    diasPasados = DateTime.now().difference(ultima).inDays;

    final cantidad = widget.tarea.cantidadFrecuencia ?? 1;
    final unidad = widget.tarea.unidadFrecuencia ?? "Dias";

    frecuenciaEnDias = cantidad * _convertirUnidadADias(unidad);

    progreso = frecuenciaEnDias > 0 ? diasPasados / frecuenciaEnDias : 1.0;
    if (progreso > 1) progreso = 1.0;
  }

  String get estadoTexto {
    if (progreso < 0.4) return "Hacer ya";
    if (progreso < 0.8) return "Aún no";
    return "Bien";
  }

  Color get estadoColor {
    if (progreso < 0.4) return Colors.red;
    if (progreso < 0.8) return Colors.orange;
    return Colors.green;
  }

  Future<void> completarTarea() async {
    final fecha = DateTime.now().toIso8601String();

    // Determinar si la barra está completamente pintada
    final cuadrosLlenos = (progreso * 5).round();
    final bool estaCompleta = cuadrosLlenos == 5;

    final nuevaTarea = Tarea(
      id: widget.tarea.id,
      areaId: widget.tarea.areaId,
      nombre: widget.tarea.nombre,
      cantidadFrecuencia: widget.tarea.cantidadFrecuencia,
      unidadFrecuencia: widget.tarea.unidadFrecuencia,
      completada: estaCompleta, // ← depende de la barra
      ultimaFecha: fecha,
    );

    await DatabaseHelper.instance.updateTarea(nuevaTarea);

    Navigator.pop(context);
  }

  // CHIP INTERACTIVO PARA CAMBIAR BARRA
  Widget _estadoBoton(String texto, double progresoAsociado) {
    final activo = estadoSeleccionado == texto;

    return ChoiceChip(
      selectedColor: const Color(0xFF0095FF),
      backgroundColor: Colors.white,
      label: Text(
        texto,
        style: TextStyle(
          color: activo ? Colors.white : Colors.black,
        ),
      ),
      selected: activo,
      onSelected: (_) {
        setState(() {
          estadoSeleccionado = texto;
          progreso = progresoAsociado; // Cambia visualmente la barra
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cuadrosLlenos = (progreso * 5).round();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0095FF),
        title: const Text("Estado actual", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        color: const Color(0xFFE0F0FF),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text(
                    "Estado",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Barra de progreso visual
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
            Text(
              widget.tarea.nombre,
              style: const TextStyle(
                fontSize: 28,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Chips interactivos para cambiar barra
            Row(
              children: [
                _estadoBoton("Bien", 1.0),
                const SizedBox(width: 8),
                _estadoBoton("Aún no", 0.6),
                const SizedBox(width: 8),
                _estadoBoton("Hacer ya", 0.2),
              ],
            ),
            const SizedBox(height: 35),
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
