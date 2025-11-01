import 'package:flutter/foundation.dart';
import '../models/time_block.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart'; // Add this import

class TimeBlockProvider with ChangeNotifier {
  List<TimeBlock> _timeBlocks = [];
  List<Person> _persons = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final PreferencesService _preferencesService = PreferencesService(); // Add this
  
  String _currentDay = 'الإثنين';
  int _currentPersonId = 1;

  List<TimeBlock> get timeBlocks => _timeBlocks;
  List<Person> get persons => _persons;
  String get currentDay => _currentDay;
  int get currentPersonId => _currentPersonId;

  // Initialize with saved preferences
  Future<void> initialize() async {
    await loadPersons();
    await _loadSavedPreferences();
  }

  // Load saved preferences
  Future<void> _loadSavedPreferences() async {
    try {
      // Load saved day
      final savedDay = await _preferencesService.getLastDay();
      if (savedDay != null) {
        _currentDay = savedDay;
      }

      // Load saved person
      final savedPersonId = await _preferencesService.getLastPersonId();
      if (savedPersonId != null && _persons.any((p) => p.id == savedPersonId)) {
        _currentPersonId = savedPersonId;
      } else if (_persons.isNotEmpty) {
        // Fallback to first person if saved person doesn't exist
        _currentPersonId = _persons.first.id!;
      }

      // Load time blocks for the saved day and person
      await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
      
      notifyListeners();
    } catch (e) {
      print('Error loading preferences: $e');
      // Fallback to default values
      if (_persons.isNotEmpty) {
        _currentPersonId = _persons.first.id!;
        await loadTimeBlocksByDayAndPerson(_currentDay, _currentPersonId);
      }
    }
  }

  // Set current day and save to preferences
  void setCurrentDay(String day) {
    _currentDay = day;
    _preferencesService.saveLastDay(day);
    loadTimeBlocksByDayAndPerson(day, _currentPersonId);
  }

  // Set current person and save to preferences
  void setCurrentPerson(int personId) {
    final person = _persons.firstWhere((p) => p.id == personId);
    _currentPersonId = personId;
    _preferencesService.saveLastPerson(personId, person.name);
    loadTimeBlocksByDayAndPerson(_currentDay, personId);
  }

  // Load all persons
  Future<void> loadPersons() async {
    _persons = await _databaseHelper.getPersons();
    notifyListeners();
  }

  // Rest of your existing methods remain the same...
  Future<void> loadTimeBlocks() async {
    _timeBlocks = await _databaseHelper.getTimeBlocks();
    notifyListeners();
  }

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
    // If current person was deleted, switch to first person and save
    if (_currentPersonId == personId && _persons.isNotEmpty) {
      setCurrentPerson(_persons.first.id!);
    }
  }

  // Time block operations
  Future<void> addTimeBlock(TimeBlock timeBlock) async {
    final timeBlockId = await _databaseHelper.insertTimeBlock(timeBlock);
    
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
    // Reset to first person after clearing
    if (_persons.isNotEmpty) {
      setCurrentPerson(_persons.first.id!);
    }
    notifyListeners();
  }
}
