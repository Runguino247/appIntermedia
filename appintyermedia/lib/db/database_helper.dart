import 'package:sqflite/sqflite.dart'; // El motor
import 'package:path/path.dart';       // Utilidad de rutas
import '../models/comida.dart';          // Importamos tu modelo

class DatabaseHelper {
  // Patrón Singleton: Para usar siempre la misma instancia de la BD
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Obtener la base de datos (la abre si no existe)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('comidas.db'); // Nombre del archivo
    return _database!;
  }

  // Inicializar y crear la tabla
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Aquí ejecutamos el CREATE TABLE (Solo ocurre la primera vez)
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT'; // Imagen puede ser nula

    await db.execute('''
      CREATE TABLE meals ( 
        id $idType, 
        title $textType,
        description $textType,
        time $textType,
        imagePath $textNullable,
        dayOfWeek $textType
      )
    ''');
  }

  // --- MÉTODOS CRUD (Crear, Leer, Actualizar, Borrar) ---

  // 1. CREAR (Insertar una comida)
  Future<int> create(Comida meal) async {
    final db = await instance.database;
    // Es igual a: INSERT INTO meals (title, ...) VALUES (...)
    return await db.insert('meals', meal.toMap());
  }

  // 2. LEER (Obtener comidas filtradas por día)
  // Ejemplo: Dame todas las comidas del "Lunes"
  Future<List<Comida>> readMealsByDay(String day) async {
    final db = await instance.database;

    final result = await db.query(
      'meals',
      where: 'dayOfWeek = ?', // El ? evita inyección SQL
      whereArgs: [day],       // Aquí va "Lunes", "Martes", etc.
      orderBy: 'time ASC',    // Ordenar por hora (ej. desayuno antes que cena)
    );

    // Convertimos la lista de mapas (JSON) a lista de objetos Meal
    return result.map((json) => Comida.fromMap(json)).toList();
  }

  // 3. BORRAR
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}