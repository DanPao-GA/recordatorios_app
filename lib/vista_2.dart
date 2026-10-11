import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';



class Vista2 extends StatefulWidget {
  const Vista2({super.key});

  @override
  State<Vista2> createState() => _Vista2State();
}

class _Vista2State extends State<Vista2> {
  @override
  Widget build(BuildContext context) {
  double anchoPantalla = MediaQuery.of(context).size.width; //pa saber el ancho de la pantalla
    return Scaffold(

      backgroundColor: AppColors.colorBase3,
      body: Padding(
      padding: const EdgeInsets.all(16.0),

      child: anchoPantalla < 600 ? 
      //verdadero: tlf
    SingleChildScrollView(
      child:Column(
        children: [

         // Expanded( CRASHEA SI LO USAS PA TLF NO SUAR
            Container(
              padding: EdgeInsets.all(16.0), //esto es para que el contenido no toque los bordes de la pantalla
              decoration: BoxDecoration(
                color: AppColors.colorBase4, //esto es para que el contenido tenga un color de fondo
                border: Border.all(color: Colors.white, width: 2.0), //esto es para que el contenido tenga un borde blanco
                borderRadius: BorderRadius.circular(16.0), //esto es para que el contenido tenga bordes redondeados
              ),
            
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, //esto centra el contenido horizontalmente
                children: [
                  Text('Contenido de la Vista 2'),
                ],
              ),
            ),
          //),
          // rojas se van a ver las rosas de este jardin !
            const SizedBox(width: 16), //caja de separacion

          Container(
              padding: EdgeInsets.all(16.0), //esto es para que el contenido no toque los bordes de la pantalla
              decoration: BoxDecoration(
                color: AppColors.colorBase4, //esto es para que el contenido tenga un color de fondo
                border: Border.all(color: Colors.white, width: 2.0), //esto es para que el contenido tenga un borde blanco
                borderRadius: BorderRadius.circular(16.0), //esto es para que el contenido tenga bordes redondeados
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Contenido de la Vista 2'),
                ],
              ),
            ),
        ],
        ),
      )

      ///////// ROW PARA PANTALLAS GRANDES
      : Row(
        mainAxisAlignment: MainAxisAlignment.center, //esto centra el contenido horizontalmente
        crossAxisAlignment: CrossAxisAlignment.center, //esto centra el contenido verticalmente sin importar el tamaño de la pantalla
        children: [

          Expanded( //esto es para que el contenido ocupe todo el espacio disponible en la pantalla, sin esto el contenido se vería muy pequeño en pantallas grandes y flutter se vuelve loco y no sabe donde poner el contenido
            child: Container(
              padding: EdgeInsets.all(16.0), //esto es para que el contenido no toque los bordes de la pantalla
              decoration: BoxDecoration(
                color: AppColors.colorBase4, //esto es para que el contenido tenga un color de fondo
                border: Border.all(color: Colors.white, width: 2.0), //esto es para que el contenido tenga un borde blanco
                borderRadius: BorderRadius.circular(16.0), //esto es para que el contenido tenga bordes redondeados
              ),
            
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, //esto centra el contenido horizontalmente
                children: [
                  Text('Contenido de la Vista 2'),
                ],
              )
            ),
          ),

            const SizedBox(width: 16), //caja de separacion

          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0), //esto es para que el contenido no toque los bordes de la pantalla
              decoration: BoxDecoration(
                color: AppColors.colorBase4, //esto es para que el contenido tenga un color de fondo
                border: Border.all(color: Colors.white, width: 2.0), //esto es para que el contenido tenga un borde blanco
                borderRadius: BorderRadius.circular(16.0), //esto es para que el contenido tenga bordes redondeados
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Contenido de la Vista 2'),
                ],
              ),
            ),
          ),

          ],
        ),
      ),
    );
  }
}