import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart'; 

class vista_1 extends StatefulWidget {
  const vista_1({super.key});

  @override
  State<vista_1> createState() => _vista_1State();
}

class _vista_1State extends State<vista_1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.colorBase4,

      body: Center(
        child: Text('Contenido de la Vista 1'),
      ),
    );
  }
}