import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_block.dart';
import '../providers/time_block_provider.dart';

class TimeBlockCard extends StatelessWidget {
  final TimeBlock timeBlock;

  const TimeBlockCard({super.key, required this.timeBlock});

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeBlockProvider>(
      builder: (context, provider, child) {
        final person = provider.persons.firstWhere(
          (p) => p.id == timeBlock.personId,
          orElse: () => Person(id: 1, name: 'الأب', color: 'FF4285F4'),
        );

        return Card(
          margin: EdgeInsets.all(8.0),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Person badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: _parseColor(person.color ?? 'FF4285F4'),
                      child: Text(
                        person.name[0],
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      person.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    // Delete button
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, timeBlock);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Main content row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Checkbox
                    Checkbox(
                      value: timeBlock.isCompleted,
                      onChanged: (value) {
                        Provider.of<TimeBlockProvider>(context, listen: false)
                            .toggleTimeBlockCompletion(timeBlock.id!, value!);
                      },
                    ),
                    
                    // Title and description
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
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                decoration: timeBlock.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Time and category row
                Row(
                  children: [
                    // Time
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${_formatTime(timeBlock.startTime)} - ${_formatTime(timeBlock.endTime)}',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Spacer(),
                    // Category
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          timeBlock.category,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Action Items Section
                if (timeBlock.actionItems.isNotEmpty) ...[
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'بنود العمل:',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
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
                              style: TextStyle(
                                fontSize: 14,
                                decoration: actionItem.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
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
                            dense: true,
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
      },
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

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
