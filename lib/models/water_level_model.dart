class WaterLevelModel {
  final int id;
  final String lokasi;
  final double tinggiAir; // dalam cm
  final double? lat;
  final double? lng;
  final String status; // 'normal' | 'waspada' | 'siaga' | 'bahaya'
  final DateTime tanggal;

  const WaterLevelModel({
    required this.id,
    required this.lokasi,
    required this.tinggiAir,
    this.lat,
    this.lng,
    required this.status,
    required this.tanggal,
  });

  bool get isNormal => status == 'normal';
  bool get isWaspada => status == 'waspada';
  bool get isSiaga => status == 'siaga';
  bool get isBahaya => status == 'bahaya';
  bool get hasKoordinat => lat != null && lng != null;

  /// Warna status: normal=hijau, waspada=kuning, siaga=oranye, bahaya=merah
  String get statusLabel {
    switch (status) {
      case 'normal':   return 'Normal';
      case 'waspada':  return 'Waspada';
      case 'siaga':    return 'Siaga';
      case 'bahaya':   return 'Bahaya';
      default:         return status;
    }
  }

  factory WaterLevelModel.fromJson(Map<String, dynamic> json) {
    return WaterLevelModel(
      id: json['id'] as int,
      lokasi: json['lokasi'] as String,
      tinggiAir: double.parse(json['tinggi_air'].toString()),
      lat: json['lat'] != null ? double.parse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.parse(json['lng'].toString()) : null,
      status: (json['status'] as String? ?? 'normal').toLowerCase(),
      tanggal: DateTime.parse(json['tanggal'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lokasi': lokasi,
        'tinggi_air': tinggiAir,
        'lat': lat,
        'lng': lng,
        'status': status,
        'tanggal': tanggal.toIso8601String(),
      };

  @override
  String toString() =>
      'WaterLevelModel(lokasi: $lokasi, tinggiAir: $tinggiAir cm, status: $status)';
}
