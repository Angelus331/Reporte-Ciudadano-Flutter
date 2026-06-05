import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportMapWidget extends StatelessWidget {
  final double latitud;
  final double longitud;

  const ReportMapWidget({
    super.key,
    required this.latitud,
    required this.longitud,
  });

  @override
  Widget build(BuildContext context) {
    // Si la latitud y longitud vienen en cero o nulas de AWS, apuntamos a la Plaza de Armas de Puno
    final LatLng ubicacionReporte = (latitud == 0 && longitud == 0)
        ? const LatLng(-15.8402, -70.0281) 
        : LatLng(latitud, longitud);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withAlpha(50), width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: ubicacionReporte, // Centro inicial del mapa
            initialZoom: 15.5,               // Zoom ideal para visualizar la calle
          ),
          children: [
            // Servidor de mosaicos oficiales y gratuitos de OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.reporte_ciudadano',
            ),
            
            // Marcador físico del reporte (El Pin rojo)
            MarkerLayer(
              markers: [
                Marker(
                  point: ubicacionReporte,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.redAccent,
                    size: 45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}