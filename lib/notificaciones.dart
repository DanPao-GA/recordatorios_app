//import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:flutter/material.dart';
//import 'package:recordatorios_app/AppColors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:timezone/timezone.dart' as tz;
import 'dart:io';


    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> guardarRecordatorioProgramadoSemanal( {
  
  required int id,
  required String nombre, 
 // required fecha,
  required hora,
  required dia
//  required FlutterLocalNotificationsPlugin notificationsPlugin 
  
  } ) async {

    if (!Platform.isWindows) {
      throw UnsupportedError('La programación de tareas está implementada para Windows.');
    }
    
  const diasWindows = <String, String>{
    'lunes': 'MON',
    'martes': 'TUE',
    'miércoles': 'WED',
    'jueves': 'THU',
    'viernes': 'FRI',
    'sábado': 'SAT',
    'domingo': 'SUN',
  };

  final String? codigoDia = diasWindows[dia.toLowerCase()];
  if (codigoDia == null) {
    throw ArgumentError.value(dia, 'dia', 'Día de la semana no reconocido.');
  }
  
  final String nombreTarea = 'Habito_${id}_$codigoDia';

  final String ntl =  nombreTarea.replaceAll("'", "''");

  final Directory tempDir = Directory.systemTemp;
  final File scriptFile = File('${tempDir.path}/notif_$nombreTarea.ps1');


final String contenidoPs = '''
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipIcon = 'Info'
\$notification.BalloonTipTitle = 'RIN: \n$nombre'
\$notification.BalloonTipText = 'HA LLEGADO LA HORA DE: $nombre'
\$notification.Visible = \$true
\$notification.ShowBalloonTip(10000)
Start-Sleep -s 10
\$notification.Dispose()
''';

  await scriptFile.writeAsString(contenidoPs);

final String accion = 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "${scriptFile.path}"';



    List<String> argumentos = [
    '/Create',
    '/SC', 'WEEKLY',
    '/D', codigoDia,
    '/TN', ntl,
    '/TR', accion,
    '/ST', hora,
    '/IT',
    '/F',
  ];

  final resultado = await Process.run('schtasks', argumentos);

  
  if (resultado.exitCode != 0) {
    throw ProcessException(
      'schtasks',
      argumentos,
      resultado.stderr.toString(),
      resultado.exitCode,
    );
  }
  }


Future<void> guardarRecordatorioProgramadoUnico( {
  
  required int id,
  required String nombre, 
  required fecha,
  required hora,
  
  } ) async {

    if (!Platform.isWindows) {
      throw UnsupportedError('La programación de tareas está implementada para Windows.');
    }
  
  final String fechaStr = fecha.toString().split(' ').first.replaceAll(RegExp(r'[/\\:\s]'), '');
  final String nombreTarea = 'HabitoUnico_${id}_$fechaStr';
  
  final String ntl =  nombreTarea.replaceAll("'", "''");

  final Directory tempDir = Directory.systemTemp;
  final File scriptFile = File('${tempDir.path}/notif_$nombreTarea.ps1');

final String contenidoPs = '''
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipIcon = 'Info'
\$notification.BalloonTipTitle = 'RIN: \n$nombre'
\$notification.BalloonTipText = 'HA LLEGADO LA HORA DE: $nombre'
\$notification.Visible = \$true
\$notification.ShowBalloonTip(10000)
Start-Sleep -s 10
\$notification.Dispose()
''';

  await scriptFile.writeAsString(contenidoPs);

final String accion = 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "${scriptFile.path}"';

final String anio = fecha.year.toString();
final String mes = fecha.month.toString().padLeft(2, '0');
final String dia = fecha.day.toString().padLeft(2, '0');

// schtasks exige estrictamente MM/DD/YYYY para el parámetro /SD en tareas de tipo ONCE
final String fechaSchtasks = '$mes/$dia/$anio';

//final String fechaSchtasks = fecha.toString().split(' ').first.replaceAll('-', '/'); // debe ser YYYY-MM-DD o YYYY/MM/DD

    List<String> argumentos = [
    '/Create',
    '/SC', 'ONCE',
    '/SD', fechaSchtasks, //fecha
    '/TN', ntl, //NOMBRE Q SE VA A PONER
    '/TR', accion, //ACCION DEL TASK SCHEDULER
    '/ST', hora, // HORA
    '/IT',
    '/F',
  ];

  final resultado = await Process.run('schtasks', argumentos);

  
  if (resultado.exitCode != 0) {
    throw ProcessException(
      'schtasks',
      argumentos,
      resultado.stderr.toString(),
      resultado.exitCode,
    );
  }
  }



