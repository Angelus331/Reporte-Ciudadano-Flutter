import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';
import '../../utils/constants.dart';
import 'report_detail_screen.dart';
import '../widget/report_skeleton.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      const userToken = "TU_TOKEN_DE_AUTH";
      context.read<ReportProvider>().loadData(userToken);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) => reportProvider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Buscar reportes...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          if (reportProvider.categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:
                    reportProvider.categories.length +
                    1, // +1 para el botón "Todas"
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Botón especial para limpiar filtros
                    final isSelected =
                        reportProvider.selectedCategoryId == null;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: const Text('Todas'),
                        selected: isSelected,
                        selectedColor: Colors.blue.withValues(alpha: 0.2),
                        checkmarkColor: Colors.blue,
                        onSelected: (_) => reportProvider.selectCategory(null),
                      ),
                    );
                  }

                  final category = reportProvider.categories[index - 1];
                  final isSelected =
                      reportProvider.selectedCategoryId == category.id;

                  final style = Constants.getCategoryStyle(category.name);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      avatar: Icon(
                        style['icon'],
                        size: 18,
                        color: isSelected ? style['color'] : Colors.grey,
                      ),
                      label: Text(category.name),
                      selected: isSelected,
                      selectedColor: style['color'].withValues(alpha: 0.2),
                      checkmarkColor: style['color'],
                      labelStyle: TextStyle(
                        color: isSelected ? style['color'] : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (_) =>
                          reportProvider.selectCategory(category.id),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: reportProvider.isLoading
                ? const ReportSkeleton()
                : reportProvider.reports.isEmpty
                ? const Center(child: Text('No hay reportes para mostrar'))
                : ListView.builder(
                    itemCount: reportProvider.reports.length,
                    itemBuilder: (context, index) {
                      final report = reportProvider.reports[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: report.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    report.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                          title: Text(
                            report.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              report.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReportDetailScreen(report: report),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
