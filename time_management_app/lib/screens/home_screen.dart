import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_management_app/models/time_block.dart';
import '../providers/time_block_provider.dart';
import 'add_time_block_screen.dart';
import '../widgets/time_block_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _days = [
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
    _tabController = TabController(length: _days.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TimeBlockProvider>(context, listen: false);
      provider.loadPersons().then((_) {
        provider.setCurrentDay(_days[_tabController.index]);
      });
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final newDay = _days[_tabController.index];
      Provider.of<TimeBlockProvider>(context, listen: false)
          .setCurrentDay(newDay);
    }
  }

  void _showPersonSelectionDialog(BuildContext context) {
    final provider = Provider.of<TimeBlockProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر الشخص'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: provider.persons.length,
              itemBuilder: (context, index) {
                final person = provider.persons[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _parseColor(person.color ?? 'FF4285F4'),
                    child: Text(
                      person.name[0],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(person.name),
                  trailing: provider.currentPersonId == person.id
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    provider.setCurrentPerson(person.id!);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  void _showClearDatabaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('مسح جميع البيانات'),
          content: Text('هل أنت متأكد من أنك تريد مسح جميع البيانات؟ لا يمكن التراجع عن هذا الإجراء.'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('مسح الكل', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Provider.of<TimeBlockProvider>(context, listen: false)
                    .clearAllData()
                    .then((_) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم مسح جميع البيانات بنجاح'),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeBlockProvider>(
      builder: (context, provider, child) {
        final currentPerson = provider.persons.firstWhere(
          (person) => person.id == provider.currentPersonId,
          orElse: () => Person(id: 1, name: 'الأب', color: 'FF4285F4'),
        );

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('إدارة الوقت العائلي'),
                Text(
                  currentPerson.name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.people),
                onPressed: () => _showPersonSelectionDialog(context),
                tooltip: 'تغيير الشخص',
              ),
              IconButton(
                icon: Icon(Icons.delete_sweep),
                onPressed: () => _showClearDatabaseDialog(context),
                tooltip: 'مسح جميع البيانات',
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _showAddTimeBlockDialog(context, currentPerson);
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: _days.map((day) => Tab(text: day)).toList(),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: _days.map((day) {
              return _buildDayTab(day, currentPerson);
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showAddTimeBlockDialog(context, currentPerson);
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildDayTab(String day, Person currentPerson) {
    return Consumer<TimeBlockProvider>(
      builder: (context, provider, child) {
        final dayTimeBlocks = provider.timeBlocks
            .where((block) => block.dayOfWeek == day && block.personId == currentPerson.id)
            .toList();

        if (dayTimeBlocks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد فترات زمنية لـ $day',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'لـ ${currentPerson.name}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'انقر على + لإضافة فترة زمنية',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: dayTimeBlocks.length,
          itemBuilder: (context, index) {
            final timeBlock = dayTimeBlocks[index];
            return Dismissible(
              key: Key(timeBlock.id.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmationDialog(context, timeBlock);
              },
              onDismissed: (direction) {
                Provider.of<TimeBlockProvider>(context, listen: false)
                    .deleteTimeBlock(timeBlock.id!);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف "${timeBlock.title}"'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: TimeBlockCard(timeBlock: timeBlock),
            );
          },
        );
      },
    );
  }

  void _showAddTimeBlockDialog(BuildContext context, Person currentPerson) {
    final currentDay = _days[_tabController.index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTimeBlockScreen(
          selectedDay: currentDay,
          selectedPerson: currentPerson,
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context, TimeBlock timeBlock) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف الفترة الزمنية'),
          content: Text('هل أنت متأكد من أنك تريد حذف "${timeBlock.title}"؟'),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('حذف', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}