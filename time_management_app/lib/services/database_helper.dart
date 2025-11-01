import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/time_block.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'time_management.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_blocks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE action_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        timeBlockId INTEGER NOT NULL,
        FOREIGN KEY(timeBlockId) REFERENCES time_blocks(id) ON DELETE CASCADE
      )
    ''');
  }

  // TimeBlock operations
  Future<int> insertTimeBlock(TimeBlock timeBlock) async {
    final db = await database;
    return await db.insert('time_blocks', _timeBlockToMap(timeBlock));
  }

  Future<List<TimeBlock>> getTimeBlocks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('time_blocks');
    
    List<TimeBlock> timeBlocks = [];
    for (var map in maps) {
      final actionItems = await getActionItemsForTimeBlock(map['id']);
      timeBlocks.add(_timeBlockFromMap(map, actionItems));
    }
    
    return timeBlocks;
  }

  Future<TimeBlock?> getTimeBlock(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_blocks',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      final actionItems = await getActionItemsForTimeBlock(id);
      return _timeBlockFromMap(maps.first, actionItems);
    }
    return null;
  }

  Future<int> updateTimeBlock(TimeBlock timeBlock) async {
    final db = await database;
    return await db.update(
      'time_blocks',
      _timeBlockToMap(timeBlock),
      where: 'id = ?',
      whereArgs: [timeBlock.id],
    );
  }

  Future<int> deleteTimeBlock(int id) async {
    final db = await database;
    // First delete associated action items
    await db.delete(
      'action_items',
      where: 'timeBlockId = ?',
      whereArgs: [id],
    );
    // Then delete the time block
    return await db.delete(
      'time_blocks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ActionItem operations
  Future<int> insertActionItem(ActionItem actionItem) async {
    final db = await database;
    return await db.insert('action_items', _actionItemToMap(actionItem));
  }

  Future<List<ActionItem>> getActionItemsForTimeBlock(int timeBlockId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'action_items',
      where: 'timeBlockId = ?',
      whereArgs: [timeBlockId],
    );
    return maps.map((map) => _actionItemFromMap(map)).toList();
  }

  Future<void> updateActionItemCompletion(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'action_items',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateTimeBlockCompletion(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'time_blocks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteActionItem(int id) async {
    final db = await database;
    return await db.delete(
      'action_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Helper methods for conversion
  Map<String, dynamic> _timeBlockToMap(TimeBlock timeBlock) {
    return {
      'id': timeBlock.id,
      'title': timeBlock.title,
      'description': timeBlock.description,
      'startTime': timeBlock.startTime.millisecondsSinceEpoch,
      'endTime': timeBlock.endTime.millisecondsSinceEpoch,
      'category': timeBlock.category,
      'isCompleted': timeBlock.isCompleted ? 1 : 0,
    };
  }

  TimeBlock _timeBlockFromMap(Map<String, dynamic> map, List<ActionItem> actionItems) {
    return TimeBlock(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      actionItems: actionItems,
      category: map['category'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Map<String, dynamic> _actionItemToMap(ActionItem actionItem) {
    return {
      'id': actionItem.id,
      'title': actionItem.title,
      'isCompleted': actionItem.isCompleted ? 1 : 0,
      'timeBlockId': actionItem.timeBlockId,
    };
  }

  ActionItem _actionItemFromMap(Map<String, dynamic> map) {
    return ActionItem(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      timeBlockId: map['timeBlockId'],
    );
  }
}
