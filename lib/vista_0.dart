import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';

class Vista0 extends StatefulWidget {
  const Vista0({super.key});

  @override
  State<Vista0> createState() => _Vista0State();
}

class _Vista0State extends State<Vista0> {
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