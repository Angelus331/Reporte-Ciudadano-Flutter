import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../reports/report_list_screen.dart';
import '../reports/create_report_screen.dart';
import '../sensors/sensor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        elevation: 0,
        actions: [
          // Botón de Cerrar Sesión Estilizado
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO DE BIENVENIDA MODERNO
            Text(
              '¡Hola, Ciudadano Insanito Listo para hacer tus Reportes y ayudar a tu Comunidad!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona una opción para interactuar con tu comunidad.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 30),

            // CUADRÍCULA PREMIUM DE SECCIONES (Grid View)
            GridView.count(
              crossAxisCount: 2, // Dos columnas para las tarjetas
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll manejado por el body general
              children: [
                // TARJETA: VER REPORTES
                _buildMenuCard(
                  context,
                  title: 'Ver Reportes',
                  subtitle: 'Explora incidencias',
                  icon: Icons.analytics_outlined,
                  color: primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportListScreen()),
                  ),
                ),

                // TARJETA: CREAR REPORTE
                _buildMenuCard(
                  context,
                  title: 'Crear Reporte',
                  subtitle: 'Informa un problema',
                  icon: Icons.add_box_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateReportScreen(),
                    ),
                  ),
                ),

                // TARJETA: SENSORES
                _buildMenuCard(
                  context,
                  title: 'Sensores',
                  subtitle: 'Lecturas en vivo',
                  icon: Icons.sensors_rounded,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SensorScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Constructor modular para las Tarjetas del Menú
  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero, // Reiniciamos márgenes internos del Grid
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16), // Curva perfecta al hacer clic
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Contenedor circular con opacidad para el Icono
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),

              // Textos informativos de la sección
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
