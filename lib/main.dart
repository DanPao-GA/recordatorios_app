import 'package:flutter/material.dart';
import 'package:recordatorios_app/interfaz_grafica_menu.dart';

void main() {
  runApp(const PantallaRecordatorios());
}

class PantallaRecordatorios extends StatelessWidget {
  const PantallaRecordatorios({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'Recordatorios App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 106, 255, 223)),
        scaffoldBackgroundColor: AppColors.colorBase5,
        //scaffoldBackgroundColor: const Color.fromARGB(255, 236, 175, 233)
      ),
      home: const InterfazGraficaMenu(title: 'Interfaz Gráfica Menu'),
    );
  }
}
