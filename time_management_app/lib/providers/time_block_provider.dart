import 'package:flutter/foundation.dart';
import '../models/time_block.dart';
import '../services/database_helper.dart';

class TimeBlockProvider with ChangeNotifier {
  List<TimeBlock> _timeBlocks = [];
  List<Person> _persons = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _currentDay = 'الإثنين';
  int _currentPersonId = 1; // Default to first person

  List<TimeBlock> get timeBlocks => _timeBlocks;
  List<Person> get persons => _persons;
  String get currentDay => _currentDay;
  int get currentPersonId => _currentPersonId;

  // Set current day and load relevant time blocks
  void setCurrentDay(String day) {
    _currentDay = day;
    loadTimeBlocksByDayAndPerson(day, _currentPersonId);
  }

  // Set current person and load their time blocks
  void setCurrentPerson(int personId) {
    _currentPersonId = personId;
    loadTimeBlocksByDayAndPerson(_currentDay, personId);
  }

  // Load all persons
  Future<void> loadPersons() async {
    _persons = await _databaseHelper.getPersons();
    notifyListeners();
  }

  Future<void> loadTimeBlocks() async {
    _timeBlocks = await _databaseHelper.getTimeBlocks();
    notifyListeners();
  }

  // Load time blocks for specific day and person
  Future<void> loadTimeBlocksByDayAndPerson(String day, int personId) async {
    _timeBlocks = await _databaseHelper.getTimeBlocksByDayAndPerson(day, personId);
    notifyListeners();
  }

  // Person management
  Future<void> addPerson(Person person) async {
    await _databaseHelper.insertPerson(person);
    await loadPersons();
  }

  Future<void> updatePerson(Person person) async {
    await _databaseHelper.updatePerson(person);
    await loadPersons();
  }

  Future<void> deletePerson(int personId) async {
    await _databaseHelper.deletePerson(personId);
    await loadPersons();
    // If current person was deleted, switch to first person
    if (_currentPersonId == personId && _persons.isNotEmpty) {
      setCurrentPerson(_persons.first.id!);
    }
  }

  // Time block operations
  Future<void> addTimeBlock(TimeBlock timeBlock) async {
    final timeBlockId = await _databaseHelper.insertTimeBlock(timeBlock);
    
    // Add action items
    for (var actionItem in timeBlock.actionItems) {
      await _databaseHelper.insertActionItem(
        ActionItem(
          title: actionItem.title,
          timeBlockId: timeBlockId,
          isCompleted: actionItem.isCompleted,
        ),
      );
    }
    
    await loadTimeBlocksByDayAndPerson(timeBlock.dayOfWeek, timeBlock.personId);
  }

  Future<void> toggleActionItem(int timeBlockId, int actionItemId, bool isCompleted) async {
    await _databaseHelper.updateActionItemCompletion(actionItemId, isCompleted);
    await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
  }

  Future<void> toggleTimeBlockCompletion(int timeBlockId, bool isCompleted) async {
    await _databaseHelper.updateTimeBlockCompletion(timeBlockId, isCompleted);
    await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
  }

  Future<void> deleteTimeBlock(int timeBlockId) async {
    await _databaseHelper.deleteTimeBlock(timeBlockId);
    await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
  }

  Future<void> deleteActionItem(int actionItemId) async {
    await _databaseHelper.deleteActionItem(actionItemId);
    await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
  }

  // Clear entire database
  Future<void> clearAllData() async {
    await _databaseHelper.clearDatabase();
    _timeBlocks = [];
    await loadPersons();
    notifyListeners();
  }
}