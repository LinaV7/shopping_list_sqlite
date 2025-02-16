import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/list_items.dart';
import '../models/shopping_list.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static const int _version = 2;
  Database? _db;

  // Приватный конструктор
  DbHelper._internal();

  // Фабричный конструктор для синглтона
  factory DbHelper() {
    return _instance;
  }

  // Инициализация базы данных
  Future<void> initializeDatabase() async {
    if (_db != null)
      return; // Убедимся, что база данных инициализируется только один раз

    final String path = join(await getDatabasesPath(), 'shopping.db');

    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> openDb() async {
    if (_db != null)
      return; // Убедимся, что база данных инициализируется только один раз

    final String path = join(await getDatabasesPath(), 'shopping.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE lists(id INTEGER PRIMARY KEY, name TEXT, priority INTEGER)',
        );
      },
    );
  }

  // Создание таблиц при первом запуске
  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE lists(id INTEGER PRIMARY KEY, name TEXT, priority INTEGER)',
    );
    await db.execute(
      'CREATE TABLE items(id INTEGER PRIMARY KEY, idList INTEGER, name TEXT, quantity TEXT, note TEXT, ' +
          'FOREIGN KEY(idList) REFERENCES lists(id))',
    );
  }

  // Обновление базы данных при изменении версии
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE lists ADD COLUMN priority INTEGER');
    }
  }

  // Вставка списка
  Future<int> insertList(ShoppingList list) async {
    return await _db!.insert(
      'lists',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Вставка элемента
  Future<int> insertItem(ListItem item) async {
    return await _db!.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Получение всех списков
  Future<List<ShoppingList>> getLists() async {
    final List<Map<String, dynamic>> maps = await _db!.query('lists');
    return List.generate(maps.length, (i) {
      return ShoppingList(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['priority'],
      );
    });
  }

  // Получение элементов по id списка
  Future<List<ListItem>> getItems(int idList) async {
    final List<Map<String, dynamic>> maps =
        await _db!.query('items', where: 'idList = ?', whereArgs: [idList]);
    return List.generate(maps.length, (i) {
      return ListItem(
        maps[i]['id'],
        maps[i]['idList'],
        maps[i]['name'],
        maps[i]['quantity'],
        maps[i]['note'],
      );
    });
  }

  // Удаление списка и связанных элементов
  Future<int> deleteList(ShoppingList list) async {
    await _db!.delete("items", where: "idList = ?", whereArgs: [list.id]);
    return await _db!.delete("lists", where: "id = ?", whereArgs: [list.id]);
  }

  // Удаление элементов
  Future<int> deleteItem(ListItem item) async {
    int result =
        await _db!.delete('items', where: "id = ?", whereArgs: [item.id]);
    return result;
  }

  // Удаление файла базы данных (для тестирования)
  Future<void> deleteDatabaseFile() async {
    final String path = join(await getDatabasesPath(), 'shopping.db');
    await deleteDatabase(path);
  }

  // Закрытие базы данных
  Future<void> close() async {
    await _db!.close();
  }
}
