import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/report_provider.dart';
import 'pantallas/home/home_screen.dart'; // O tu pantalla inicial

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        // Aquí podrás meter más providers después (como el de Auth o Categorías)
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // Ajusta según tu flujo
    );
  }
}