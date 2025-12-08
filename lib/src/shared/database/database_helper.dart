import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_provedores_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE providers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE clients (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      provider_id INTEGER NOT NULL,
      cpf TEXT NOT NULL,
      name TEXT NOT NULL,
      latitude REAL, 
      longitude REAL,
      plan_type TEXT NOT NULL,
      phone TEXT,
      street TEXT,
      number TEXT,
      neighborhood TEXT,
      city TEXT,
      state TEXT,
      zip_code TEXT,
      FOREIGN KEY (provider_id) REFERENCES providers (id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL
    )
    ''');

    await db.insert('plans', {'name': '50 Mega'});
    await db.insert('plans', {'name': '100 Mega'});
    await db.insert('plans', {'name': '300 Mega'});
    await db.insert('plans', {'name': '500 Mega'});
    await db.insert('plans', {'name': '1 Giga'});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona novos campos de endereço
      await db.execute('ALTER TABLE clients ADD COLUMN street TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN number TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN neighborhood TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN city TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN state TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN zip_code TEXT');
    }
  }

  String _generateHash(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> createProvider(String username, String password) async {
    final db = await instance.database;
    final passwordHash = _generateHash(password);
    try {
      final id = await db.insert('providers', {
        'username': username,
        'password': passwordHash, 
      });
      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getProvider(String username, String password) async {
    final db = await instance.database;
    final passwordHash = _generateHash(password);
    final maps = await db.query(
      'providers',
      columns: ['id', 'username'],
      where: 'username = ? AND password = ?',
      whereArgs: [username, passwordHash],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<List<String>> getPlans() async {
    final db = await instance.database;
    final result = await db.query('plans', orderBy: 'id ASC');
    return result.map((e) => e['name'] as String).toList();
  }

  Future<int> createClient({
    required int providerId,
    required String name,
    required String cpf,
    required String phone,
    required String planType,
    double? latitude,
    double? longitude,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    final db = await instance.database;
    return await db.insert('clients', {
      'provider_id': providerId,
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'plan_type': planType,
      'latitude': latitude,
      'longitude': longitude,
      'street': street,
      'number': number,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'zip_code': zipCode,
    });
  }

  Future<List<Map<String, dynamic>>> getClientsByProvider(int providerId) async {
    final db = await instance.database;
    return await db.query(
      'clients',
      where: 'provider_id = ?',
      whereArgs: [providerId],
      orderBy: 'name ASC',
    );
  }

  Future<int> updateClient({
    required int id,
    required String name,
    required String cpf,
    required String phone,
    required String planType,
    double? latitude,
    double? longitude,
    String? street,
    String? number,
    String? neighborhood,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    final db = await instance.database;
    return await db.update(
      'clients',
      {
        'name': name,
        'cpf': cpf,
        'phone': phone,
        'plan_type': planType,
        'latitude': latitude,
        'longitude': longitude,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'zip_code': zipCode,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await instance.database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>> getProviderStats(int providerId) async {
    final db = await instance.database;
    final totalClients = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM clients WHERE provider_id = ?',
      [providerId],
    )) ?? 0;

    final plansResult = await db.rawQuery('''
      SELECT plan_type, COUNT(*) as count
      FROM clients
      WHERE provider_id = ?
      GROUP BY plan_type
    ''', [providerId]);

    return {
      'total': totalClients,
      'by_plan': plansResult,
    };
  }
}