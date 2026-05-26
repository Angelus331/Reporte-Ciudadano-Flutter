import 'package:flutter/material.dart';

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';

class EditReportScreen extends StatefulWidget {

  final ReportModel report;

  const EditReportScreen({
    super.key,
    required this.report,
  });

  @override
  State<EditReportScreen> createState() =>
      _EditReportScreenState();
}

class _EditReportScreenState
    extends State<EditReportScreen> {

  late TextEditingController titleController;

  late TextEditingController
      descriptionController;

  bool loading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.report.title,
    );

    descriptionController =
        TextEditingController(
      text: widget.report.description,
    );
  }

  Future<void> updateReport() async {

    setState(() {
      loading = true;
    });

    bool success =
        await ReportService().updateReport(

      id: widget.report.id,

      title: titleController.text,

      description:
          descriptionController.text,
    );

    setState(() {
      loading = false;
    });

    if (success) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte actualizado'),
        ),
      );

      Navigator.pop(context);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Editar Reporte'),
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller:
                  descriptionController,

              decoration: const InputDecoration(
                labelText: 'Descripción',
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(

              onPressed:
                  loading ? null : updateReport,

              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Actualizar'),
            )
          ],
        ),
      ),
    );
  }
}