class Area {
  final int? id; 
  final String name;
  final int tipo; // 0 dentro, 1 fuera, 2 copiar
  final String? imageSeed;

  Area({
    this.id,
    required this.name,
    required this.tipo,
    this.imageSeed,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'tipo': tipo,
      'imageSeed': imageSeed,
    };
  }

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      id: map['id'] as int?,
      name: map['name'] as String,
      tipo: map['tipo'] as int,
      imageSeed: map['imageSeed'] as String?,
    );
  }
}

