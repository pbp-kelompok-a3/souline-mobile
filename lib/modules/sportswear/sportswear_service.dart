import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:souline_mobile/shared/models/sportswear_model.dart';

class SportswearService {
  final CookieRequest request;
  SportswearService(this.request);

  String get _baseUrl => "https://farrel-rifqi-souline.pbp.cs.ui.ac.id/sportswear/api";

  // Fetch brand list
  Future<List<Product>> fetchBrands({String? tag, String? query}) async {
    String url = "$_baseUrl/list/";

    if (tag != null && tag != 'All' && tag.isNotEmpty) {
      url += "?tag=$tag";
      if (query != null && query.isNotEmpty) {
        url += "&q=$query";
      }
    } else if (query != null && query.isNotEmpty) {
      url += "?q=$query";
    }

    try {
      final response = await request.get(url);
      if (response is List) {
        return response.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Create
  Future<bool> createBrand(Map<String, dynamic> data) async {
    try {
      final response = await request.postJson(
        '$_baseUrl/create/',
        jsonEncode(data),
      );
      return response['status'] == 'success' ||
             response.containsKey('id') ||
             response['message'] == 'Created';
    } catch (e) {
      return false;
    }
  }

  // Update
  Future<bool> updateBrand(int id, Map<String, dynamic> data) async {
    final String url = '$_baseUrl/update/';
    data['id'] = id;

    try {
      final response = await request.postJson(url, jsonEncode(data));
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  // Delete
  Future<bool> deleteBrand(int id) async {
    final String url = '$_baseUrl/delete/';

    try {
      final response = await request.postJson(url, jsonEncode({'id': id}));
      return response['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
}