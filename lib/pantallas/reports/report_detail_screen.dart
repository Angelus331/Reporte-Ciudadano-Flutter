import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';
import 'edit_report_screen.dart';

class ReportDetailScreen extends StatelessWidget {
  final ReportModel report;

  const ReportDetailScreen({super.key, required this.report});
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
    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),

        actions: [
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

          // ELIMINAR
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

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () async {
                      final Uri url = Uri.parse(
                        'https://www.google.com/maps/search/?api=1&query=${report.latitude},${report.longitude}',
                      );

                      await launchUrl(url);
                    },

                    child: const Text('Abrir ubicación'),
                  ),

                  const SizedBox(height: 20),

                  // GOOGLE MAP
                  SizedBox(
                    height: 300,

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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
