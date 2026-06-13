// ─────────────────────────────────────────────────────────────
// form_laporan_screen.dart — UPDATED
// Field yang dikirim ke API:
// title, description, address, latitude, longitude,
// category (genangan|banjir_sedang|banjir_parah), water_height, photo
// ─────────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../models/models.dart';
import '../../providers/report_provider.dart';
import '../../utils/geocode_helper.dart';
import '../../utils/snackbar_helper.dart';

class FormLaporanScreen extends ConsumerStatefulWidget {
  const FormLaporanScreen({super.key});

  @override
  ConsumerState<FormLaporanScreen> createState() =>
      _FormLaporanScreenState();
}

class _FormLaporanScreenState
    extends ConsumerState<FormLaporanScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _alamatCtrl= TextEditingController();

  static const _primaryBlue = Color(0xFF1a4fd4);

  String? _category; // 'genangan'|'banjir_sedang'|'banjir_parah'
  double _waterHeight = 0;
  File?  _photo;
  LatLng _pin = const LatLng(-7.4479, 112.7183);
  bool   _loading   = false;
  bool   _geocoding = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  Future<void> _onMapTap(TapPosition _, LatLng pos) async {
    setState(() {
      _pin = pos;
      _geocoding = true;
    });
    final alamat = await GeocodeHelper.reverseGeocode(
        pos.latitude, pos.longitude);
    if (mounted) {
      setState(() {
        _alamatCtrl.text = alamat;
        _geocoding = false;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      showErrorSnackbar(context, 'Pilih kategori banjir terlebih dahulu');
      return;
    }
    setState(() => _loading = true);
    try {
      // Panggil provider dengan nama field yang benar
      await ref.read(reportProvider.notifier).createReport(
            title:       _titleCtrl.text.trim(),
            description: _descCtrl.text.trim(),
            address:     _alamatCtrl.text.trim(),
            latitude:    _pin.latitude,
            longitude:   _pin.longitude,
            category:    _category!,
            waterHeight: _waterHeight,
            photo:       _photo,
          );
      if (!mounted) return;
      showSuccessSnackbar(context, 'Laporan berhasil dikirim!');
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(
          context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        title: const Text('Buat laporan baru',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [

            // ── INFORMASI ──────────────────────────────────
            _sectionCard(
              title: 'Informasi laporan',
              icon: Icons.description_outlined,
              children: [
                _label('Judul laporan', required: true),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDec('Contoh: Banjir Jl. Ahmad Yani'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Judul wajib diisi'
                      : null,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Kategori', required: true),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: _inputDec('Pilih...'),
                            isExpanded: true,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black87),
                            // Tampilkan label yang ramah
                            items: kKategoriLabels.entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Tinggi air (cm)'),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAFBFF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: const Color(0xFFD0D8EE)),
                            ),
                            child: Text(
                              '${_waterHeight.toInt()} cm',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _primaryBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _primaryBlue,
                    thumbColor: _primaryBlue,
                    inactiveTrackColor: const Color(0xFFD0D8EE),
                  ),
                  child: Slider(
                    value: _waterHeight,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    onChanged: (v) => setState(() => _waterHeight = v),
                  ),
                ),
                _label('Deskripsi', required: true),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration:
                      _inputDec('Tuliskan detail kejadian banjir...'),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Deskripsi wajib diisi'
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── FOTO ───────────────────────────────────────
            _sectionCard(
              title: 'Foto kejadian',
              icon: Icons.photo_camera_outlined,
              subtitle: '(opsional)',
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: _photo != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_photo!,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        )
                      : Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FD),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFB0BBDD)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined,
                                  size: 32, color: Color(0xFF8899CC)),
                              SizedBox(height: 6),
                              Text('Ketuk untuk pilih foto',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF8899CC),
                                      fontWeight: FontWeight.w500)),
                              Text('Dari kamera atau galeri',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFAABBCC))),
                            ],
                          ),
                        ),
                ),
                if (_photo != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _photo = null),
                      icon: const Icon(Icons.delete_outline,
                          size: 16, color: Colors.red),
                      label: const Text('Hapus foto',
                          style: TextStyle(
                              color: Colors.red, fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // ── LOKASI ─────────────────────────────────────
            _sectionCard(
              title: 'Lokasi kejadian',
              icon: Icons.location_on_outlined,
              children: [
                _label('Ketuk peta untuk menentukan lokasi',
                    required: true),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 160,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _pin,
                        initialZoom: 14,
                        onTap: _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.example.sistem_banjir',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _pin,
                              width: 36,
                              height: 36,
                              child: const Icon(Icons.location_pin,
                                  color: _primaryBlue, size: 36),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _label('Alamat (otomatis dari peta)'),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD0D8EE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_pin,
                          size: 16, color: _primaryBlue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _geocoding
                            ? const Text('Mendeteksi alamat...',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic))
                            : Text(
                                _alamatCtrl.text.isEmpty
                                    ? 'Ketuk peta untuk mendapatkan alamat'
                                    : _alamatCtrl.text,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: _alamatCtrl.text.isEmpty
                                        ? Colors.grey
                                        : const Color(0xFF3a5080)),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _coordBox(
                        'Latitude',
                        _pin.latitude.toStringAsFixed(4))),
                    const SizedBox(width: 8),
                    Expanded(child: _coordBox(
                        'Longitude',
                        _pin.longitude.toStringAsFixed(4))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── SUBMIT ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined),
                label: Text(_loading ? 'Mengirim...' : 'Kirim laporan',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: const Text('Batal, kembali',
                    style:
                        TextStyle(color: Colors.grey, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE3F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 15, color: _primaryBlue),
              const SizedBox(width: 5),
              Text(title,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _primaryBlue)),
              if (subtitle != null)
                Text(' $subtitle',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
            ]),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      );

  Widget _label(String text, {bool required = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87),
            children: required
                ? const [
                    TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red))
                  ]
                : [],
          ),
        ),
      );

  Widget _coordBox(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FD),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFFDDE3F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 9, color: Color(0xFFAABBCC))),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Color(0xFF333333))),
          ],
        ),
      );

  InputDecoration _inputDec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: Color(0xFFAAABBB), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFAFBFF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD0D8EE))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _primaryBlue)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red)),
      );
}
