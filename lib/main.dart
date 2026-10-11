import 'package:flutter/material.dart';
import 'package:recordatorios_app/interfaz_grafica_menu.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'dart:io'; // Para detectar la plataforma (Platform.isWindows)
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Necesario para Windows/Linux/macOS
import 'package:recordatorios_app/bdd.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración para Windows o plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit(); // Inicializa el motor FFI de SQLite
    databaseFactory = databaseFactoryFfi; // Asigna la fábrica para escritorio
  }

  // Esto inicializa la bdd, no tocar
  await DatabaseHelper().database;

  runApp(const PantallaRecordatorios());
}

class PantallaRecordatorios extends StatelessWidget {
  const PantallaRecordatorios({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Recordatorios App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 106, 255, 223)),
        scaffoldBackgroundColor: AppColors.colorBase5,
      ),
      home: const InterfazGraficaMenu(title: 'Interfaz Gráfica Menu'),
    );
  }
}
