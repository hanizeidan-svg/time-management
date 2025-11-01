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

class HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimeBlockProvider>(context, listen: false).loadTimeBlocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة الوقت الشخصي'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTimeBlockScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimeBlockProvider>(
        builder: (context, provider, child) {
          if (provider.timeBlocks.isEmpty) {
            return Center(
              child: Text(
                'لا توجد فترات زمنية مضافة بعد!\nانقر على + لإنشاء واحدة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.timeBlocks.length,
            itemBuilder: (context, index) {
              final timeBlock = provider.timeBlocks[index];
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTimeBlockScreen()),
          );
        },
        child: Icon(Icons.add),
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
}
