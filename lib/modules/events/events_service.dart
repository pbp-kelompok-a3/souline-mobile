import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../shared/models/event_model.dart';

class EventService {
  final CookieRequest request;
  final String baseUrl;

  EventService(this.request, this.baseUrl);

  String _joinBase(String path) {
    if (baseUrl.endsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  /// Fetch events from API (public endpoint)
  /// [filter] = '', 'soon', 'later'
  /// [kota] = optional city filter
  Future<List<EventModel>> fetchEvents({
    String filter = '',
    String kota = '',
  }) async {
    try {
      String endpoint = 'events/json/';
      if (filter == 'soon') {
        endpoint = 'events/json/soon/';
      } else if (filter == 'later') {
        endpoint = 'events/json/later/';
      }

      String url = _joinBase(endpoint);
      if (kota.isNotEmpty) {
        url += '?kota=$kota';
      }

      final response = await request.get(url);

      if (response is List) {
        return response.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  /// Delete an event (requires authentication)
  Future<bool> deleteEvent(int eventId) async {
    try {
      final url = _joinBase('events/api/$eventId/delete/');
      final response = await request.postJson(url, jsonEncode({}));

      return response['status'] == 'success' || response['message'] != null;
    } catch (e) {
      throw Exception('Error deleting event: $e');
    }
  }

  /// Create a new event (requires authentication)
  Future<bool> createEvent({
    required String name,
    required String date,
    required String description,
    required String location,
    String? posterUrl,
  }) async {
    try {
      final url = _joinBase('events/api/create/');
      final body = {
        'name': name,
        'date': date,
        'description': description,
        'location': location,
        if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
      };

      final response = await request.postJson(url, jsonEncode(body));
      return response['status'] == 'success' || response['id'] != null;
    } catch (e) {
      throw Exception('Error creating event: $e');
    }
  }

  /// Update an existing event (requires authentication)
  Future<bool> updateEvent({
    required int eventId,
    required String name,
    required String date,
    required String description,
    required String location,
    String? posterUrl,
  }) async {
    try {
      final url = _joinBase('events/api/$eventId/edit/');
      final body = {
        'name': name,
        'date': date,
        'description': description,
        'location': location,
        if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
      };

      final response = await request.postJson(url, jsonEncode(body));
      return response['status'] == 'success' || response['id'] != null;
    } catch (e) {
      throw Exception('Error updating event: $e');
    }
  }
}
