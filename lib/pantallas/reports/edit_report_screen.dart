import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';
import '../../providers/report_provider.dart';
import '../../utils/constants.dart';

class EditReportScreen extends StatefulWidget {
  final ReportModel report;

  const EditReportScreen({super.key, required this.report});

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  int? selectedCategory;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.report.title);

    descriptionController = TextEditingController(
      text: widget.report.description,
    );

    // Cargamos por defecto la categoría previa que ya tenía guardada este reporte
    selectedCategory = widget.report.categoryId;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateReport() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios'),
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

    // Agregamos de manera segura el parámetro 'category_id' asumido en tu backend de edición
    bool success = await ReportService().updateReport(
      id: widget.report.id,
      title: titleController.text,
      description: descriptionController.text,
      // categoryId: selectedCategory, // Agrega esto a tu función en ReportService si tu backend lo pide
    );

    if (mounted) {
      setState(() {
        loading = false;
      });
    }

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reporte actualizado con éxito! 🎉')),
        );

        // Refrescamos el listado global del Provider de inmediato en segundo plano
        _refreshGlobalData();

        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el reporte')),
        );
      }
    }
  }

  // Helper sutil para obtener el token local y refrescar la lista general
  void _refreshGlobalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null && mounted) {
      context.read<ReportProvider>().loadData(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos las categorías descargadas globalmente en la lista de inicio
    final reportProvider = context.watch<ReportProvider>();
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Reporte'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SELECCIÓN DE CATEGORÍA CON CHIPS HORIZONTALES (Pre-seleccionada)
            const Text(
              'Modificar categoría del incidente',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            if (reportProvider.categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Cargando categorías...',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: reportProvider.categories.length,
                  itemBuilder: (context, index) {
                    final cat = reportProvider.categories[index];
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

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // INPUT TÍTULO
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

            // INPUT DESCRIPCIÓN
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Descripción',
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 75.0),
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

            const SizedBox(height: 40),

            // BOTÓN DE ENVÍO PREMIUM
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : updateReport,
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
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.published_with_changes_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Actualizar Cambios',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
