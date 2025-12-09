import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/area.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false; // solo visual

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Cargar preferencias guardadas
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  // Guardar preferencias
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  // Crear copia de seguridad de todas las áreas en JSON
  Future<void> _createBackup() async {
    final db = DatabaseHelper.instance;
    final List<Area> areas = await db.getAreas();
    final List<Map<String, dynamic>> jsonList = areas.map((a) => a.toMap()).toList();

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backup_areas.json');

    await file.writeAsString(jsonEncode(jsonList));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copia guardada en: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF0095FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // PERFIL SUPERIOR
          Container(
            color: const Color(0xFF0095FF),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Color(0xFF0095FF)),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Usuario Admin',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'admin@ejemplo.com',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // GENERAL
          _buildSectionTitle('General'),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar apariencia de la aplicación'),
            secondary: const Icon(Icons.dark_mode),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              _saveSetting('isDarkMode', value);
            },
          ),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas de mantenimiento'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSetting('notificationsEnabled', value);
            },
          ),

          const Divider(),

          // SEGURIDAD
          _buildSectionTitle('Seguridad'),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Biometría'),
            subtitle: const Text('Usar huella (solo visual)'),
            secondary: const Icon(Icons.fingerprint),
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() => _biometricEnabled = value);
              _saveSetting('biometricEnabled', value);
            },
          ),

          const Divider(),

          // BASE DE DATOS
          _buildSectionTitle('Base de Datos'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Borrar todas las áreas', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Esta acción no se puede deshacer'),
            onTap: () => _showDeleteConfirmation(context),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Copia de seguridad'),
            subtitle: const Text('Guardar configuración en archivo local'),
            onTap: _createBackup,
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              'Versión 1.0.2 (Beta)',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // TÍTULOS DE SECCIÓN
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // BORRAR TODA LA BASE DE DATOS
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Esto borrará todas las áreas en la base de datos SQLite local.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final db = DatabaseHelper.instance;
              await db.deleteTodasLasAreas();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todas las áreas han sido borradas')),
                );
              }
            },
            child: const Text('BORRAR TODO', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
