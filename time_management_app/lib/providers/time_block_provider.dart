import 'package:flutter/foundation.dart';
import '../models/time_block.dart';
import '../services/database_helper.dart';

class TimeBlockProvider with ChangeNotifier {
  List<TimeBlock> _timeBlocks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String _currentDay = 'الإثنين'; // Default day

  List<TimeBlock> get timeBlocks => _timeBlocks;
  String get currentDay => _currentDay;

  // Set current day and load relevant time blocks
  void setCurrentDay(String day) {
    _currentDay = day;
    loadTimeBlocksByDay(day);
  }

  Future<void> loadTimeBlocks() async {
    _timeBlocks = await _databaseHelper.getTimeBlocks();
    notifyListeners();
  }

  // Load time blocks for specific day
  Future<void> loadTimeBlocksByDay(String day) async {
    _timeBlocks = await _databaseHelper.getTimeBlocksByDay(day);
    notifyListeners();
  }

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
    
    await loadTimeBlocksByDay(timeBlock.dayOfWeek); // Reload current day
  }

  Future<void> toggleActionItem(int timeBlockId, int actionItemId, bool isCompleted) async {
    await _databaseHelper.updateActionItemCompletion(actionItemId, isCompleted);
    await loadTimeBlocksByDay(_currentDay); // Reload current day
  }

  Future<void> toggleTimeBlockCompletion(int timeBlockId, bool isCompleted) async {
    await _databaseHelper.updateTimeBlockCompletion(timeBlockId, isCompleted);
    await loadTimeBlocksByDay(_currentDay); // Reload current day
  }

  Future<void> deleteTimeBlock(int timeBlockId) async {
    await _databaseHelper.deleteTimeBlock(timeBlockId);
    await loadTimeBlocksByDay(_currentDay); // Reload current day
  }

  Future<void> deleteActionItem(int actionItemId) async {
    await _databaseHelper.deleteActionItem(actionItemId);
    await loadTimeBlocksByDay(_currentDay); // Reload current day
  }

  // Clear entire database
  Future<void> clearAllData() async {
    await _databaseHelper.clearDatabase();
    _timeBlocks = [];
    notifyListeners();
  }
}
