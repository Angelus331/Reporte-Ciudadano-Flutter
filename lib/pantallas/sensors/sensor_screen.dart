import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final totalForce = (x.abs() + y.abs() + z.abs()) / 3;
    final iconColor = totalForce > 5
        ? Theme.of(context).colorScheme.error
        : primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoreo de Sensores'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TARJETA PRINCIPAL
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.vibration_rounded,
                        size: 56,
                        color: iconColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      totalForce > 5
                          ? '¡Dispositivo en movimiento!'
                          : 'Dispositivo Estable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: totalForce > 5
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Telemetría del acelerómetro en tiempo real.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Ejes de Medición (m/s²)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            // Eje X (Azul)
            _buildSensorGauge(
              context,
              axisName: 'Eje X',
              axisDescription: 'Inclinación Lateral (Izquierda / Derecha)',
              value: x,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),

            _buildSensorGauge(
              context,
              axisName: 'Eje Y',
              axisDescription: 'Inclinación Frontal (Adelante / Atrás)',
              value: y,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 16),

            // Eje Z (Púrpura)
            _buildSensorGauge(
              context,
              axisName: 'Eje Z',
              axisDescription: 'Fuerza Vertical (Gravedad / Elevación)',
              value: z,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorGauge(
    BuildContext context, {
    required String axisName,
    required String axisDescription,
    required double value,
    required Color color,
  }) {
    //  Se removió la variable local 'surfaceColor' que causaba el warning y usamos la propiedad del tema directamente
    double normalizedValue = ((value + 10) / 20).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.15,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    axisName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    axisDescription,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Text(
                value.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: normalizedValue,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
