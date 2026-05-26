import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../servicios/servicios_api.dart';
import '../../servicios/notification_service.dart';
import '../../servicios/category_services.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  File? image;

  bool loading = false;

  final ImagePicker picker = ImagePicker();

  List categories = [];
  int? selectedCategory;

  Future<void> loadCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    final data = await CategoryService().getCategories(token!);

    setState(() {
      categories = data;
    });
  }

  // CAMARA

  Future<void> pickImageCamera() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // GALERIA

  Future<void> pickImageGallery() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // GPS AUTOMATICO

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      latitudeController.text = position.latitude.toString();

      longitudeController.text = position.longitude.toString();
    });
  }

  // CREAR REPORTE

  Future<void> createReport() async {
    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');

    FormData formData = FormData.fromMap({
      'title': titleController.text,

      'description': descriptionController.text,

      'latitude': latitudeController.text,

      'longitude': longitudeController.text,

      'category_id': selectedCategory,

      if (image != null) 'image': await MultipartFile.fromFile(image!.path),
    });

    try {
      await ApiService().dio.post(
        '/reports',

        data: formData,

        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      await NotificationService.showNotification(
        title: 'Reporte creado',
        body: 'Tu reporte fue enviado correctamente',
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reporte creado')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al crear reporte')));
    }

    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Reporte')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // TITULO
            TextField(
              controller: titleController,

              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // DESCRIPCION
            TextField(
              controller: descriptionController,

              maxLines: 4,

              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // IMAGEN PREVIEW
            if (image != null)
              Image.file(image!, height: 200, fit: BoxFit.cover),

            const SizedBox(height: 20),

            // BOTONES IMAGEN
            ElevatedButton(
              onPressed: pickImageCamera,
              child: const Text('Tomar Foto'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: pickImageGallery,
              child: const Text('Elegir de Galería'),
            ),

            const SizedBox(height: 20),

            // LATITUD
            TextField(
              controller: latitudeController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Latitud',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // LONGITUD
            TextField(
              controller: longitudeController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: 'Longitud',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // GPS AUTOMATICO
            ElevatedButton(
              onPressed: getLocation,
              child: const Text('Obtener GPS'),
            ),

            const SizedBox(height: 30),

            DropdownButton<int>(
              value: selectedCategory,
              hint: const Text('Seleccionar categoría'),
              items: categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            // GUARDAR
            ElevatedButton(
              onPressed: loading ? null : createReport,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Guardar Reporte'),
            ),
          ],
        ),
      ),
    );
  }
}
