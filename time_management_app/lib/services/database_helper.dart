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
      version: 1, // Start fresh with version 1
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Persons table
    await db.execute('''
      CREATE TABLE persons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT
      )
    ''');

    // Time blocks table
    await db.execute('''
      CREATE TABLE time_blocks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        startTime INTEGER NOT NULL,
        endTime INTEGER NOT NULL,
        category TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        dayOfWeek TEXT NOT NULL,
        personId INTEGER NOT NULL,
        FOREIGN KEY(personId) REFERENCES persons(id) ON DELETE CASCADE
      )
    ''');

    // Action items table
    await db.execute('''
      CREATE TABLE action_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        timeBlockId INTEGER NOT NULL,
        FOREIGN KEY(timeBlockId) REFERENCES time_blocks(id) ON DELETE CASCADE
      )
    ''');

    // Insert default persons
    await _insertDefaultPersons(db);
  }

  Future<void> _insertDefaultPersons(Database db) async {
    final defaultPersons = [
      {'name': 'هاني', 'color': 'FF4285F4'},
      {'name': 'آلاء', 'color': 'FFEA4335'},
      {'name': 'يحيى', 'color': 'FF34A853'},
      {'name': 'ابراهيم', 'color': 'FFFBBC05'},
      {'name': 'فاطمة', 'color': 'FF9C27B0'},
      {'name': 'أحمد', 'color': 'FFFF5722'},
    ];

    for (var person in defaultPersons) {
      await db.insert('persons', {
        'name': person['name'],
        'color': person['color'],
      });
    }
  }

  // Person operations
  Future<int> insertPerson(Person person) async {
    final db = await database;
    return await db.insert('persons', _personToMap(person));
  }

  Future<List<Person>> getPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('persons');
    return maps.map((map) => _personFromMap(map)).toList();
  }

  Future<int> updatePerson(Person person) async {
    final db = await database;
    return await db.update(
      'persons',
      _personToMap(person),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  Future<int> deletePerson(int id) async {
    final db = await database;
    return await db.delete(
      'persons',
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // Get time blocks by day and person
  Future<List<TimeBlock>> getTimeBlocksByDayAndPerson(String dayOfWeek, int personId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_blocks',
      where: 'dayOfWeek = ? AND personId = ?',
      whereArgs: [dayOfWeek, personId],
    );
    
    List<TimeBlock> timeBlocks = [];
    for (var map in maps) {
      final actionItems = await getActionItemsForTimeBlock(map['id']);
      timeBlocks.add(_timeBlockFromMap(map, actionItems));
    }
    
    return timeBlocks;
  }

  // Get all time blocks for a specific day across all persons
  Future<List<TimeBlock>> getTimeBlocksByDay(String dayOfWeek) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'time_blocks',
      where: 'dayOfWeek = ?',
      whereArgs: [dayOfWeek],
    );
    
    List<TimeBlock> timeBlocks = [];
    for (var map in maps) {
      final actionItems = await getActionItemsForTimeBlock(map['id']);
      timeBlocks.add(_timeBlockFromMap(map, actionItems));
    }
    
    return timeBlocks;
  }

  // Rest of the methods remain similar but with updated mappings...

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

  Future<int> deleteTimeBlock(int id) async {
    final db = await database;
    await db.delete(
      'action_items',
      where: 'timeBlockId = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'time_blocks',
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

  // Clear entire database
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('action_items');
    await db.delete('time_blocks');
    await db.delete('persons');
    // Reinsert default persons after clearing
    await _insertDefaultPersons(db);
  }

  // Helper methods for conversion
  Map<String, dynamic> _personToMap(Person person) {
    return {
      'id': person.id,
      'name': person.name,
      'color': person.color,
    };
  }

  Person _personFromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'],
      name: map['name'],
      color: map['color'],
    );
  }

  Map<String, dynamic> _timeBlockToMap(TimeBlock timeBlock) {
    return {
      'id': timeBlock.id,
      'title': timeBlock.title,
      'description': timeBlock.description,
      'startTime': timeBlock.startTime.millisecondsSinceEpoch,
      'endTime': timeBlock.endTime.millisecondsSinceEpoch,
      'category': timeBlock.category,
      'isCompleted': timeBlock.isCompleted ? 1 : 0,
      'dayOfWeek': timeBlock.dayOfWeek,
      'personId': timeBlock.personId,
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
      dayOfWeek: map['dayOfWeek'],
      personId: map['personId'],
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