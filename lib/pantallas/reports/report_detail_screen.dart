import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';
import 'edit_report_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});

  // LÓGICA DE COMPARTIR A WHATSAPP
  void _compartirReporte() async {
    final String mensaje = '''
  *Nuevo Reporte Ciudadano* 
*Título:* ${report.title}
*Descripción:* ${report.description}

_Enviado desde la App de Reportes Ciudadanos_ 
''';

    await Share.share(mensaje, subject: 'Reporte: ${report.title}');
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
            // SECCIÓN DE IMAGEN
            if (report.imageUrl != null)
              Image.network(
                report.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
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
                  Text(report.description),
                  const SizedBox(height: 30),

                  // 🗺️ EL BOTÓN ÚNICO Y SEGURO: Abre la ubicación en el mapa externo del celular sin crasheos
                  if (report.latitude != null && report.longitude != null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Abrir ubicación en Google Maps'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          // Interpolación limpia corregida usando comillas y variables unidas
                          final Uri url = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
                          );
                          if (await canLaunchUrl(url)) {
                            await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No se pudo abrir la app de mapas')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  const SizedBox(height: 80), // Espacio de seguridad abajo para que el FAB no tape el texto
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
        backgroundColor: const Color(0xFF25D366), // Verde oficial de WhatsApp
        foregroundColor: Colors.white,
      ),
    );
  }
}