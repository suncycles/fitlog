import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
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
    
    print('Database path: $path');
     
    // Force delete existing database: use if urs is bugging
    // if (await databaseExists(path)) {
    //     print('Deleting existing database...');
    //     await deleteDatabase(path);
    // }
    
    final exists = await databaseExists(path);
    print('Database exists: $exists');
    
    if (!exists) {
        print('Copying database from assets...');
        try {
            await Directory(dirname(path)).create(recursive: true);
        } catch (e) {
            print('Error creating directory: $e');
        }
        
        try {
            // Copy from assets
            final data = await rootBundle.load('assets/$filePath');
            final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
            await File(path).writeAsBytes(bytes, flush: true);
            print('Database copied successfully, size: ${bytes.length} bytes');
        } catch (e) {
            print('Error copying database: $e');
        }
    }
    
    final db = await openDatabase(path, version: 1);
    
    // Verify the database has data
    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM exercise_list'));
    print('Exercise count in database: $count');
    
    return db;
}
    // creates table from scratch (empty, left here for reference idk)
    // Future _createDB(Database db, int version) async {
       
    //     await db.execute('''
    //     CREATE TABLE IF NOT EXISTS exercise_list (
    //         exercise_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         exercise_name TEXT,
    //         primary_muscles TEXT,
    //         secondary_muscles TEXT,
    //         equipment TEXT,
    //         instructions TEXT,
    //         image_names TEXT
    //     );
    //     ''');

    //     await db.execute('''
    //     CREATE TABLE IF NOT EXISTS workout_builder (
    //         workout_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         workout_name TEXT NOT NULL,
    //         exercise_id INTEGER NOT NULL,
    //         sets INTEGER NOT NULL,
    //         FOREIGN KEY (exercise_id) REFERENCES exercise_list (exercise_id) ON DELETE CASCADE
    //     );
    //     ''');

    //     await db.execute('''
    //     CREATE TABLE IF NOT EXISTS exercise_history (
    //         history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    //         workout_id INTEGER,
    //         exercise_id INTEGER NOT NULL,
    //         exercise_date TEXT NOT NULL,
    //         set1 TEXT,
    //         set2 TEXT,
    //         set3 TEXT,
    //         set4 TEXT,
    //         set5 TEXT,
    //         set6 TEXT,
    //         set7 TEXT,
    //         set8 TEXT,
    //         set9 TEXT,
    //         set10 TEXT,
    //         notes TEXT,
    //         FOREIGN KEY (exercise_id) REFERENCES exercise_list (exercise_id) ON DELETE CASCADE,
    //         FOREIGN KEY (workout_id) REFERENCES workout_builder (workout_id) ON DELETE CASCADE
    //     );
    //     ''');
    // }


    Future close() async {
        final db = _database;
        if (db != null) {
            await db.close();
            _database = null;
        }
    }
}