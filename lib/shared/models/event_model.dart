import 'package:intl/intl.dart';

class EventModel {
  final int id;
  final String name;
  final DateTime date;
  final String description;
  final String poster;
  final String location;
  final String? locationId;
  final String createdBy;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    required this.poster,
    required this.location,
    this.locationId,
    required this.createdBy,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['date'] ?? '';
    DateTime parsed = DateTime.tryParse(dateRaw) ?? DateTime.now();
    if (!dateRaw.contains('-')) {
      try {
        parsed = DateFormat("dd MMMM yyyy").parse(dateRaw);
      } catch (_) {
        try {
          parsed = DateFormat("dd MMM yyyy").parse(dateRaw);
        } catch (_) {
          parsed = DateTime.now();
        }
      }
    }

    return EventModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      date: parsed,
      description: json['description'] ?? '',
      poster: json['poster'] ?? '',
      location: json['location'] ?? '',
      locationId: json['location_id']?.toString(),
      createdBy: json['created_by'] ?? '',
    );
  }
}
