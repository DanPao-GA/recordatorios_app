import 'package:flutter/material.dart';
import 'package:recordatorios_app/interfaz_grafica_menu.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'dart:io'; // Para detectar la plataforma (Platform.isWindows)
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Necesario para Windows/Linux/macOS
import 'package:recordatorios_app/bdd.dart';
import 'package:recordatorios_app/notificaciones.dart';
//notificaciones 
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
import 'package:local_notifier/local_notifier.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración para Windows o plataformas de escritorio
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit(); // Inicializa el motor FFI de SQLite
    databaseFactory = databaseFactoryFfi; // Asigna la fábrica para escritorio
  }

  // Esto inicializa la bdd, no tocar
  await DatabaseHelper().database; //fua ya iba yo a tocar esto pq no sabia q era JAJAJAJA

  // flutter_local_notifications no tiene implementación registrada para Windows.
  // if (!Platform.isWindows) {
  //   tz.initializeTimeZones();

  //   final InitializationSettings initializationSettings = InitializationSettings();

  //   // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //   await flutterLocalNotificationsPlugin.initialize(
        
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (details) {
  //       print('En efecto');
  //     },
  //   );
  // }

  await localNotifier.setup(appName: 'RIN');

  if (args.length == 2 && args[0] == '--notificar') {
    await LocalNotification(
      title: 'Recordatorio',
      body: args[1],
    ).show();

    exit(0);
  }


  runApp(const PantallaRecordatorios());
}

class PantallaRecordatorios extends StatelessWidget {
  const PantallaRecordatorios({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Esto quita la banderita de debug que aparece en la esquina superior derecha
      title:'Recordatorios App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 106, 255, 223)),
        scaffoldBackgroundColor: AppColors.colorBase5,
      ),
      home: const InterfazGraficaMenu(title: 'Interfaz Gráfica Menu'),
    );
  }
}
