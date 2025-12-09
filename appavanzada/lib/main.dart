import 'package:appavanzada/pantallas/pantalla_areas.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Necesario para inicializar bindings antes de usar async en main
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatos de fecha en español
  await initializeDateFormatting('es_ES', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // Deshabilitar el debug banner
      debugShowCheckedModeBanner: false,
      // Pantalla principal de la app
      home: Scaffold(
        body: PantallaAreas(), // Aquí se muestra la pantalla de áreas
      ),
    );
  }
}
