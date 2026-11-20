import 'dart:async';
import 'package:flutter/material.dart';
import 'package:recordatorios_app/AppColors.dart';
import 'bdd.dart';

// Momento en que se abrió la app: es el punto de partida para contar los intervalos
final DateTime _inicioApp = DateTime.now();

// Desde cuándo cuenta cada hábito de intervalo. Se borra al pausarlo y se
// vuelve a crear al reactivarlo, así su contador siempre empieza de cero.
final Map<int, DateTime> _inicios = {};
Set<int>? _activosPrevios;
Timer? _vigilante;

// Compara qué hábitos están activos ahora contra la vez anterior
Future<void> _vigilarActivaciones() async {
  final filas = await DatabaseHelper().obtenerHabitos();
  final activosAhora = filas
      .where((f) => f['activo'] == 1)
      .map((f) => f['id'] as int)
      .toSet();

  final previos = _activosPrevios;
  if (previos != null) {
    for (final id in activosAhora) {
      if (!previos.contains(id)) {
        _inicios[id] = DateTime.now(); // recién activado o creado: empieza de cero
      }
    }
    for (final id in previos) {
      if (!activosAhora.contains(id)) {
        _inicios.remove(id); // pausado o eliminado
      }
    }
  }
  _activosPrevios = activosAhora;
}

// Se inicia una sola vez y no se detiene aunque cambies de pantalla
void _iniciarVigilante() {
  if (_vigilante != null) return;
  _vigilarActivaciones();
  _vigilante = Timer.periodic(
    const Duration(seconds: 1),
    (_) => _vigilarActivaciones(),
  );
}

// Consejos: se muestra uno distinto cada día
const List<String> _consejos = [
  'Tómate un vaso de agua nada más levantarte cada mañana para un impulso natural de energía. ¡Sigue así!',
  'Cada hora, levántate y estira la espalda un minuto. Tu cuerpo te lo agradecerá.',
  'Mantén la pantalla a la altura de los ojos para no encorvar el cuello.',
  'Respira profundo 3 veces antes de empezar una tarea difícil.',
  'Cada 20 minutos mira algo lejano durante 20 segundos para descansar la vista.',
  'Dormir bien es un hábito también: intenta acostarte a la misma hora.',
  'Pequeños pasos todos los días valen más que un gran esfuerzo una vez.',
  'Camina 5 minutos después de comer, ayuda a la digestión y despeja la mente.',
  'Mantén una botella de agua a la vista: lo que se ve, se toma.',
  'Siéntate con la espalda apoyada y los pies en el suelo.',
  'Celebra tus avances, por pequeños que sean.',
  'Desconecta del celular 30 minutos antes de dormir.',
  'Una pausa corta no es perder tiempo, es recargar energía.',
  'Come una fruta hoy: tu futuro tú te lo agradecerá.',
  'No tienes que ser perfecto, solo constante.',
];

// Un recordatorio activo de la BDD (de tipo intervalo, unico o semanal)
class _Recordatorio {
  final int id;
  final String nombre;
  final String tipo; // 'intervalo', 'unico' o 'semanal'
  final IconData icono;
  final Duration? cada; // solo intervalo
  final DateTime? fechaUnica; // solo unico
  final int hora; // solo semanal
  final int minuto; // solo semanal
  final Set<int> dias; // solo semanal (1 = lunes ... 7 = domingo)

  _Recordatorio({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.icono,
    this.cada,
    this.fechaUnica,
    this.hora = 0,
    this.minuto = 0,
    this.dias = const {},
  });

  // Cuándo suena la próxima vez (null si ya no volverá a sonar)
  DateTime? siguiente(DateTime ahora) {
    final c = cada;
    if (c != null) {
      final base = _inicios[id] ?? _inicioApp;
      final ciclos = ahora.difference(base).inMicroseconds ~/ c.inMicroseconds;
      return base.add(c * (ciclos + 1));
    }

    final f = fechaUnica;
    if (f != null) {
      return f.isAfter(ahora) ? f : null;
    }

    for (var i = 0; i <= 7; i++) {
      final dia = ahora.add(Duration(days: i));
      if (dias.contains(dia.weekday)) {
        final candidato = DateTime(dia.year, dia.month, dia.day, hora, minuto);
        if (candidato.isAfter(ahora)) return candidato;
      }
    }
    return null;
  }

