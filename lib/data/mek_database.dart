import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class Mek {
  const Mek({
    required this.id,
    required this.nombre,
    required this.apodo,
    this.fotoPath,
    this.apiId,
  });

  final int id;
  final String nombre;
  final String apodo;
  final String? fotoPath;
  final int? apiId;

  factory Mek.fromMap(Map<String, Object?> map) {
    return Mek(
      id: map['id'] as int,
      nombre: map['nombre'] as String,
      apodo: map['apodo'] as String,
      fotoPath: map['fotoPath'] as String?,
      apiId: map['apiId'] as int?,
    );
  }
}

class MekDatabase {
  MekDatabase._();

  static final MekDatabase instance = MekDatabase._();

  static const _databaseName = 'meks.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<void> init() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    await database;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final databasePath = await getDatabasesPath();
    final fullPath = p.join(databasePath, _databaseName);

    _database = await openDatabase(
      fullPath,
      version: _databaseVersion,
      onCreate: _createDatabase,
    );

    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        apodo TEXT NOT NULL,
        fotoPath TEXT,
        apiId INTEGER,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> agregarMek({
    required String nombre,
    required String apodo,
    String? fotoPath,
    int? apiId,
  }) async {
    final db = await database;
    return db.insert('meks', {
      'nombre': nombre.trim(),
      'apodo': apodo.trim(),
      'fotoPath': (fotoPath == null || fotoPath.trim().isEmpty)
          ? null
          : fotoPath.trim(),
      'apiId': apiId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> actualizarMek({
    required int id,
    required String nombre,
    required String apodo,
    String? fotoPath,
    int? apiId,
  }) async {
    final db = await database;
    await db.update(
      'meks',
      {
        'nombre': nombre.trim(),
        'apodo': apodo.trim(),
        'fotoPath': (fotoPath == null || fotoPath.trim().isEmpty)
            ? null
            : fotoPath.trim(),
        'apiId': apiId,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Mek>> listarMeks({
    required bool ordenarPorApodo,
  }) async {
    final db = await database;
    final campoOrden = ordenarPorApodo ? 'apodo' : 'nombre';
    final rows = await db.query(
      'meks',
      orderBy: '$campoOrden COLLATE NOCASE ASC',
    );

    return rows.map(Mek.fromMap).toList();
  }

  Future<int> contarMeks() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) AS total FROM meks');
    return result.first['total'] as int? ?? 0;
  }

  Future<void> eliminarMek(int id) async {
    final db = await database;
    await db.delete(
      'meks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
