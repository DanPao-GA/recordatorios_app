import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'bdd.dart';

// Modelo de Hábito que incluye su temporizador (intervalo en minutos)
class Habit {
  int id; 
  String name;
  bool isActive;
  int intervalMinutes;
  IconData icon;
  String type;

// Y LUEGO MODIFICAR LA VISTA PARA QUE MUESTRE LOS HABITOS SEGUN SU TIPO, 
// Y TAMBIEN MODIFICAR LA BDD PARA QUE GUARDE EL TIPO DE HABITO Y SUS ATRIBUTOS CORRESPONDIENTES


  Habit({
    required this.id,
    required this.name,
    this.isActive = true,
    required this.intervalMinutes,
    required this.icon,
    required this.type,
  });
}

class Vista0 extends StatefulWidget {
  const Vista0({super.key});

  @override
  State<Vista0> createState() => _Vista_0State();
}

class _Vista_0State extends State<Vista0> {
  List<Habit> _habitos = [];
  @override
    void initState() {
    super.initState();
    _cargarHabitos();
    }
    Future<void> _cargarHabitos() async {
  final filas = await DatabaseHelper().obtenerHabitos();

  final habitos = filas.map((fila) {
    return Habit(
      id: fila['id'] as int, // esto es el id del hábito
      name: fila['nombre'] as String, // el nombre
      isActive: fila['activo'] == 1, // aqui es pa q muestre el activo
      intervalMinutes: (fila['intervalo_minutos'] as int?) ?? 0, // si tiene intervalo, si no, 0
      icon: IconData(
          (fila['icono'] as int?) ?? Icons.notifications.codePoint,
            fontFamily: 'MaterialIcons',
            ), // el icono
      type: fila['tipo'] as String, // el tipo
    );
  }).toList();

  if (!mounted) return;

  setState(() {
    _habitos = habitos;
  });
}


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
                          color: Colors.black.withValues(alpha: 0.05),
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
                          activeThumbColor: AppColors.colorBase1,
                          onChanged: (bool value) async{
                            // Actualizar el estado del hábito en la base de datos
                            await DatabaseHelper().actualizarEstadoHabito(habito.id, value,);
                            setState(() {
                              habito.isActive = value;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        // Botón para eliminar el hábito
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () async {
                            final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Eliminar hábito'),
                                content: const Text(
                                  '¿Estás seguro de que deseas eliminar este hábito?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(false);
                                    },
                                    child: const Text('No'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop(true);
                                    },
                                    child: const Text('Sí'),
                                  ),
                                ],
                              );
                            },
                            );

                            if (confirmar != true) {
                            return;
                            }

                            final filasEliminadas =
                              await DatabaseHelper().eliminarHabito(habito.id);

                            if (filasEliminadas == 1 && mounted) {
                            setState(() {
                              _habitos.removeWhere((item) => item.id == habito.id);
                            });
                            }
                            },
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