Future<void> guardarRecordatorioProgramadoIntervalo( {
  
  required int id,
  required String nombre, 
  required minuto,
  required hora
  
  } ) async {

    if (!Platform.isWindows) {
      throw UnsupportedError('La programación de tareas está implementada para Windows.');
    }
  
final int horasInt = int.parse(hora.text.isEmpty ? '0' : hora.text);
final int minutosInt = int.parse(minuto.text.isEmpty ? '0' : minuto.text);

// 2. Ahora sí puedes hacer la operación matemática limpia
final int intervalo = (horasInt * 60) + minutosInt;

  final String nombreTarea = 'HabitoIntervalo_${id}_$intervalo';
  
  final String ntl =  nombreTarea.replaceAll("'", "''");

  final Directory tempDir = Directory.systemTemp;
  final File scriptFile = File('${tempDir.path}/notif_$nombreTarea.ps1');

final String contenidoPs = '''
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
\$notification = New-Object System.Windows.Forms.NotifyIcon
\$notification.Icon = [System.Drawing.SystemIcons]::Information
\$notification.BalloonTipIcon = 'Info'
\$notification.BalloonTipTitle = 'RIN: \n$nombre'
\$notification.BalloonTipText = 'HA LLEGADO LA HORA DE: $nombre'
\$notification.Visible = \$true
\$notification.ShowBalloonTip(10000)
Start-Sleep -s 10
\$notification.Dispose()
''';

  await scriptFile.writeAsString(contenidoPs);

final String accion = 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "${scriptFile.path}"';

    List<String> argumentos = [
    '/Create',
    '/SC', 'MINUTE',
    '/MO', intervalo.toString(),
   // '/SD', fechaSchtasks, //fecha
    '/TN', ntl, //NOMBRE Q SE VA A PONER
    '/TR', accion, //ACCION DEL TASK SCHEDULER
   // '/ST', hora, // HORA
    '/IT',
    '/F',
  ];

  final resultado = await Process.run('schtasks', argumentos);

  
  if (resultado.exitCode != 0) {
    throw ProcessException(
      'schtasks',
      argumentos,
      resultado.stderr.toString(),
      resultado.exitCode,
    );
  }
  }








Future<void> cancelarRecordatorioProgramadosSemanal({
  required int id,
  required Iterable<String> dias,
}) async {
  if (!Platform.isWindows) {
    throw UnsupportedError('La cancelación está implementada para Windows.');
  }

  const diasWindows = <String, String>{
    'lunes': 'MON',
    'martes': 'TUE',
    'miércoles': 'WED',
    'jueves': 'THU',
    'viernes': 'FRI',
    'sábado': 'SAT',
    'domingo': 'SUN',
  };

  for (final String dia in dias) {
    final String? codigoDia = diasWindows[dia.toLowerCase()];
    if (codigoDia == null) {
      throw ArgumentError.value(dia, 'dia', 'Día de la semana no reconocido.');
    }

    final String nombreTarea = 'RecordatorioHabito_${id}_$codigoDia';
    final argumentos = ['/Delete', '/TN', nombreTarea, '/F'];
    final resultado = await Process.run('schtasks', argumentos);

    if (resultado.exitCode != 0) {
      throw ProcessException(
        'schtasks',
        argumentos,
        resultado.stderr.toString(),
        resultado.exitCode,
      );
    }
  }
}




String obtenerProximaFechaSemanal(String diaSemana, TimeOfDay horaInput) {

  Map<String, int> diasMap = {

    'lunes': 1,
    'martes': 2,
    'miercoles': 3,
    'jueves': 4,
    'viernes': 5,
    'sabado': 6,
    'domingo': 7,
  };

  int diaObjetivo = diasMap[diaSemana.toLowerCase()] ?? 1;

  DateTime ahora = DateTime.now();

  int diaActual = ahora.weekday;

  int diasDiferencia = diaObjetivo - diaActual;

  if (diasDiferencia < 0 ){
    diasDiferencia+=7; // pa q vaya a la sig semana si es hoy o ya paso la hora
      } 
  else if (diasDiferencia == 0 ){

    DateTime fechaHoraHoy = DateTime(ahora.year, ahora.month, ahora.day, horaInput.hour, horaInput.minute);

    if (ahora.isAfter(fechaHoraHoy)){
      diasDiferencia +=7;
    }
  }


  DateTime proximaFecha = ahora.add(Duration(days: diasDiferencia));

  String anio = proximaFecha.year.toString();
  String mes = proximaFecha.month.toString().padLeft(2, '0');
  String dia = proximaFecha.day.toString().padLeft(2, '0');

  return '$anio-$mes-$dia';
}


