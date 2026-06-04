import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:light/light.dart';

class SensorCardsTab extends StatefulWidget {
  const SensorCardsTab({super.key});

  @override
  State<SensorCardsTab> createState() => _SensorCardsTabState();
}

class _SensorCardsTabState extends State<SensorCardsTab> {
  // Acelerómetro Original
  double x = 0, y = 0, z = 0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Giroscopio Nuevo
  double gyroX = 0, gyroY = 0, gyroZ = 0;
  StreamSubscription? _gyroSubscription;

  // Sensor de Luz Nuevo (Luxes)
  int _luxValue = 0;
  StreamSubscription? _lightSubscription;
  Light? _light;

  // Brújula Nueva (Dirección)
  double? _heading = 0;
  StreamSubscription? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
      });
    });

    _gyroSubscription = gyroscopeEventStream().listen((event) {
      if (!mounted) return;
      setState(() {
        gyroX = event.x;
        gyroY = event.y;
        gyroZ = event.z;
      });
    });

    try {
      _light = Light();
      _lightSubscription = _light?.lightSensorStream.listen((lux) {
        if (!mounted) return;
        setState(() { _luxValue = lux; });
      });
    } catch (_) {}

    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      setState(() { _heading = event.heading; });
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _gyroSubscription?.cancel();
    _lightSubscription?.cancel();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Lógica Original de Fuerza G y Detector de Movimiento
    final totalForce = (x.abs() + y.abs() + z.abs()) / 3;
    final iconColor = totalForce > 5
        ? Theme.of(context).colorScheme.error
        : primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🛑 TU TARJETA PRINCIPAL DEL ACELERÓMETRO ORIGINAL
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
                    totalForce > 5 ? '¡Dispositivo en movimiento!' : 'Dispositivo Estable',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: totalForce > 5 ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalForce > 5 ? "Detector: ¡Sacudida o Trote! 🏃‍♂️" : "Detector: Quieto 🛑",
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Módulos Adicionales IoT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // 1. NUEVO SENSOR DE LUZ
              _buildSensorMiniCard(
                title: "Sensor de Luz", icon: Icons.lightbulb_outline_rounded, color: Colors.amber, isDarkMode: isDarkMode,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$_luxValue LX', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber)),
                    const SizedBox(height: 4),
                    Text(_luxValue > 50 ? "Luz Brillante" : "Oscuridad", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),

              _buildSensorMiniCard(
                title: "Brújula", icon: Icons.explore_rounded, color: Colors.redAccent, isDarkMode: isDarkMode,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: ((_heading ?? 0) * (3.141592653589793 / 180) * -1),
                      child: const Icon(Icons.navigation_rounded, size: 36, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 4),
                    Text('${_heading?.toStringAsFixed(0) ?? '0'}° N', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            'Ejes de Medición del Acelerómetro (m/s²)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),

          _buildSensorGauge(context, axisName: 'Eje X', axisDescription: 'Inclinación Lateral (Izquierda / Derecha)', value: x, color: Colors.blue),
          const SizedBox(height: 16),
          _buildSensorGauge(context, axisName: 'Eje Y', axisDescription: 'Inclinación Frontal (Adelante / Atrás)', value: y, color: const Color(0xFF10B981)),
          const SizedBox(height: 16),
          _buildSensorGauge(context, axisName: 'Eje Z', axisDescription: 'Fuerza Vertical (Gravedad / Elevación)', value: z, color: Colors.purple),
          
          const SizedBox(height: 20),
          
          // BONUS: GIROSCOPIO COMPACTO ABAJO
          _buildSensorGauge(context, axisName: 'Giroscopio (Eje X)', axisDescription: 'Velocidad de Rotación Angular', value: gyroX, color: Colors.orange),
        ],
      ),
    );
  }

  // Widget de barra de progreso original tuyo
  Widget _buildSensorGauge(BuildContext context, {required String axisName, required String axisDescription, required double value, required Color color}) {
    double normalizedValue = ((value + 10) / 20).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.15),
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
                  Text(axisName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(axisDescription, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
              Text(value.toStringAsFixed(2), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
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

  Widget _buildSensorMiniCard({required String title, required IconData icon, required Color color, required bool isDarkMode, required Widget child}) {
    return Card(
      elevation: 0,
      color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: isDarkMode ? 0.05 : 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
            Expanded(child: Center(child: child)),
          ],
        ),
      ),
    );
  }
}