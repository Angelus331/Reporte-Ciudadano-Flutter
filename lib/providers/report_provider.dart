import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/category_model.dart';
import '../servicios/report_servicio.dart';
import '../servicios/category_services.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService = ReportService();
  final CategoryService _categoryService = CategoryService();

  List<ReportModel> _allReports = [];
  List<ReportModel> _filteredReports = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;
  String _searchQuery = '';
  int? _selectedCategoryId;

  List<ReportModel> get reports => _filteredReports;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  int? get selectedCategoryId => _selectedCategoryId;

  Future<void> loadData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _reportService
            .getReports(), // Si tu ReportService también requiere token, agrégalo aquí
        _categoryService.getCategories(token),
      ]);

      _allReports = results[0] as List<ReportModel>;
      _categories = results[1] as List<CategoryModel>;

      _applyFilter();
    } catch (e) {
      debugPrint("Error cargando datos en ReportProvider: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void selectCategory(int? categoryId) {
    if (_selectedCategoryId == categoryId) {
      _selectedCategoryId = null;
    } else {
      _selectedCategoryId = categoryId;
    }
    _applyFilter();
  }

  void _applyFilter() {
    _filteredReports = _allReports.where((report) {
      final matchesSearch =
          report.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          report.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategoryId == null ||
          report.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();

    notifyListeners();
  }
}
