import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';

// Modelo de Hábito que incluye su temporizador (intervalo en minutos)
class Habit {
  String name;
  bool isActive;
  int intervalMinutes;
  IconData icon;

// DAVID, DEBES TAMBIEN MODIFICAR ESTO DEBIDO A QUE 
// LOS HABITOS PUEDEN SER DE TIPO INTERVALO, UNICO O SEMANAL,
// POR LO QUE DEBES AGREGAR UN ATRIBUTO TIPO, Y SI
// EL TIPO ES INTERVALO, AGREGAR EL ATRIBUTO intervalMinutes, 
// SI ES UNICO, AGREGAR EL ATRIBUTO fechaUnica, 
// Y SI ES SEMANAL, AGREGAR EL ATRIBUTO diasSemana (LISTA DE BOOLEANOS PARA CADA DIA DE LA SEMANA)
// BASICAMENTE, REESTRUCTURAR ESTA CLASE PARA QUE PUEDA REPRESENTAR LOS TRES TIPOS DE HABITOS, 
// Y LUEGO MODIFICAR LA VISTA PARA QUE MUESTRE LOS HABITOS SEGUN SU TIPO, 
// Y TAMBIEN MODIFICAR LA BDD PARA QUE GUARDE EL TIPO DE HABITO Y SUS ATRIBUTOS CORRESPONDIENTES

  Habit({
    required this.name,
    this.isActive = true,
    required this.intervalMinutes,
    required this.icon,
  });
}

class vista_0 extends StatefulWidget {
  const vista_0({super.key});

  @override
  State<Vista0> createState() => _Vista0State();
}

class _vista_0State extends State<vista_0> {
  // Lista inicial de hábitos con sus respectivos temporizadores
  final List<Habit> _habitos = [
    Habit(name: 'Pausa de hidratación', intervalMinutes: 10, icon: Icons.water_drop),
    Habit(name: 'Pausa de estiramiento', intervalMinutes: 30, icon: Icons.accessibility_new),
    Habit(name: 'Descanso de vista', intervalMinutes: 20, icon: Icons.remove_red_eye),
  ];

  // Función para eliminar un hábito de la lista
  void _eliminarHabito(int index) {
    setState(() {
      _habitos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBase4,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera "Active Habits"
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.colorBase1,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Active Habits',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Lista dinámica de hábitos activos
            Expanded(
              child: ListView.builder(
                itemCount: _habitos.length,
                itemBuilder: (context, index) {
                  final habito = _habitos[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(habito.icon, color: AppColors.colorBase5),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habito.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Temporizador: Cada ${habito.intervalMinutes} min',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Switch para activar/desactivar el hábito
                        Switch(
                          value: habito.isActive,
                          activeColor: AppColors.colorBase1,
                          onChanged: (bool value) {
                            setState(() {
                              habito.isActive = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        // Botón para eliminar el hábito
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _eliminarHabito(index),
                          tooltip: 'Eliminar hábito',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}