import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
    static final DatabaseHelper instance = DatabaseHelper._init();
    static Database? _database;

    DatabaseHelper._init();

    Future<Database> get database async {
      if (_database != null) return _database!;
       _database = await _initDB('workoutDB.db');
        return _database!;
    }

    Future<Database> _initDB(String filePath) async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);
        return await openDatabase(path, version: 1, onCreate: _createDB);
    }

    Future _createDB(Database db, int version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS exercise_list (
            exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_name TEXT,
            primary_muscles TEXT,
            secondary_muscles TEXT,
            equipment TEXT,
            instructions TEXT,
            image_names TEXT
        );
        ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_builder (
            workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_name TEXT NOT NULL,
            exercise_id INTEGER NOT NULL,
            sets INTEGER NOT NULL,
            FOREIGN KEY (exercise_id) REFERENCES exercise_list (exercise_id) ON DELETE CASCADE
        );
        ''');

        await db.execute('''
        CREATE TABLE IF NOT EXISTS exercise_history (
            history_id INTEGER PRIMARY KEY AUTOINCREMENT,
            workout_id INTEGER,
            exercise_id INTEGER NOT NULL,
            exercise_date TEXT NOT NULL,
            set1 TEXT,
            set2 TEXT,
            set3 TEXT,
            set4 TEXT,
            set5 TEXT,
            set6 TEXT,
            set7 TEXT,
            set8 TEXT,
            set9 TEXT,
            set10 TEXT,
            notes TEXT,
            FOREIGN KEY (exercise_id) REFERENCES exercise_list (exercise_id) ON DELETE CASCADE,
            FOREIGN KEY (workout_id) REFERENCES workout_builder (workout_id) ON DELETE CASCADE
        );
        ''');
    }

    Future close() async {
        final db = await instance.database;
        db.close();
    }
}
