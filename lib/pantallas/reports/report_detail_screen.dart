import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart'; 

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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado con éxito')),
        );
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar el reporte')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // 🟢 TRUCO MAESTRO DE COMPATIBILIDAD CON LARAVEL:
    // Si tu modelo no mapeó bien 'image_url', intentamos extraer la ruta cruda del objeto de forma dinámica.
    String? urlImagenValida;
    try {
      urlImagenValida = report.imageUrl;
      if (urlImagenValida == null || urlImagenValida.isEmpty) {
        // Intento fallback por si se quedó guardado como llave cruda json
        final dynamic temporal = report;
        urlImagenValida = temporal.imageUrl ?? temporal.image_url;
      }
    } catch (_) {
      urlImagenValida = null;
    }

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
              bool? confirm = await showDialog<bool>(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Eliminar reporte'),
                    content: const Text('¿Seguro que deseas eliminarlo?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true && context.mounted) {
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
            // SECCIÓN DE IMAGEN CONTROLADA (Cero forzados fatales de tipo '!')
            if (urlImagenValida != null && urlImagenValida.isNotEmpty)
              Image.network(
                urlImagenValida,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  
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
                  // Si la IP de AWS cambia o el enlace se rompe, muestra esto en vez de cerrar la pantalla
                  return Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey.withValues(alpha: 0.1),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image_outlined, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No se pudo cargar la imagen del servidor', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                },
              )
            else
              // Marcador de posición elegante si el reporte no contiene imagen
              Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey.withValues(alpha: 0.1),
                child: const Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
              ),

            // DETALLES DEL REPORTE 
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
                  const SizedBox(height: 24),
                  
                  // 🟢 BOTÓN CORREGIDO CON EL SÍMBOLO '$' EN LA LATITUD
                  if (report.latitude != null && report.longitude != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      key: const ValueKey('btn_maps'),
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Abrir en Google Maps Externo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                  // VISTA INCRUSTADA DE GOOGLE MAPS
                  if (report.latitude != null && report.longitude != null)
                    SizedBox(
                      height: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(report.latitude!, report.longitude!),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('report_marker'),
                              position: LatLng(report.latitude!, report.longitude!),
                            ),
                          },
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 80), // Margen inferior de seguridad
                ],
              ),
            ), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _compartirReporte,
        label: const Text('Compartir Reporte'),
        icon: const Icon(Icons.share_rounded), 
        backgroundColor: const Color(0xFF25D366), 
        foregroundColor: Colors.white,
      ),
    );
  }
}