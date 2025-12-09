import 'dart:convert'; // Para convertir objetos a JSON
import 'dart:io'; // Para trabajar con archivos
import 'package:flutter/material.dart'; // Librería principal de Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar preferencias locales
import 'package:path_provider/path_provider.dart'; // Para obtener directorios del dispositivo
import '../db/database_helper.dart'; // Nuestro helper para SQLite
import '../models/area.dart'; // Modelo Area

// Pantalla de configuración general de la aplicación
class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  // --- Variables de estado de la configuración ---
  bool _isDarkMode = false; // Activar modo oscuro
  bool _notificationsEnabled = true; // Activar notificaciones
  bool _biometricEnabled = false; // Activar biometría (solo visual)

  @override
  void initState() {
    super.initState();
    _loadSettings(); // Cargar configuraciones guardadas al iniciar
  }

  // --- Función para cargar preferencias guardadas ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    });
  }

  // --- Función para guardar cualquier preferencia ---
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  // --- Función para crear copia de seguridad de todas las áreas ---
  Future<void> _createBackup() async {
    final db = DatabaseHelper.instance; // Obtenemos la instancia de la base de datos
    final List<Area> areas = await db.getAreas(); // Obtenemos todas las áreas
    final List<Map<String, dynamic>> jsonList = areas.map((a) => a.toMap()).toList(); // Convertimos a JSON

    // Obtenemos la carpeta de documentos del dispositivo
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backup_areas.json');

    // Escribimos el archivo JSON
    await file.writeAsString(jsonEncode(jsonList));

    // Mensaje visual indicando dónde se guardó la copia
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copia guardada en: ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar ---
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: const Color(0xFF0095FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // --- Lista de opciones de configuración ---
      body: ListView(
        children: [
          // --- PERFIL SUPERIOR ---
          Container(
            color: const Color(0xFF0095FF),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Row(
              children: [
                // Avatar del usuario
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Color(0xFF0095FF)),
                ),
                const SizedBox(width: 15),
                // Información del usuario
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

          // --- SECCIÓN GENERAL ---
          _buildSectionTitle('General'),
          // Opción de modo oscuro
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
          // Opción de notificaciones
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

          // --- SECCIÓN SEGURIDAD ---
          _buildSectionTitle('Seguridad'),
          // Opción biométrica (solo visual)
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

          // --- SECCIÓN BASE DE DATOS ---
          _buildSectionTitle('Base de Datos'),
          // Opción para borrar todas las áreas (acción destructiva)
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Borrar todas las áreas', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Esta acción no se puede deshacer'),
            onTap: () => _showDeleteConfirmation(context),
          ),
          // Opción para crear copia de seguridad de áreas
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Copia de seguridad'),
            subtitle: const Text('Guardar configuración en archivo local'),
            onTap: _createBackup,
          ),

          const SizedBox(height: 30),

          // --- VERSIÓN ---
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

  // --- Helper para títulos de sección ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(), // Mostramos en mayúsculas
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  // --- Mostrar cuadro de diálogo para borrar la base de datos ---
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Esto borrará todas las áreas en la base de datos SQLite local.'),
        actions: [
          // Cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          // Confirmar borrado
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerramos el diálogo
              final db = DatabaseHelper.instance;
              await db.deleteTodasLasAreas(); // Llamada al helper para borrar

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
