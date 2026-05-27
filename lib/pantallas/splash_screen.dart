import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importante para leer el token guardado

import 'auth/login_screen.dart';
import 'home/home_screen.dart'; // Importamos el Home para el redireccionamiento directo

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _iniciarFlujo();
  }

  // Función inteligente que verifica el estado de la sesión antes de navegar
  Future<void> _iniciarFlujo() async {
    // Damos una espera de 2.5 segundos para que se aprecie la animación estática de carga
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    // Abrimos la instancia de SharedPreferences y buscamos el token
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (!mounted) return;

    // Validamos el destino de navegación según la existencia del token
    if (token != null && token.trim().isNotEmpty) {
      // ¡Ya está logueado! Saltamos directo al Panel Principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // 🔒 No hay sesión activa, requiere loguearse
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Contenedor circular con el isotipo de la comunidad
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_city_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Título de la aplicación
            Text(
              'Reporte Ciudadano',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tu voz importa en tu comunidad',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 60),

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
