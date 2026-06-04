import 'package:flutter/material.dart';
import 'widgets/sensor_cards_tab.dart';
import 'widgets/calculadora_tab.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Herramientas'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.sensors_rounded), text: 'Telemetría IoT'),
              Tab(icon: Icon(Icons.calculate_rounded), text: 'Calculadora Pro'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SensorCardsTab(), // Pestaña 1: Tu acelerómetro original + sensores nuevos
            CalculadoraTab(), // Pestaña 2: Tu panel matemático
          ],
        ),
      ),
    );
  }
}