import 'package:appavanzada/pantallas/pantalla_areas.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatos en español
  await initializeDateFormatting('es_ES', null);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: PantallaAreas()
      ),
    );
  }
}
