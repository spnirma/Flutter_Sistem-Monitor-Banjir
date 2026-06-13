// ─────────────────────────────────────────────────────────────
// report_provider.dart — UPDATED
// Parameter createReport disesuaikan dengan field API:
// title, description, address, latitude, longitude,
// category, waterHeight, photo
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/report_service.dart';

class ReportState {
  final List<ReportModel> reports;
  final bool isLoading;
  final String? error;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  ReportState copyWith({
    List<ReportModel>? reports,
    bool? isLoading,
    String? error,
  }) =>
      ReportState(
        reports:   reports   ?? this.reports,
        isLoading: isLoading ?? this.isLoading,
        error:     error,
      );
}

final reportProvider = NotifierProvider<ReportNotifier, ReportState>(
  ReportNotifier.new,
);

class ReportNotifier extends Notifier<ReportState> {
  late final ReportService _service;

  @override
  ReportState build() {
    _service = ref.read(reportServiceProvider);
    return const ReportState();
  }

  // ── Laporan milik user (masyarakat) ───────────────────────
  Future<void> fetchMyReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports = await _service.getMyReports();
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Semua laporan (pemerintah & peta) ─────────────────────
  Future<void> fetchAllReports({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final reports =
          await _service.getAllReports(status: status);
      state = state.copyWith(reports: reports, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  // ── Buat laporan baru ─────────────────────────────────────
  Future<void> createReport({
    required String title,
    required String description,
    String? address,
    required double latitude,
    required double longitude,
    required String category,
    double? waterHeight,
    File? photo,
  }) async {
    final newReport = await _service.createReport(
      title:       title,
      description: description,
      address:     address,
      latitude:    latitude,
      longitude:   longitude,
      category:    category,
      waterHeight: waterHeight,
      photo:       photo,
    );
    state = state.copyWith(
      reports: [newReport, ...state.reports],
    );
  }

  // ── Update status (pemerintah) ────────────────────────────
  Future<void> updateStatus(int id, String status) async {
    final updated = await _service.updateStatus(id, status);
    state = state.copyWith(
      reports: state.reports
          .map((r) => r.id == id ? updated : r)
          .toList(),
    );
  }

  // ── Hapus laporan ─────────────────────────────────────────
  Future<void> deleteReport(int id) async {
    await _service.deleteReport(id);
    state = state.copyWith(
      reports: state.reports.where((r) => r.id != id).toList(),
    );
  }
}
