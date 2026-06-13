// ─────────────────────────────────────────────────────────────
// report_service.dart
// Disesuaikan dengan field yang diterima API:
// title, description, address, latitude, longitude,
// category, water_height, photo (file)
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/models.dart';
import 'api_client.dart';

final reportServiceProvider =
    Provider<ReportService>((ref) => ReportService());

class ReportService {
  final _dio = ApiClient().dio;

  // ── Laporan milik user sendiri (masyarakat) ───────────────
  Future<List<ReportModel>> getMyReports() async {
    final res = await _dio.get(AppConstants.epReports);
    final data = res.data['data'] as List;
    return data
        .map((j) => ReportModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── Semua laporan (pemerintah) ────────────────────────────
  Future<List<ReportModel>> getAllReports({String? status}) async {
    final res = await _dio.get(
      AppConstants.epAdminReports,
      queryParameters: (status != null && status != 'semua')
          ? {'status': status}
          : null,
    );
    final data = res.data['data'] as List;
    return data
        .map((j) => ReportModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  // ── Detail 1 laporan ──────────────────────────────────────
  Future<ReportModel> getReport(int id) async {
    final res = await _dio.get('${AppConstants.epAdminReports}/$id');
    return ReportModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  // ── Buat laporan baru ─────────────────────────────────────
  // Pakai multipart/form-data karena ada upload foto
  Future<ReportModel> createReport({
    required String title,
    required String description,
    String? address,
    required double latitude,
    required double longitude,
    required String category, // 'genangan'|'banjir_sedang'|'banjir_parah'
    double? waterHeight,
    File? photo,
  }) async {
    final formData = FormData.fromMap({
      'title':        title,
      'description':  description,
      if (address != null) 'address': address,
      'latitude':     latitude.toString(),
      'longitude':    longitude.toString(),
      'category':     category,
      if (waterHeight != null) 'water_height': waterHeight.toString(),
      if (photo != null)
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: photo.path.split('/').last,
        ),
    });

    final res = await _dio.post(
      AppConstants.epReports,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    return ReportModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  // ── Update status (pemerintah) ────────────────────────────
  // Status valid: 'pending' | 'selesai' | 'batal'
  Future<ReportModel> updateStatus(int id, String status) async {
    final res = await _dio.post(
      '${AppConstants.epAdminReports}/$id/status',
      data: {'status': status},
    );
    return ReportModel.fromJson(
        res.data['data'] as Map<String, dynamic>);
  }

  // ── Hapus laporan ─────────────────────────────────────────
  Future<void> deleteReport(int id) async {
    await _dio.delete('${AppConstants.epAdminReports}/$id');
  }
}