  // Cuántas veces sonó entre dos momentos (para el contador "Completados")
  int disparados(DateTime desde, DateTime hasta) {
    final c = cada;
    if (c != null) {
      final base = _inicios[id] ?? _inicioApp;
      final desdeReal = base.isAfter(desde) ? base : desde;
      return hasta.difference(desdeReal).inMicroseconds ~/ c.inMicroseconds;
    }

    final f = fechaUnica;
    if (f != null) {
      return (f.isAfter(desde) && !f.isAfter(hasta)) ? 1 : 0;
    }

    var total = 0;
    var dia = DateTime(desde.year, desde.month, desde.day);
    while (!dia.isAfter(hasta)) {
      if (dias.contains(dia.weekday)) {
        final f2 = DateTime(dia.year, dia.month, dia.day, hora, minuto);
        if (f2.isAfter(desde) && !f2.isAfter(hasta)) total++;
      }
      dia = dia.add(const Duration(days: 1));
    }
    return total;
  }
}

class _Proximo {
  final _Recordatorio recordatorio;
  final DateTime cuando;

  _Proximo(this.recordatorio, this.cuando);
}

class Vista1 extends StatefulWidget {
  const Vista1({super.key});

  @override
  State<Vista1> createState() => _Vista1State();
}

class _Vista1State extends State<Vista1> {
  Timer? _timer;
  int _ticks = 0;
  List<_Recordatorio> _recordatorios = [];
  List<_Proximo> _proximos = []; // ordenados del más cercano al más lejano
  int _activosTotal = 0;

  _Proximo? get _proximo => _proximos.isEmpty ? null : _proximos.first;

