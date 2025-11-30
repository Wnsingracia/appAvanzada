import 'package:flutter/material.dart';
import 'pantalla_nueva_area.dart';

class PantallaSelecionArea extends StatefulWidget {
  const PantallaSelecionArea({super.key});

  @override
  State<PantallaSelecionArea> createState() => _PantallaSelecionAreaState();
}

class _PantallaSelecionAreaState extends State<PantallaSelecionArea> {
  int selectedTab = 0; // 0: Dentro, 1: Fuera, 2: Copiar

  List<String> _areasParaTab(int tab) {
    if (tab == 0) {
      // Dentro
      return [
        'Personalizar',
        'Sala de Estar',
        'Comedor',
        'Cocina',
        'Baño',
        'Dormitorio',
      ];
    } else if (tab == 1) {
      // Fuera
      return [
        'Personalizar',
        'Jardín',
        'Garaje',
        'Terraza',
        'Patio',
      ];
    }
    // Copiar (puede mostrar lo mismo que Dentro por ahora xd)
    return [
      'Seleccionar Area',
      'Sala de Estar',
      'Comedor',
      'Dormitorio',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Area'),
        backgroundColor: const Color(0xFF0095FF),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFF0095FF),
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona\nTipo de Area',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Tabs
                  Row(
                    children: List.generate(3, (i) {
                      final labels = ['Dentro', 'Fuera', 'Copiar'];
                      final isSelected = selectedTab == i;
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

          // Area list
          Container(
            height: 360,
            color: const Color(0xFF0095FF),
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: _areasParaTab(selectedTab).length,
                    separatorBuilder: (_, __) => const Divider(color: Colors.white30, height: 1),
                    itemBuilder: (context, index) {
                      final name = _areasParaTab(selectedTab)[index];
                      return ListTile(
                        title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        onTap: () {
                          if (name == 'Personalizar') {
                            // Abrir pantalla para crear una área personalizada
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PantallaNuevaArea(areaNombre: '', tipo: 0, isCustom: true),
                              ),
                            );
                          } else {
                            // Cuando selecciona un area existente, abrir pantalla nueva y pasar seleccion
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
