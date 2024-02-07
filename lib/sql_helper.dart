import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTable(sql.Database database) async {
    await database.execute("""
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        imageUrl TEXT,
        cost TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
      """);

      await database.execute("""
      CREATE TABLE carts(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        imageUrl TEXT,
        cost TEXT,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      );
      """);
  }

  

  static Future<sql.Database> db() async {
    return sql.openDatabase('mydb.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTable(database);
    });
  }

  static Future<int> createItem(String imgUrl, String? cost) async {
    final db = await SQLHelper.db();
    final data = {'imageUrl': imgUrl, 'cost': cost};
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<int> createItemCart(String imgUrl, String? cost) async {
    final db = await SQLHelper.db();
    final data = {'imageUrl': imgUrl, 'cost': cost};
    final id = await db.insert('carts', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItemsFromCart() async {
    final db = await SQLHelper.db();
    return db.query('carts', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: "id");
  }

  

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('query', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, String imgUrl, String? cost) async {
    final db = await SQLHelper.db();
    final data = {
      'imgUrl': imgUrl,
      'cost': cost,
      'created_at': DateTime.now().toString()
    };
    final result =
        await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItemFromCart(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('carts', where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("something went wrong $err");
    }
  }
}