  @override
  void initState() {
    super.initState();
    _iniciarVigilante();
    _cargarHabitos();
    // Cada segundo se actualiza el contador; cada 5 segundos se vuelve a leer la BDD
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _ticks++;
      if (_ticks % 5 == 0) {
        _cargarHabitos();
      } else {
        _actualizar();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // importante: si no, el timer sigue corriendo
    super.dispose();
  }

  // Saca hora y minuto de un texto como "15:00"
  List<int>? _parseHora(String? texto) {
    if (texto == null) return null;
    final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(texto);
    if (m == null) return null;
    return [int.parse(m.group(1)!), int.parse(m.group(2)!)];
  }

  Future<void> _cargarHabitos() async {
    await _vigilarActivaciones(); // asegura que los reinicios ya estén registrados
    final db = await DatabaseHelper().database;
    final filas = await DatabaseHelper().obtenerHabitos();
    final semanales = await db.query('h_Semanal');

    // Días de cada hábito semanal: id -> {1..7}
    const columnas = [
      'lunes',
      'martes',
      'miercoles',
      'jueves',
      'viernes',
      'sabado',
      'domingo',
    ];
    final diasPorId = <int, Set<int>>{};
    for (final s in semanales) {
      final dias = <int>{};
      for (var i = 0; i < columnas.length; i++) {
        if (s[columnas[i]] == 1) dias.add(i + 1);
      }
      diasPorId[s['id'] as int] = dias;
    }

    final activos = filas.where((f) => f['activo'] == 1).toList();
    final lista = <_Recordatorio>[];

    for (final f in activos) {
      final id = f['id'] as int;
      final nombre = f['nombre'] as String;
      final tipo = f['tipo'] as String;
      final icono = IconData(
        (f['icono'] as int?) ?? Icons.notifications.codePoint,
        fontFamily: 'MaterialIcons',
      );

      if (tipo == 'intervalo') {
        final minutos = (f['intervalo_minutos'] as int?) ?? 0;
        if (minutos > 0) {
          lista.add(_Recordatorio(
            id: id,
            nombre: nombre,
            tipo: tipo,
            icono: icono,
            cada: Duration(minutes: minutos),
          ));
        }
      } else if (tipo == 'unico') {
        final hm = _parseHora(f['hora'] as String?);
        final fecha = (f['fecha'] as String?)?.split('-');
        if (hm != null && fecha != null && fecha.length == 3) {
          lista.add(_Recordatorio(
            id: id,
            nombre: nombre,
            tipo: tipo,
            icono: icono,
            fechaUnica: DateTime(
              int.parse(fecha[0]),
              int.parse(fecha[1]),
              int.parse(fecha[2]),
              hm[0],
              hm[1],
            ),
          ));
        }
      } else if (tipo == 'semanal') {
        final hm = _parseHora(f['hora'] as String?);
        final dias = diasPorId[f['h_Semanal_id'] as int?];
        if (hm != null && dias != null && dias.isNotEmpty) {
          lista.add(_Recordatorio(
            id: id,
            nombre: nombre,
            tipo: tipo,
            icono: icono,
            hora: hm[0],
            minuto: hm[1],
            dias: dias,
          ));
        }
      }
    }

    if (!mounted) return;
    _recordatorios = lista;
    _activosTotal = activos.length;
    _actualizar();
  }

  // Calcula cuál es el siguiente recordatorio de todos y cuánto falta
  void _actualizar() {
    if (!mounted) return;
    final ahora = DateTime.now();

    final proximos = <_Proximo>[];
    for (final r in _recordatorios) {
      final s = r.siguiente(ahora);
      if (s != null) proximos.add(_Proximo(r, s));
    }
    proximos.sort((a, b) => a.cuando.compareTo(b.cuando));

    setState(() {
      _proximos = proximos;
    });
  }

  // Recordatorios que ya sonaron desde que se abrió la app
  int get _completados {
    final ahora = DateTime.now();
    var total = 0;
    for (final r in _recordatorios) {
      total += r.disparados(_inicioApp, ahora);
    }
    return total;
  }

  String _formatear(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final dias = d.inDays;
    final h = d.inHours % 24;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    if (dias > 0) return '$dias d, $h h, $mm min';
    if (h > 0) return '$h h, $mm min, $ss seg';
    return '$m min, $ss seg';
  }

  String _etiquetaTipo(String tipo) {
    if (tipo == 'intervalo') return 'Intervalo';
    if (tipo == 'unico') return 'Único';
    return 'Semanal';
  }

  String _saludo() {
    final hora = DateTime.now().hour;
    if (hora < 12) return '¡Buenos días!';
    if (hora < 19) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  String get _consejoDelDia {
    final ahora = DateTime.now();
    final diaDelAnio = ahora.difference(DateTime(ahora.year, 1, 1)).inDays;
    return _consejos[diaDelAnio % _consejos.length];
  }

  BoxDecoration _decoracion(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // ---------- ENCABEZADO: BARRA CON LOGO Y TÍTULO ----------
  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.colorBase1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/logo_rin.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              // Si no encuentra la imagen, muestra una campana en vez de fallar
              errorBuilder: (_, __, ___) => const Icon(
                Icons.notifications,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'RIN',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
              Text(
                _saludo(),
                style: const TextStyle(fontSize: 15, color: Colors.white70),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _mostrarGuia,
            tooltip: 'Cómo usar RIN',
            icon: const Icon(Icons.help_outline, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ---------- TARJETA: TIP DEL DÍA ----------
  Widget _tarjetaTip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracion(AppColors.colorBase2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tip del Día',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(Icons.local_florist, size: 32, color: AppColors.colorBase5),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _consejoDelDia,
            style: const TextStyle(fontSize: 17, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ---------- TARJETA: PRÓXIMO RECORDATORIO ----------
  Widget _tarjetaProximo() {
    final prox = _proximo;

    if (prox == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _decoracion(Colors.white),
        child: const Column(
          children: [
            Icon(Icons.notifications_off_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No tienes recordatorios activos pendientes.\nCrea uno en la pantalla de la derecha →',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    final r = prox.recordatorio;
    final restante = prox.cuando.difference(DateTime.now());
    final horaTexto = TimeOfDay.fromDateTime(prox.cuando).format(context);

    final ahora = DateTime.now();
    final esHoy = prox.cuando.year == ahora.year &&
        prox.cuando.month == ahora.month &&
        prox.cuando.day == ahora.day;
    final cuandoTexto = esHoy
        ? 'Suena a las $horaTexto'
        : 'Suena el ${prox.cuando.day}/${prox.cuando.month} a las $horaTexto';

    final c = r.cada;
    final progreso = c == null
        ? null
        : (1 - restante.inSeconds / c.inSeconds).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _decoracion(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NEXT REMINDER:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            r.nombre,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _formatear(restante),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            cuandoTexto,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          if (progreso != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                color: AppColors.colorBase5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- LISTA: PRÓXIMOS RECORDATORIOS ----------
  Widget _tarjetaLista() {
    // Los que vienen después del primero (el primero ya está en el timer)
    final siguientes = _proximos.skip(1).take(5).toList();
    if (siguientes.isEmpty) return const SizedBox.shrink();

    final ahora = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoracion(Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Próximos recordatorios',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          for (final p in siguientes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(p.recordatorio.icono,
                      size: 22, color: AppColors.colorBase5),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.recordatorio.nombre,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _etiquetaTipo(p.recordatorio.tipo),
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatear(p.cuando.difference(ahora)),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ---------- GUÍA DE USO ----------
  Widget _paso(int numero, IconData icono, String titulo, String texto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.colorBase1,
            child: Text(
              '$numero',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icono, size: 20, color: AppColors.colorBase5),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  texto,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarGuia() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.colorBase2,
      constraints: const BoxConstraints(maxWidth: 600),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cómo usar RIN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.colorBase1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea tus hábitos y deja que RIN te lo recuerde.',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            _paso(
              1,
              Icons.swipe,
              'Desliza para navegar',
              'La app tiene 3 pantallas. Desliza hacia los lados (con el dedo o arrastrando con el mouse): a la izquierda está tu lista de hábitos, en el centro esta pantalla principal y a la derecha la de crear recordatorios.',
            ),
            _paso(
              2,
              Icons.add_alarm,
              'Crea un recordatorio',
              'Desliza a la derecha, escribe un nombre y elige el tipo: Intervalo (se repite cada cierto tiempo, por ejemplo cada 30 minutos), Único (una sola vez en una fecha y hora) o Semanal (los días que elijas a una hora fija). Luego presiona el botón de crear.',
            ),
            _paso(
              3,
              Icons.toggle_on,
              'Activa o pausa tus hábitos',
              'Desliza a la izquierda para ver tu lista. Con el interruptor puedes pausar o activar cada hábito. Si reactivas uno de intervalo, su cuenta empieza de cero.',
            ),
            _paso(
              4,
              Icons.delete_outline,
              'Elimina los que ya no uses',
              'En la lista de hábitos, toca el icono de la papelera y confirma para borrar un recordatorio.',
            ),
            _paso(
              5,
              Icons.timer,
              'Sigue tu próximo recordatorio',
              'Aquí, en la pantalla principal, verás cuál es el siguiente recordatorio con su cuenta regresiva, los que vienen después y cuántos has completado.',
            ),
            _paso(
              6,
              Icons.lightbulb_outline,
              'Lee el tip del día',
              'Cada día aparece una frase o consejo nuevo para motivarte a mantener tus buenos hábitos.',
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.colorBase1,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Entendido',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaGuia() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _decoracion(AppColors.colorBase5),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Primera vez en RIN?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Aprende a usar la app en un minuto',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _mostrarGuia,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.colorBase5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Ver guía',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- MINI TARJETAS DE RESUMEN ----------
  Widget _miniTarjeta(IconData icono, String valor, String etiqueta) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: _decoracion(AppColors.colorBase3.withValues(alpha: 0.6)),
        child: Column(
          children: [
            Icon(icono, color: AppColors.colorBase1),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              etiqueta,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width;
    final tip = _tarjetaTip();
    final proximo = _tarjetaProximo();

    return Scaffold(
      backgroundColor: AppColors.colorBase4,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(),
              const SizedBox(height: 16),

              // En pantallas anchas (Windows) van lado a lado, como en el boceto
              if (ancho >= 700)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: tip),
                    const SizedBox(width: 16),
                    Expanded(child: proximo),
                  ],
                )
              else ...[
                tip,
                const SizedBox(height: 16),
                proximo,
              ],

              if (_proximos.length > 1) ...[
                const SizedBox(height: 16),
                _tarjetaLista(),
              ],

              const SizedBox(height: 16),
              Row(
                children: [
                  _miniTarjeta(Icons.notifications_active,
                      '$_activosTotal', 'Hábitos activos'),
                  const SizedBox(width: 12),
                  _miniTarjeta(
                      Icons.check_circle, '$_completados', 'Completados'),
                ],
              ),

              const SizedBox(height: 16),
              _tarjetaGuia(),
            ],
          ),
        ),
      ),
    );
  }
}