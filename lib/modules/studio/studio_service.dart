import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/studio_entry.dart';

class StudioService {
  const StudioService(this.request);

  final CookieRequest request;

  String _url(String path) => '${AppConstants.baseUrl}$path';

  Future<StudioEntry> fetchStudios() async {
    final data = await request.get(_url('studio/json/'));
    return StudioEntry.fromJson(data as Map<String, dynamic>);
  }

  Future<bool> isAdmin() async {
    final data = await request.get(_url('is-admin/'));
    if (data is Map<String, dynamic> && data.containsKey('is_admin')) {
      return data['is_admin'] == true;
    }
    return false;
  }

  Future<void> createStudio({
    required String namaStudio,
    required String thumbnail,
    required UserKota kota,
    required String area,
    required String alamat,
    required String gmapsLink,
    required String nomorTelepon,
    required double rating,
  }) async {
    final payload = {
      'nama_studio': namaStudio,
      'thumbnail': thumbnail,
      'kota': userKotaValues.reverse[kota],
      'area': area,
      'alamat': alamat,
      'gmaps_link': gmapsLink,
      'nomor_telepon': nomorTelepon,
      'rating': rating,
    };

    final res = await request.postJson(_url('studio/create-flutter/'), jsonEncode(payload));
    _assertSuccess(res);
  }

  Future<void> updateStudio({
    required String id,
    required String namaStudio,
    required String thumbnail,
    required UserKota kota,
    required String area,
    required String alamat,
    required String gmapsLink,
    required String nomorTelepon,
    required double rating,
  }) async {
    final payload = {
      'nama_studio': namaStudio,
      'thumbnail': thumbnail,
      'kota': userKotaValues.reverse[kota],
      'area': area,
      'alamat': alamat,
      'gmaps_link': gmapsLink,
      'nomor_telepon': nomorTelepon,
      'rating': rating,
    };

    final res = await request.postJson(_url('studio/edit-flutter/$id/'), jsonEncode(payload));
    _assertSuccess(res);
  }

  Future<void> deleteStudio(String id) async {
    final res = await request.post(_url('studio/delete-flutter/$id/'), null);
    _assertSuccess(res);
  }

  void _assertSuccess(dynamic res) {
    if (res is Map<String, dynamic>) {
      if (res['status'] == 'success') return;
      final message = res['message'] ?? 'Unknown error';
      throw Exception('Studio API error: $message');
    }
    throw Exception('Studio API error: invalid response');
  }
}


String proxiedImageUrl(String originalUrl) {
  if (originalUrl.isEmpty) return originalUrl;

  // If it's already pointing to the backend, leave it as-is.
  if (originalUrl.startsWith(AppConstants.baseUrl)) return originalUrl;

  final encoded = Uri.encodeComponent(originalUrl);
  return '${AppConstants.baseUrl}studio/proxy-image/?url=$encoded';
}
