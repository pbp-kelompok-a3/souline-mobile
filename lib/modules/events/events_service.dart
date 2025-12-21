import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:http/http.dart' as http;
import '../../shared/models/event_model.dart';

class EventService {
  final String baseUrl;

  EventService(this.baseUrl);

  String _joinBase(String path) {
    if (baseUrl.endsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }

  /// Fetch events from API
  /// [filter] = '', 'soon', 'later'
  /// [kota] = optional city filter
  Future<List<EventModel>> fetchEvents({String filter = '', String kota = ''}) async {
    try {
      final queryParameters = <String, String>{};
      if (filter.isNotEmpty) queryParameters['filter'] = filter;
      if (kota.isNotEmpty) queryParameters['kota'] = kota;

      final uri = Uri.parse(_joinBase('events/json/')).replace(queryParameters: queryParameters);

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load events: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => EventModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }
}
