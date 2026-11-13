import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Patrón Singleton para una única instancia del helper
  // Sinceramente no se que es, pero se que es por una cuestion de rendimiento
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;


  // Esto del future es para que la base de datos se abra de manera asincrona, y no se bloquee la app mientras se abre
  // Y aja, si la base de datos ya esta abierta, simplemente la devuelve, si no, la abre y luego la devuelve
  // lo que devuelve es un Future, que es como una promesa de que en algun momento va a devolver la base de datos o un error si no se pudo abrir
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Aqui se inicializa la base de datos, creando las tablas si no existen
  // La ruta de la base de datos se obtiene con getDatabasesPath(), que devuelve la ruta por defecto para cada plataforma
  // Luego se abre la base de datos con openDatabase(), que recibe la ruta, la version y un callback para crear las tablas si no existen
  Future<Database> _initDatabase() async {
    // Obtiene la ruta por defecto según la plataforma (Android o escritorio)
    String path = join(await getDatabasesPath(), 'rin_habitos.db');
    print('--- RUTA DE LA BDD: $path ---');


    return await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: (db, oldVersion, newVersion) async {
  if (oldVersion < 2) {
    await db.execute(
      'ALTER TABLE habitos ADD COLUMN icono INTEGER NOT NULL DEFAULT 0',
    );
  }
},
    );
  }

  // Este método se llama cuando la base de datos se crea por primera vez
  // Aquí se crean las tablas que hablamos antes, con sus columnas y tipos de datos

  Future<void> _onCreate(Database db, int version) async {
    
    
    // TABLA DE HABITOS SEMANALES
    await db.execute('''
      CREATE TABLE IF NOT EXISTS h_Semanal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lunes INTEGER NOT NULL DEFAULT 0,
        martes INTEGER NOT NULL DEFAULT 0,
        miercoles INTEGER NOT NULL DEFAULT 0,
        jueves INTEGER NOT NULL DEFAULT 0,
        viernes INTEGER NOT NULL DEFAULT 0,
        sabado INTEGER NOT NULL DEFAULT 0,
        domingo INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // TABLA DE HABITOS 
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habitos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,           -- 'intervalo', 'unico', o 'semanal' 
        intervalo_minutos INTEGER,    -- Solo para tipo 'intervalo'
        fecha TEXT,                   -- Solo para tipo 'unico' (ej: '2026-10-14')
        hora TEXT,                    -- Solo la hora atómica (ej: '15:00:00')
        h_Semanal_id INTEGER,         -- Llave foránea opcional Solo para tipo 'semanal'
        activo INTEGER NOT NULL,      -- 1 o 0
        icono INTEGER NOT NULL,       -- Nuevo campo para almacenar el icono como un entero (codepoint)
        FOREIGN KEY (h_Semanal_id) REFERENCES h_Semanal(id) ON DELETE CASCADE
      )
    ''');
  }

//  Ahora para insertar los unicos

Future<int> insertarHabitoUnico({
    required String nombre,
    required String tipo,
    int? intervaloMinutos,
    String? fecha,
    String? hora,
    int? hSemanalId,
    required bool activo,
    required int icono, // Nuevo parámetro para el icono
  }) async {
    final db = await database;
    final habitData = {
      'nombre': nombre,
      'tipo': tipo,
      'intervalo_minutos': null, // No se usa para tipo 'unico'
      'fecha': fecha,
      'hora': hora,
      'h_Semanal_id': null, // No se usa para tipo 'unico'
      'activo': activo ? 1 : 0, // Convertir bool a entero
      // ahora guardare el icono con el codepoint ese de la verga, funcionara para todos los iconos de la libreria de material icons, y si quiero agregar un icono personalizado, tendre que guardarlo como imagen en la carpeta assets y luego cargarlo desde ahi, pero eso es otra historia
      'icono': icono, // Guardar el icono como un entero (codepoint)
    };
    return await db.insert('habitos', habitData);
  }


// INSERCION DE H_SEMANAL Y DE  HABITOS SEMANALES

Future<int> insertarHSemanal({
    required bool lunes,
    required bool martes,
    required bool miercoles,
    required bool jueves,
    required bool viernes,
    required bool sabado,
    required bool domingo,
  }) async {
    final db = await database;
    final hSemanalData = {
      'lunes': lunes ? 1 : 0,
      'martes': martes ? 1 : 0,
      'miercoles': miercoles ? 1 : 0,
      'jueves': jueves ? 1 : 0,
      'viernes': viernes ? 1 : 0,
      'sabado': sabado ? 1 : 0,
      'domingo': domingo ? 1 : 0,
    };
    return await db.insert('h_Semanal', hSemanalData);
  }
Future <int> insertarHabitoSemanal({
    required String nombre,
    required String tipo,
    int? intervaloMinutos,
    String? fecha,
    String? hora,
    required int hSemanalId,
    required bool activo,
    required int icono, // Nuevo parámetro para el icono
  }) async {
    final db = await database;
    final habitData = {
      'nombre': nombre,
      'tipo': tipo,
      'intervalo_minutos': null, // No se usa para tipo 'semanal'
      'fecha': null, // No se usa para tipo 'semanal'
      'hora': hora,
      'h_Semanal_id': hSemanalId, // Llave foránea para tipo 'semanal'
      'activo': activo ? 1 : 0, // Convertir bool a entero
      'icono': icono, // Guardar el icono como un entero (codepoint)
    };
    return await db.insert('habitos', habitData);
  }
  // FIN DE LA INSERCION DE LOS SEMANALES

  // INSERTAR HABITOS DE TIPO INTERVALO
  Future<int> insertarHabitoIntervalo({
    required String nombre,
    required String tipo,
    required int intervaloMinutos,
    String? fecha,
    String? hora,
    int? hSemanalId,
    required bool activo,
    required int icono, // Nuevo parámetro para el icono
  }) async {
    final db = await database;
    final habitData = {
      'nombre': nombre,
      'tipo': tipo,
      'intervalo_minutos': intervaloMinutos, // Solo para tipo 'intervalo'
      'fecha': null, // No se usa para tipo 'intervalo'
      'hora': hora,
      'h_Semanal_id': null, // No se usa para tipo 'intervalo'
      'activo': activo ? 1 : 0, // Convertir bool a entero
      'icono': icono, // Guardar el icono como un entero (codepoint)
    };
    return await db.insert('habitos', habitData);
  }

// AHORA PARA ACTUALIZAR LOS HABITOS (ACTIVARLOS/DESACTIVARLOS) CUANDO SE HAGA CLICK EN EL SWITCH DE LA VISTA 0, Y QUE SE ACTUALICE EN LA BDD
  Future<int> actualizarEstadoHabito(int id, bool activo) async {
    final db = await database;
    return await db.update(
      'habitos',
      {'activo': activo ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// LECTURA DE HABITOS PA LA VISTA 0
Future<List<Map<String, dynamic>>> obtenerHabitos() async {
  final db = await database;
  return await db.query(
    'habitos',
    orderBy: 'activo DESC, id ASC',
  );
}
// ELIMINACION DE HABITOS DE LA BDD
Future<int> eliminarHabito(int id) async {
  final db = await database;
  return await db.delete(
    'habitos',
    where: 'id = ?',
    whereArgs: [id],
  );
}


  


}