import 'dart:convert';

class Event {
  final int id;
  final String name;
  final String description;
  final String location;
  final String owner;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.owner,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      owner: json['owner'],
    );
  }
}
