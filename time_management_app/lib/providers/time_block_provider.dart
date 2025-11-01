import 'package:flutter/foundation.dart';
import '../models/time_block.dart';
import '../services/database_helper.dart';

class TimeBlockProvider with ChangeNotifier {
  List<TimeBlock> _timeBlocks = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<TimeBlock> get timeBlocks => _timeBlocks;

  Future<void> loadTimeBlocks() async {
    _timeBlocks = await _databaseHelper.getTimeBlocks();
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
    
    await loadTimeBlocks(); // Reload to get the complete data with IDs
  }

  Future<void> toggleActionItem(int timeBlockId, int actionItemId, bool isCompleted) async {
    await _databaseHelper.updateActionItemCompletion(actionItemId, isCompleted);
    await loadTimeBlocks(); // Reload to get updated data
  }

  Future<void> toggleTimeBlockCompletion(int timeBlockId, bool isCompleted) async {
    await _databaseHelper.updateTimeBlockCompletion(timeBlockId, isCompleted);
    await loadTimeBlocks();
  }

  // Add this method to delete time blocks
  Future<void> deleteTimeBlock(int timeBlockId) async {
    await _databaseHelper.deleteTimeBlock(timeBlockId);
    await loadTimeBlocks(); // Reload to refresh the list
  }

  // Add this method to delete action items
  Future<void> deleteActionItem(int actionItemId) async {
    await _databaseHelper.deleteActionItem(actionItemId);
    await loadTimeBlocks(); // Reload to refresh the list
  }
}
