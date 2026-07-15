import 'dart:io';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class UsuarioDatabase {
  UsuarioDatabase._();

  static final UsuarioDatabase instance = UsuarioDatabase._();

  static const _databaseName = 'usuarios.db';
  static const _databaseVersion = 1;

  Database? _database;

  Future<void> init() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    } else {
      databaseFactory = databaseFactorySqflitePlugin;
    }
    await database;
    await seedDemoUsuarios();
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
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> seedDemoUsuarios() async {
    final usuarios = await listarUsuarios();
    if (usuarios.isNotEmpty) {
      return;
    }

    await guardarUsuario(nombre: 'admin', password: 'admin123');
    await guardarUsuario(nombre: 'usuario_demo', password: '123456');
  }

  Future<int> guardarUsuario({
    required String nombre,
    required String password,
  }) async {
    final nombreLimpio = nombre.trim();
    final passwordLimpia = password.trim();

    if (nombreLimpio.isEmpty) {
      throw ArgumentError('El usuario no puede estar vacío.');
    }

    if (passwordLimpia.isEmpty) {
      throw ArgumentError('La contraseña no puede estar vacía.');
    }

    final db = await database;
    final passwordHash = BCrypt.hashpw(passwordLimpia, BCrypt.gensalt());

    return db.insert(
      'usuarios',
      {
        'nombre': nombreLimpio,
        'passwordHash': passwordHash,
        'createdAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, Object?>>> listarUsuarios() async {
    final db = await database;
    return db.query(
      'usuarios',
      orderBy: 'id DESC',
    );
  }
}
