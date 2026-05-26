class ReportModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['image_url'],
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
    );
  }
}
