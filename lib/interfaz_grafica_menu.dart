import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:recordatorios_app/vista_1.dart';
import 'package:recordatorios_app/vista_2.dart';
import 'package:recordatorios_app/AppColors.dart';


// class AppColors {
//   static const Color colorBase1 = Color.fromARGB(255, 9, 0, 135);
//   static const Color colorBase1_2 = Color.fromARGB(255, 25, 19, 110);
//   static const Color colorBase2 = Color.fromARGB(255, 242, 255, 233);
//   static const Color colorBase3 = Color.fromARGB(255, 242, 164, 165);
//   static const Color colorBase4 = Color.fromARGB(255, 229, 212, 197);
//   static const Color colorBase5 = Color.fromARGB(255, 48, 120, 164);
//   static const Color colorTexto = Colors.white;
// }


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
  PageController _pageController = PageController();
  int _paginaActual = 0;

  void _cambiarPagina(int nuevaPagina) {
    if (nuevaPagina >= 0 && nuevaPagina < 2) {
      _pageController.animateToPage(
        nuevaPagina,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Somos los Dart')),
      backgroundColor: AppColors.colorBase5,
      body: Column(
        children: [
          // Parte central con flechas a los lados y PageView
          Expanded(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => _cambiarPagina(_paginaActual - 1),
                ),
                
                Expanded(
  // Listener captura la rueda del mouse
  child: Listener(
    onPointerSignal: (pointerSignal) {
      if (pointerSignal is PointerScrollEvent) {
        if (pointerSignal.scrollDelta.dy > 0) {
          _cambiarPagina(_paginaActual + 1);
        } else if (pointerSignal.scrollDelta.dy < 0) {
          _cambiarPagina(_paginaActual - 1);
        }
      }
    },
    // AQUÍ METES EL SCROLL CONFIGURATION ENVOLVIENDO AL PAGEVIEW:
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse, // Permite arrastrar con el clic izquierdo
          PointerDeviceKind.trackpad,
        },
      ),

      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _paginaActual = index),
        children: const [
          vista_1(),
          //Center(child: Text('Vista 1', style: TextStyle(color: Colors.white, fontSize: 24))),
          


          vista_2(),
          Center(child: Text('Vista 2', style: TextStyle(color: Colors.white, fontSize: 24))),
        ],
      ),
    ),
  ),
),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                  onPressed: () => _cambiarPagina(_paginaActual + 1),
                ),
              ],
            ),
          ),

          // Indicador de puntos simple en la parte inferior
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _paginaActual == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _paginaActual == index ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
