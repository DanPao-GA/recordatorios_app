import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


Future<void> guardarRecordatorioProgramado( {
  
  required String nombre, 
  required fecha,
  required hora,
  required FlutterLocalNotificationsPlugin notificationsPlugin 
  
  } ) async {

    DateTime fechaHoraCompleta = DateTime.parse('$fecha $hora');

    int nuevoId = 1; //aqui es donde se obtien elel ultimo id insertado ede la bdd

    final tz.TZDateTime horaProgramada = tz.TZDateTime.from(
      fechaHoraCompleta,
      tz.local,

    );

    const NotificationDetails details = NotificationDetails();

  await notificationsPlugin.zonedSchedule(nuevoId, nombre, '', horaProgramada, details, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);

  }




