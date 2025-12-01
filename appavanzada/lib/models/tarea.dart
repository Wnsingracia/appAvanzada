class Tarea {
  final int? id;
  final int areaId;
  final String nombre;
  final bool completada;
  final int? cantidadFrecuencia;
  final String? unidadFrecuencia;
  final String? ultimaFecha;

  Tarea({
    this.id,
    required this.areaId,
    required this.nombre,
    this.completada = false,
    this.cantidadFrecuencia,
    this.unidadFrecuencia,
    this.ultimaFecha,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'areaId': areaId,
      'nombre': nombre,
      'completada': completada ? 1 : 0,
      'cantidadFrecuencia': cantidadFrecuencia,
      'unidadFrecuencia': unidadFrecuencia,
      'ultimaFecha': ultimaFecha,
    };
  }

  // Crear objeto Tarea desde Map de SQLite
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'] as int?,
      areaId: map['areaId'] as int,
      nombre: map['nombre'] as String,
      completada: map['completada'] == 1,
      cantidadFrecuencia: map['cantidadFrecuencia'] as int?,
      unidadFrecuencia: map['unidadFrecuencia'] as String?,
      ultimaFecha: map['ultimaFecha'] as String?,
    );
  }
}
