import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/report_provider.dart';
import 'pantallas/splash_screen.dart';
import 'servicios/notification_service.dart'; 

void main() async {
  // Asegura que los canales de comunicación nativos con Android/iOS estén listos
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("No se pudieron inicializar las notificaciones locales: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ReportProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reporte Ciudadano',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0066FF),
          secondary: Color(0xFF10B981),
          surface: Colors.white,
          error: Color(0xFFEF4444),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withAlpha(38),
              width: 1,
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3B82F6),
          secondary: Color(0xFF34D399),
          surface: Color(0xFF1E293B),
          error: Color(0xFFF87171),
        ),

        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.white.withAlpha(13),
              width: 1,
            ),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF1E293B),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      themeMode: ThemeMode.system,

      home: const SplashScreen(),
    );
  }
}