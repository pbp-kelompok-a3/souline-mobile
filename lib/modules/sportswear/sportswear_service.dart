import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:souline_mobile/core/constants/app_constants.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';

class SportswearService {
  String get _baseUrl => '${AppConstants.baseUrl}sportswear/api';

  Future<Map<String, String>> _getAuthHeaders() async {
    return {'Content-Type': 'application/json; charset=UTF-8'};
  }

  // READ/LIST
  Future<List<Product>> fetchBrands({String? tag, String? query}) async {
    String url = '$_baseUrl/list/';
    Map<String, String> params = {};
    if (tag != null && tag.toLowerCase() != 'all') {
      params['tag'] = tag;
    }
    if (query != null && query.isNotEmpty) {
      params['q'] = query;
    }
    if (params.isNotEmpty) {
      url += '?${Uri(queryParameters: params).query}';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load brands. Status: ${response.statusCode}');
    }
  }

  // CREATE
  Future<Product> createBrand(Product newBrand) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/create/');

    final Map<String, dynamic> body = newBrand.toJson();
    body.remove('id');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Validation Failed: ${errorBody['errors'] ?? 'Invalid data submitted'}',
      );
    } else {
      throw Exception('Failed to create brand. Status: ${response.statusCode}');
    }
  }

  // UPDATE
  Future<Product> updateBrand(Product existingBrand) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/update/${existingBrand.id}/');

    final response = await http.put(
      url,
      headers: headers,
      body: jsonEncode(existingBrand.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'Validation Failed: ${errorBody['errors'] ?? 'Invalid data'}',
      );
    } else {
      throw Exception('Failed to update brand. Status: ${response.statusCode}');
    }
  }

  // DELETE
  Future<void> deleteBrand(int id) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$_baseUrl/delete/$id/');

    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    } else {
      throw Exception('Failed to delete brand. Status: ${response.statusCode}');
    }
  }
}
