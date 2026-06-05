import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../servicios/servicios_api.dart';
import '../../servicios/notification_service.dart';
import '../../servicios/category_services.dart';
import '../../utils/constants.dart';

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

  // CÁMARA
  Future<void> pickImageCamera() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality:
          50,
    );
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // GALERÍA
  Future<void> pickImageGallery() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // 👈 Comprime la imagen antes de meterla al FormData
    );
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  // GPS AUTOMÁTICO
  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, enciende el GPS de tu teléfono.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permisos denegados permanentemente. Actívalos en Ajustes.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obteniendo coords'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        latitudeController.text = position.latitude.toString();
        longitudeController.text = position.longitude.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ubicación obtenida con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tiempo de espera agotado o error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // CREAR REPORTE
  Future<void> createReport() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa el título y descripción'),
        ),
      );
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una categoría')),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final double? latVal = latitudeController.text.trim().isEmpty
        ? null
        : double.tryParse(latitudeController.text.trim());

    final double? lngVal = longitudeController.text.trim().isEmpty
        ? null
        : double.tryParse(longitudeController.text.trim());

    FormData formData = FormData.fromMap({
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'latitude': latVal,
      'longitude': lngVal,
      'category_id': selectedCategory,
      if (image != null)
        'image': await MultipartFile.fromFile(
          image!.path,
          filename: image!.path.split('/').last,
        ),
    });

    try {
      await ApiService().dio.post(
        '/reports',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status == 200 || status == 201,
        ),
      );

      await NotificationService.showNotification(
        title: 'Reporte creado',
        body: 'Tu reporte fue enviado correctamente, Todo un Crack',
      );

      if (mounted) {
        NotificationService.mostrarNotificacionInmediata(
          id: 1,
          titulo: '¡Reporte Creado con Éxito!',
          cuerpo: 'Tu incidencia ha sido guardada en los servidores de AWS en tiempo real.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado con éxito, Ayudaste a tu comunidad'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(
          context,
        ); // Regresa a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al crear reporte. Verifica tu conexión.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Reporte'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Categoría del incidente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Text(
                    'Cargando categorías...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat.id;
                    final style = Constants.getCategoryStyle(cat.name);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        avatar: Icon(
                          style['icon'],
                          size: 16,
                          color: isSelected ? style['color'] : Colors.grey,
                        ),
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: style['color'].withOpacity(0.2),
                        checkmarkColor: style['color'],
                        labelStyle: TextStyle(
                          color: isSelected ? style['color'] : null,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            selectedCategory = selected ? cat.id : null;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            // TÍTULO MODERNO
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                prefixIcon: const Icon(Icons.title_outlined),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            //DESCRIPCIÓN MODERNA
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 60.0),
                  child: Icon(Icons.description_outlined),
                ),
                filled: true,
                fillColor: surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // PREVIEW DE IMAGEN ESTILIZADA
            if (image != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(image!, height: 180, fit: BoxFit.cover),
                ),
              ),

            // BOTONES DE ADQUISICIÓN DE IMAGEN
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickImageCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Tomar Foto'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: pickImageGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galería'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // SECCIÓN COORDENADAS GPS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: latitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Latitud',
                      hintText: '-12.0463',
                      prefixIcon: const Icon(Icons.pin_drop_outlined),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: longitudeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Longitud',
                      hintText: '-77.0427',
                      prefixIcon: const Icon(Icons.explore_outlined),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // BOTÓN GPS AUTOMÁTICO ULTRA-MODERNO
            ElevatedButton.icon(
              onPressed: getLocation,
              icon: const Icon(Icons.location_searching_rounded),
              label: const Text('Obtener Ubicación GPS'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.1),
                foregroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // BOTÓN DEFINITIVO DE GUARDADO CON LOADING INTEGRADO
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : createReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Guardar Reporte',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
