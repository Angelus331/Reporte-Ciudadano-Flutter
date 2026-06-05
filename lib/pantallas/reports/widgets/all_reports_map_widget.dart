import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../models/report_model.dart';
import '../report_detail_screen.dart';

class AllReportsMapWidget extends StatelessWidget {
  final List<ReportModel> reports;

  const AllReportsMapWidget({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    // Apuntamos por defecto a la Plaza de Armas de Puno como centro de operaciones
    const LatLng centroPuno = LatLng(-15.8402, -70.0281);

    final List<Marker> marcadores = reports
        .where(
          (r) => r.latitude != null && r.longitude != null,
        ) // Filtramos los que no tengan GPS
        .map((reporte) {
          final double lat =
              double.tryParse(reporte.latitude.toString()) ?? 0.0;
          final double lon =
              double.tryParse(reporte.longitude.toString()) ?? 0.0;

          return Marker(
            point: LatLng(lat, lon),
            width: 45,
            height: 45,
           child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportDetailScreen(report: reporte),
                  ),
                );
              },
              child: const Icon(
                Icons.location_on_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
          );
        })
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 280, // Un tamaño un poco más imponente para el Home
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FlutterMap(
          options: const MapOptions(
            center: centroPuno,
            zoom:
                14.0, // Un zoom un poco más abierto para ver toda la ciudad de Puno
          ),
          children: [
            // Servidor oficial de mosaicos libres de OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.reporte_ciudadano',
            ),

            // Inyectamos la lista dinámica de marcadores que procesamos arriba
            MarkerLayer(markers: marcadores),
          ],
        ),
      ),
    );
  }
}
