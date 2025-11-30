import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Area {
  final String name;
  final int tipo; // 0 dentro,1 fuera,2 copiar
  final String? imageSeed;

  Area({required this.name, required this.tipo, this.imageSeed});

  Map<String, dynamic> toJson() => {
        'name': name,
        'tipo': tipo,
        'imageSeed': imageSeed,
      };

  factory Area.fromJson(Map<String, dynamic> json) => Area(
        name: json['name'] as String,
        tipo: json['tipo'] as int,
        imageSeed: json['imageSeed'] as String?,
      );
}

class AreaStorage {
  static const _key = 'areas_list_v1';

  Future<List<Area>> loadAreas() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final List<dynamic> arr = jsonDecode(raw) as List<dynamic>;
      return arr.map((e) => Area.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAreas(List<Area> areas) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(areas.map((a) => a.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  Future<void> addArea(Area area) async {
    final areas = await loadAreas();
    areas.add(area);
    await saveAreas(areas);
  }

  Future<void> updateArea(String oldName, Area newArea) async {
    final areas = await loadAreas();
    final idx = areas.indexWhere((a) => a.name == oldName);
    if (idx != -1) {
      areas[idx] = newArea;
      await saveAreas(areas);
    }
  }

  Future<void> deleteArea(String name) async {
    final areas = await loadAreas();
    areas.removeWhere((a) => a.name == name);
    await saveAreas(areas);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
