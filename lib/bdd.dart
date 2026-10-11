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
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
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
        h_Semanal_id INTEGER,         -- Llave foránea opcional
        activo INTEGER NOT NULL,      -- 1 o 0
        FOREIGN KEY (h_Semanal_id) REFERENCES h_Semanal(id) ON DELETE CASCADE
      )
    ''');
  }






  


}