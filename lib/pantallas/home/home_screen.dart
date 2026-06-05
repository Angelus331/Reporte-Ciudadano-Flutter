import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../reports/report_list_screen.dart';
import '../reports/create_report_screen.dart';
import '../sensors/sensor_screen.dart';
import '../auth/change_pasword_screen.dart';
import '../reports/widgets/all_reports_map_widget.dart';
import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(
      'token',
    ); //Borramos el token para limpiar la sesión en AWS

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectamos dinámicamente si el sistema operativo está en Modo Oscuro o Claro
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Principal'),
        elevation: 0,
        actions: [
          // Botón de Cerrar Sesión Estilizado e Intuitivo
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENCABEZADO DE BIENVENIDA MODERNO PRO [cite: 335]
            Text(
              '¡Hola, Insanito de esta Linda Comunidad!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona una opción para interactuar con tu comunidad de forma insanita.',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 24),

            const Text(
              'Mapa General de Incidencias (Puno)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<ReportModel>>(
              future: ReportService().getReports(), // Trae los reportes reales de AWS
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return const AllReportsMapWidget(reports: []);
                }
                return AllReportsMapWidget(reports: snapshot.data!);
              },
            ),

            const SizedBox(height: 32),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true, //Evita desbordamientos de renderizado vertical
              physics:
                  const NeverScrollableScrollPhysics(), // Scroll controlado por el body
              children: [
                // TARJETA 1: VER REPORTES [cite: 333]
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

                // TARJETA 2: CREAR REPORTE [cite: 333]
                _buildMenuCard(
                  context,
                  title: 'Crear Reporte',
                  subtitle: 'Informa un problema',
                  icon: Icons.add_box_outlined,
                  color: secondaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateReportScreen(),
                    ),
                  ),
                ),

                // TARJETA 3: SENSORES TELEMETRÍA [cite: 333]
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

                _buildMenuCard(
                  context,
                  title: 'Seguridad',
                  subtitle: 'Cambiar contraseña',
                  icon: Icons.shield_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets
          .zero,
      elevation:
          0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          16,
        ), 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),

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