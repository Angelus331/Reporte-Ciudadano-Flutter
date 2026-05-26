import 'package:flutter/material.dart';

import '../../models/report_model.dart';
import '../../servicios/report_servicio.dart';
import 'report_detail_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<List<ReportModel>> reports;

  @override
  void initState() {
    super.initState();

    reports = ReportService().getReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),

      body: FutureBuilder<List<ReportModel>>(
        future: reports,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          }

          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,

            itemBuilder: (context, index) {
              final report = data[index];

              return Card(
                child: ListTile(
                  leading: report.imageUrl != null
                      ? Image.network(
                          report.imageUrl!,
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : null,

                  title: Text(report.title),

                  subtitle: Text(report.description),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(report: report),
                      ),
                    );
                  },
                  
                ),
              );
            },
          );
        },
      ),
    );
  }
}
