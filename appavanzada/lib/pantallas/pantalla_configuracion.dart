import 'package:flutter/material.dart';
import '../services/area_storage.dart'; // Importamos para poder borrar datos si quieres

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  // Estado local para simular las preferencias
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

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
          // 1. Cabecera de Usuario (Estética)
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

          // 2. Sección General
          _buildSectionTitle('General'),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Modo Oscuro'),
            subtitle: const Text('Cambiar la apariencia de la aplicación'),
            secondary: const Icon(Icons.dark_mode),
            value: _isDarkMode,
            onChanged: (bool value) {
              setState(() => _isDarkMode = value);
              // Aquí llamarías a tu ThemeProvider
            },
          ),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Notificaciones'),
            subtitle: const Text('Recibir alertas de mantenimiento'),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),

          const Divider(),

          // 3. Sección de Seguridad
          _buildSectionTitle('Seguridad'),
          SwitchListTile(
            activeColor: const Color(0xFF0095FF),
            title: const Text('Biometría'),
            subtitle: const Text('Usar huella para entrar'),
            secondary: const Icon(Icons.fingerprint),
            value: _biometricEnabled,
            onChanged: (val) => setState(() => _biometricEnabled = val),
          ),

          const Divider(),

          // 4. ZONA DE PELIGRO (Muy útil para SQLite)
          _buildSectionTitle('Base de Datos y Almacenamiento'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Borrar todas las áreas', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Esta acción no se puede deshacer'),
            onTap: () => _showDeleteConfirmation(context),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Copia de seguridad'),
            subtitle: const Text('Guardar configuración en la nube'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función Próximamente')),
              );
            },
          ),

          const SizedBox(height: 30),

          // Versión de la app
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

  // Diálogo para confirmar borrado de base de datos
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Esto borrará toda la base de datos SQLite local. Tus áreas desaparecerán.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo

              // Llamamos al método clear() de tu AreaStorage
              await AreaStorage().clear();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Base de datos reiniciada')),
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