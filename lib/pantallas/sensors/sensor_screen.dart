import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() =>
      _SensorScreenState();
}

class _SensorScreenState
    extends State<SensorScreen> {

  double x = 0;
  double y = 0;
  double z = 0;

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {

      setState(() {

        x = event.x;
        y = event.y;
        z = event.z;

      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Sensores'),
      ),

      body: Center(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Text(
              'X: ${x.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Y: ${y.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Z: ${z.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}