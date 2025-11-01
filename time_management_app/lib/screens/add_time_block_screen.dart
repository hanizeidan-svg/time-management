import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/time_block.dart';
import '../providers/time_block_provider.dart';

class AddTimeBlockScreen extends StatefulWidget {
  final String selectedDay;
  final Person selectedPerson;
  
  const AddTimeBlockScreen({
    super.key, 
    required this.selectedDay,
    required this.selectedPerson,
  });

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
  late String _selectedDay;

  final List<String> _daysOfWeek = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
  }

  Future<void> _selectStartTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_startTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // Auto-adjust end time if it's before start time
          if (_endTime.isBefore(_startTime)) {
            _endTime = _startTime.add(Duration(hours: 1));
          }
        });
      }
    }
  }

  Future<void> _selectEndTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialEntryMode: DatePickerEntryMode.calendar,
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_endTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _endTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _addActionItem() {
    final text = _actionItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _actionItems.add(ActionItem(
          title: text,
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
      if (_endTime.isBefore(_startTime)) {
        _showErrorDialog('خطأ في الوقت', 'وقت الانتهاء يجب أن يكون بعد وقت البدء');
        return;
      }

      final timeBlock = TimeBlock(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        actionItems: _actionItems,
        category: _categoryController.text.trim(),
        dayOfWeek: _selectedDay,
        personId: widget.selectedPerson.id!, // Use the selected person
      );

      Provider.of<TimeBlockProvider>(context, listen: false)
          .addTimeBlock(timeBlock)
          .then((_) {
        Navigator.pop(context);
        _showSuccessMessage();
      }).catchError((error) {
        _showErrorDialog('خطأ', 'فشل في حفظ الفترة الزمنية: $error');
      });
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة الفترة الزمنية بنجاح'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('حسناً'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _actionItemController.clear();
    setState(() {
      _actionItems.clear();
      _startTime = DateTime.now();
      _endTime = DateTime.now().add(Duration(hours: 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة فترة زمنية جديدة'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: _clearForm,
            tooltip: 'مسح النموذج',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTimeBlock,
            tooltip: 'حفظ الفترة الزمنية',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Day Selection
              DropdownButtonFormField<String>(
                initialValue: _selectedDay,
                decoration: InputDecoration(
                  labelText: 'اليوم',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: _daysOfWeek.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day, textDirection: TextDirection.rtl),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDay = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء اختيار اليوم';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(widget.selectedPerson.color ?? 'FF4285F4'),
                    child: Text(
                      widget.selectedPerson.name[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('الشخص: ${widget.selectedPerson.name}', 
                            textDirection: TextDirection.rtl),
                  trailing: Icon(Icons.person, color: Colors.blue),
                ),
              ),
              SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'العنوان *',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال العنوان';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),

              // Category Field
              TextFormField(
                controller: _categoryController,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.category),
                ),
              ),
              SizedBox(height: 16),

              // Time Selection Row
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.play_arrow, color: Colors.green),
                        title: Text('وقت البدء', textDirection: TextDirection.rtl),
                        subtitle: Text(
                          _formatDateTime(_startTime),
                          textDirection: TextDirection.rtl,
                        ),
                        onTap: _selectStartTime,
                        trailing: Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.stop, color: Colors.red),
                        title: Text('وقت الانتهاء', textDirection: TextDirection.rtl),
                        subtitle: Text(
                          _formatDateTime(_endTime),
                          textDirection: TextDirection.rtl,
                        ),
                        onTap: _selectEndTime,
                        trailing: Icon(Icons.edit, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Duration Info
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'المدة: ${_calculateDuration()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Action Items Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'بنود العمل',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Add Action Item Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _actionItemController,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                labelText: 'إضافة بند عمل جديد',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              ),
                              onSubmitted: (value) {
                                if (value.trim().isNotEmpty) {
                                  _addActionItem();
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          FloatingActionButton.small(
                            onPressed: _addActionItem,
                            tooltip: 'إضافة بند عمل',
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Action Items Counter
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

                      // Action Items List
                      if (_actionItems.isNotEmpty) ..._actionItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          elevation: 1,
                          color: Colors.grey[50],
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              child: Text('${index + 1}'),
                            ),
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                        );
                      }),

                      // Empty State for Action Items
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
              SizedBox(height: 20),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveTimeBlock,
                icon: Icon(Icons.save),
                label: Text('حفظ الفترة الزمنية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration() {
    final duration = _endTime.difference(_startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0 && minutes > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (hours > 0) {
      return '$hours ساعة';
    } else {
      return '$minutes دقيقة';
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
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
