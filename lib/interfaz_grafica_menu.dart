import 'package:flutter/material.dart';


class AppColors {
  static const Color colorBase1 = Color.fromARGB(255, 9, 0, 135);
  static const Color colorBase1_2 = Color.fromARGB(255, 25, 19, 110);
  static const Color colorBase2 = Color.fromARGB(255, 242, 255, 233);
  static const Color colorBase3 = Color.fromARGB(255, 242, 164, 165);
  static const Color colorBase4 = Color.fromARGB(255, 229, 212, 197);
  static const Color colorBase5 = Color.fromARGB(255, 48, 120, 164);
  static const Color colorTexto = Colors.white;
}


// class PantallaRecordatorios extends StatelessWidget {
//   const PantallaRecordatorios({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: Text('Recordatorios App'),
//       theme: ThemeData(
//         colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 106, 255, 223)),
//         scaffoldBackgroundColor: colorBase5,
//         //scaffoldBackgroundColor: const Color.fromARGB(255, 236, 175, 233)
//       ),
//       home: const Aprendiendo(title: 'Aprendiendo'),
//     );
//   }
// }

class InterfazGraficaMenu extends StatefulWidget {
  const InterfazGraficaMenu({super.key, required this.title});

  final String title;

  @override
  State<InterfazGraficaMenu> createState() => _InterfazGraficaMenuState();
}

class _InterfazGraficaMenuState extends State<InterfazGraficaMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        //center solo acpeta un child, es decir, un hijo, y ese hijo puede ser otro widget que tenga hijos, como un Column 
        //o un Row, un row es una fila
        child: Column(

        // o uso spacing o uso const SizedBox(height: 12), entre los btoones
          mainAxisAlignment: .center, // esto es para indicar que los hijos del Column se van a centrar verticalmente
          spacing: 12, // esto indica 12 pixeles de espacio entre los hijos del Column, es decir, entre los botones
          children: <Widget>[ // <widget> es para indicar que los hijos del Column son widgets, y es necesario para que el Column funcione correctamente
          
            Text ('RECORDATORIOS',
            style: TextStyle(
                color: AppColors.colorBase4,
                fontSize: 48,
                fontWeight: FontWeight.bold
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute<void>(builder: (BuildContext context) => const SomosLosDarts()));
              },
// el context es lo q le indica a flutter donde esta el boton, en q pantalla pues, en este caso en la
// pantalla de menu, el siguiente es pa q cuando se presione el boton, ese context se reconstruya (s un constructor en tiempo real)
// y sepa a que pantaklla ir, en este caso a la pantalla de SomosLosDarts, q es la pantalla de info

              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.sizeOf(context).width * 0.5, 48), // esto es para indicar que el boton va a ocupar la mitad del ancho de la pantalla, y es necesario para que el boton funcione correctamente
                backgroundColor: AppColors.colorBase4 // esto es para indicar que el color del boton va a ser blanco, y es necesario para que el boton funcione correctamente
              ),
              child: const Text('INICIAR / DETENER', style: TextStyle(fontSize: 16)),
            ),

            ElevatedButton(
              onPressed: () {
                print('sdasd'); //esto se ve en la consola de debug, no en la terminal TT
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.sizeOf(context).width * 0.5, 48), // esto es para indicar que el boton va a ocupar la mitad del ancho de la pantalla, y es necesario para que el boton funcione correctamente
                backgroundColor: AppColors.colorBase4 // esto es para indicar que el color del boton va a ser blanco, y es necesario para que el boton funcione correctamente
              ),
              child: const Text('VISUALIZAR RECORDATORIOS', style: TextStyle(fontSize: 16)),
            ),

            ElevatedButton(
              onPressed: () {
                print('Elevated Button3 pressed');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.sizeOf(context).width * 0.5, 48), // esto es para indicar que el boton va a ocupar la mitad del ancho de la pantalla, y es necesario para que el boton funcione correctamente
                backgroundColor: AppColors.colorBase4 // esto es para indicar que el color del boton va a ser blanco, y es necesario para que el boton funcione correctamente
              ),
              child: const Text('INFO', style: TextStyle(fontSize: 16)),
            ),
          ],

        )

      ),
    );
  }
}

class SomosLosDarts extends StatefulWidget{

  const SomosLosDarts({super.key});
  @override
  State<SomosLosDarts> createState() => _SomosLosDartsState();
}


class _SomosLosDartsState extends State<SomosLosDarts>{
  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar: AppBar(
       // title: const Text('Somos los Dart'),
      ),
      backgroundColor: const Color.fromARGB(255, 90, 79, 129),
      body : Center (
        child: const Text('Somos los Dart', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      )
  
    );

  }
}



