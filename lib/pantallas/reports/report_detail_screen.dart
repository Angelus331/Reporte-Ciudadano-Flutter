import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart'; // Importamos shimmer para el bloque fantasma de la imagen

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';
import 'edit_report_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  void _compartirReporte() async {
    final String mensaje = '''
    *Nuevo Reporte Ciudadano*
    *Título:* ${report.title}
    *Descripción:* ${report.description}

    _Enviado desde la App de Reportes Ciudadanos_ 📱
    ''';

    await Share.share(
      mensaje,
      subject: 'Reporte: ${report.title}',
    );
  }

  Future<void> deleteReport(BuildContext context) async {
    bool success = await ReportService().deleteReport(report.id);

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al eliminar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Compartir',
            onPressed: _compartirReporte,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditReportScreen(report: report),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              bool? confirm = await showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Eliminar reporte'),
                    content: const Text('¿Seguro que deseas eliminarlo?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                deleteReport(context);
              }
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN MEJORADA: Imagen con Shimmer Loading incorporado
            if (report.imageUrl != null)
              Image.network(
                report.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                // Maneja el progreso de la descarga de la imagen mostrando un Shimmer premium ⚡
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child; // Si ya descargó, muestra la imagen real
                  
                  return Shimmer.fromColors(
                    baseColor: isDarkMode ? const Color(0xFF1E293B) : Colors.grey[300]!,
                    highlightColor: isDarkMode ? const Color(0xFF334155) : Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.withOpacity(0.1),
                    child: const Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
                  );
                },
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.description,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton.icon(
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
                      );
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Abrir en Google Maps'),
                  ),
                  const SizedBox(height: 20),

                  // GOOGLE MAP
                  if (report.latitude != null && report.longitude != null)
                    SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(report.latitude!, report.longitude!),
                            zoom: 16,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('report'),
                              position: LatLng(report.latitude!, report.longitude!),
                            ),
                          },
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _compartirReporte, // Apunta de forma segura a tu función de compartir
        label: const Text('Compartir'),
        icon: const Icon(Icons.phone_callback),
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
    );
  }
}