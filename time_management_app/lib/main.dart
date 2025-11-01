import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/time_block_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimeBlockProvider()),
      ],
      child: MaterialApp(
        title: 'إدارة الوقت',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Tajawal',
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
        // RTL configuration
        locale: Locale('ar', 'SA'),
        supportedLocales: [
          Locale('ar', 'SA'), // Arabic
          Locale('en', 'US'), // English as fallback
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate, // (for iOS)
        ],
      ),
    );
  }
}
