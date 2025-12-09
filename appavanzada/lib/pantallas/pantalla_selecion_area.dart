import 'package:flutter/material.dart';
import 'pantalla_nueva_area.dart';

// Pantalla donde el usuario selecciona el tipo de área (Dentro, Fuera, Copiar)
class PantallaSelecionArea extends StatefulWidget {
  const PantallaSelecionArea({super.key});

  @override
  State<PantallaSelecionArea> createState() => _PantallaSelecionAreaState();
}

class _PantallaSelecionAreaState extends State<PantallaSelecionArea> {
  // Índice del tab seleccionado
  // 0 = Dentro, 1 = Fuera, 2 = Copiar
  int selectedTab = 0;

  // Retorna la lista de áreas según el tab seleccionado
  List<String> _areasParaTab(int tab) {
    if (tab == 0) {
      // Áreas "Dentro"
      return [
        'Personalizar', // opción para crear un área personalizada
        'Sala de Estar',
        'Comedor',
        'Cocina',
        'Baño',
        'Dormitorio',
      ];
    } else if (tab == 1) {
      // Áreas "Fuera"
      return [
        'Personalizar', // opción para crear un área personalizada
        'Jardín',
        'Garaje',
        'Terraza',
        'Patio',
      ];
    }
    // Áreas "Copiar" (puede ser igual que Dentro, por ahora)
    return ['Sala de Estar', 'Comedor', 'Dormitorio'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con título
      appBar: AppBar(
        title: const Text('Nueva Area'),
        backgroundColor: const Color(0xFF0095FF),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Parte superior azul con título y tabs
          Expanded(
            child: Container(
              color: const Color(0xFF0095FF),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
                  const Text(
                    'Selecciona\nTipo de Area',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Fila de tabs: Dentro, Fuera, Copiar
                  Row(
                    children: List.generate(3, (i) {
                      final labels = ['Dentro', 'Fuera', 'Copiar'];
                      final isSelected = selectedTab == i; // verificar si está activo
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            color: isSelected ? Colors.blue[600] : Colors.blue[400],
                            child: Center(
                              child: Text(
                                labels[i],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Lista de áreas disponibles según el tab
          Container(
            height: 360,
            color: const Color(0xFF0095FF),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _areasParaTab(selectedTab).length,
                    separatorBuilder: (_, __) =>
                        const Divider(color: Colors.white30, height: 1),
                    itemBuilder: (context, index) {
                      final name = _areasParaTab(selectedTab)[index];
                      return ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        onTap: () {
                          if (name == 'Personalizar') {
                            // Si selecciona "Personalizar", abrir pantalla para crear área nueva
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PantallaNuevaArea(
                                  areaNombre: '',
                                  tipo: 0, // default a Dentro
                                  isCustom: true,
                                ),
                              ),
                            );
                          } else {
                            // Si selecciona un área predefinida, abrir PantallaNuevaArea con datos
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PantallaNuevaArea(
                                  areaNombre: name,
                                  tipo: selectedTab,
                                  isCustom: false,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Esta pantalla permite al usuario seleccionar el tipo de área (Dentro, Fuera o Copiar),
// y luego elegir un área predefinida o crear una personalizada ("Personalizar").
