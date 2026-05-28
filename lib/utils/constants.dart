import 'package:flutter/material.dart';

class Constants {
  static const String baseUrl = "http://44.206.63.158/api";
  //static const String baseUrl = "http://127.0.0.1:8000/api" para servidor propio

  // cambiar url por la de la pc
  static Map<String, dynamic> getCategoryStyle(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'seguridad':
      case 'robo':
      case 'delincuencia':
        return {'icon': Icons.shield_outlined, 'color': Colors.red};
      case 'infraestructura':
      case 'bache':
      case 'pistas':
        return {'icon': Icons.construction_outlined, 'color': Colors.amber[800]};
      case 'limpieza':
      case 'basura':
        return {'icon': Icons.delete_outline_rounded, 'color': Colors.green};
      case 'alumbrado':
      case 'luz':
        return {'icon': Icons.lightbulb_outline_rounded, 'color': Colors.orange};
      default:
        return {'icon': Icons.label_outline_rounded, 'color': Colors.blue};
    }
  }
}