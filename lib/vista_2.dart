import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';

class vista_2 extends StatefulWidget {
  const vista_2({super.key});

  @override
  State<vista_2> createState() => _vista_2State();
}

class _vista_2State extends State<vista_2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBase3,
      body: Center(
        child: Text('Contenido de la Vista 2'),
      ),
    );
  }
}