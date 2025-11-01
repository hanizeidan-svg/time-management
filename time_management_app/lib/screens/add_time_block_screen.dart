import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_block.dart';
import '../providers/time_block_provider.dart';

class AddTimeBlockScreen extends StatefulWidget {
  const AddTimeBlockScreen({super.key});

  @override
  AddTimeBlockScreenState createState() => AddTimeBlockScreenState();
}

class AddTimeBlockScreenState extends State<AddTimeBlockScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _actionItemController = TextEditingController();

  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  final List<ActionItem> _actionItems = [];

  Future<void> _selectStartTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );
      if (time != null) {
        setState(() {
          _startTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
      );
      if (time != null) {
        setState(() {
          _endTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addActionItem() {
    if (_actionItemController.text.isNotEmpty) {
      setState(() {
        _actionItems.add(ActionItem(
          title: _actionItemController.text,
          timeBlockId: 0, // Will be set when saving
        ));
        _actionItemController.clear();
      });
    }
  }

  void _removeActionItem(int index) {
    setState(() {
      _actionItems.removeAt(index);
    });
  }

  void _saveTimeBlock() {
    if (_formKey.currentState!.validate()) {
      final timeBlock = TimeBlock(
        title: _titleController.text,
        description: _descriptionController.text,
        startTime: _startTime,
        endTime: _endTime,
        actionItems: _actionItems,
        category: _categoryController.text,
      );

      Provider.of<TimeBlockProvider>(context, listen: false)
          .addTimeBlock(timeBlock)
          .then((_) {
          Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة فترة زمنية جديدة'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTimeBlock,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'العنوان',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال العنوان';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: Text('وقت البدء', textDirection: TextDirection.rtl),
                      subtitle: Text(
                        _formatDateTime(_startTime),
                        textDirection: TextDirection.rtl,
                      ),
                      onTap: _selectStartTime,
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: Text('وقت الانتهاء', textDirection: TextDirection.rtl),
                      subtitle: Text(
                        _formatDateTime(_endTime),
                        textDirection: TextDirection.rtl,
                      ),
                      onTap: _selectEndTime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'بنود العمل:',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addActionItem,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _actionItemController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        labelText: 'إضافة بند عمل',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _addActionItem();
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // Updated Action Items List with Card UI
              if (_actionItems.isNotEmpty) ...[
                Text(
                  '${_actionItems.length} بند عمل مضافة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
              ],
              
              // Improved Action Items UI with Cards
              ..._actionItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 2,
                  child: ListTile(
                    leading: Icon(Icons.checklist, color: Colors.blue),
                    title: Text(
                      item.title,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeActionItem(index),
                      tooltip: 'حذف بند العمل',
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                );
              }).toList(),

              // Empty state for action items
              if (_actionItems.isEmpty) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.checklist, size: 48, color: Colors.grey[400]),
                      SizedBox(height: 8),
                      Text(
                        'لا توجد بنود عمل مضافة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'قم بإضافة بنود العمل الخاصة بك أعلاه',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _actionItemController.dispose();
    super.dispose();
  }
}
