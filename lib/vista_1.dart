import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart'; 

class Vista1 extends StatefulWidget {
  const Vista1({super.key});

  @override
  State<Vista1> createState() => _Vista1State();
}

class _Vista1State extends State<Vista1> {
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