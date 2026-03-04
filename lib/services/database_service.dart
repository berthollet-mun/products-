import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class DatabaseService extends GetxService {
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  late Database _database;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<DatabaseService> init() async {
    _database = await _dbHelper.database;
    return this;
  }

  Database get database => _database;
  DatabaseHelper get dbHelper => _dbHelper;

  // Close database connection
  Future<void> closeDatabase() async {
    await _dbHelper.close();
  }
}
