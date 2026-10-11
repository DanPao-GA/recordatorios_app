import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';

class vista_0 extends StatefulWidget {
  const vista_0({super.key});

  @override
  State<vista_0> createState() => _vista_0State();
}

class _vista_0State extends State<vista_0> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBase2,
      body: Center(
        child: Text('Contenido de la Vista 0'),
      ),
    );
  }
}