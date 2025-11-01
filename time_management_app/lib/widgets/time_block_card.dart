import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_block.dart';
import '../providers/time_block_provider.dart';

class TimeBlockCard extends StatelessWidget {
  final TimeBlock timeBlock;

  const TimeBlockCard({super.key, required this.timeBlock});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, timeBlock);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeBlock.title,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: timeBlock.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (timeBlock.description.isNotEmpty)
                        Text(
                          timeBlock.description,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                // Checkbox moved here
                Checkbox(
                  value: timeBlock.isCompleted,
                  onChanged: (value) {
                    Provider.of<TimeBlockProvider>(context, listen: false)
                        .toggleTimeBlockCompletion(timeBlock.id!, value!);
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${_formatTime(timeBlock.startTime)} - ${_formatTime(timeBlock.endTime)}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(width: 4),
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                Spacer(),
                Text(
                  timeBlock.category,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                SizedBox(width: 4),
                Icon(Icons.category, size: 16, color: Colors.grey),
              ],
            ),
            SizedBox(height: 12),
            if (timeBlock.actionItems.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'بنود العمل:',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ...timeBlock.actionItems.map((actionItem) {
                return Row(
                  children: [
                    // Delete action item button
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline, 
                                color: Colors.red, size: 20),
                      onPressed: () {
                        _showDeleteActionItemDialog(context, actionItem);
                      },
                    ),
                    Expanded(
                      child: CheckboxListTile(
                        title: Text(
                          actionItem.title,
                          textDirection: TextDirection.rtl,
                          style: actionItem.isCompleted
                              ? TextStyle(decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        value: actionItem.isCompleted,
                        onChanged: timeBlock.isCompleted
                            ? null
                            : (value) {
                                Provider.of<TimeBlockProvider>(context, listen: false)
                                    .toggleActionItem(
                                  timeBlock.id!,
                                  actionItem.id!,
                                  value!,
                                );
                              },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, TimeBlock timeBlock) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف الفترة الزمنية'),
          content: Text('هل أنت متأكد من أنك تريد حذف "${timeBlock.title}"؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<TimeBlockProvider>(context, listen: false)
                    .deleteTimeBlock(timeBlock.id!)
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف الفترة الزمنية بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteActionItemDialog(BuildContext context, ActionItem actionItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف بند العمل'),
          content: Text('هل أنت متأكد من أنك تريد حذف "${actionItem.title}"؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<TimeBlockProvider>(context, listen: false)
                    .deleteActionItem(actionItem.id!)
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حذف بند العمل بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}