import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:recordatorios_app/vista_0.dart';
import 'package:recordatorios_app/vista_1.dart';
import 'package:recordatorios_app/vista_2.dart';
import 'package:recordatorios_app/AppColors.dart';

class InterfazGraficaMenu extends StatefulWidget {
  const InterfazGraficaMenu({super.key, required this.title});

  final String title;

  @override
  State<InterfazGraficaMenu> createState() => _InterfazGraficaMenuState();
}

class _InterfazGraficaMenuState extends State<InterfazGraficaMenu> {
  final PageController _pageController = PageController(initialPage: 1);
  int _paginaActual = 1;
  bool _cambioEnCurso = false;

  Future<void> _cambiarPagina(int nuevaPagina) async {
    if (!_pageController.hasClients ||
        _cambioEnCurso ||
        nuevaPagina < 0 ||
        nuevaPagina >= 3) {
      return;
    }

    _cambioEnCurso = true;
    try {
      await _pageController.animateToPage(
        nuevaPagina,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _cambioEnCurso = false;
    }
  }

  void _manejarRueda(PointerSignalEvent signal) {
    if (signal is! PointerScrollEvent || _cambioEnCurso) return;

    final delta = signal.scrollDelta.dy != 0
        ? signal.scrollDelta.dy
        : signal.scrollDelta.dx;
    if (delta == 0) return;

    final pagina = _pageController.hasClients
        ? (_pageController.page ?? _paginaActual).round()
        : _paginaActual;
    final siguientePagina = pagina + (delta > 0 ? 1 : -1);
    if (siguientePagina >= 0 && siguientePagina < 3) {
      _cambiarPagina(siguientePagina);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Somos los Dart')),
      backgroundColor: AppColors.colorBase5,
      body: Column(
        children: [
          Expanded(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerSignal: _manejarRueda,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _paginaActual = index),
                  children: const [Vista0(), Vista1(), Vista2()],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final activo = _paginaActual == index;
                return GestureDetector(
                  onTap: () => _cambiarPagina(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: activo ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: activo ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
