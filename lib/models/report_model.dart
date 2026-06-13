// ─────────────────────────────────────────────────────────────
// report_model.dart
// Disesuaikan dengan response API Laravel:
// title, description, address, latitude, longitude,
// category, water_height, photo_url, status, created_at
// ─────────────────────────────────────────────────────────────

class ReportModel {
  final int id;
  final int userId;
  final String title;
  final String description;
  final String? address;
  final double latitude;
  final double longitude;
  final String? category;
  final double? waterHeight; // water_height dalam cm
  final String? photoUrl;   // photo_url (full URL dari Storage::url)
  final String status;      // 'pending' | 'selesai' | 'batal'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? pelapor;    // dari relasi user.name
  final String? emailPelapor; // dari relasi user.email

  const ReportModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.address,
    required this.latitude,
    required this.longitude,
    this.category,
    this.waterHeight,
    this.photoUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.pelapor,
    this.emailPelapor,
  });

  // ── Getter helpers ─────────────────────────────────────────
  bool get isPending  => status == 'pending';
  bool get isSelesai  => status == 'selesai';
  bool get isBatal    => status == 'batal';
  bool get hasFoto    => photoUrl != null && photoUrl!.isNotEmpty;

  String get categoryLabel {
    switch (category) {
      case 'genangan':      return 'Genangan Air';
      case 'banjir_sedang': return 'Banjir Sedang';
      case 'banjir_parah':  return 'Banjir Parah';
      default:              return category ?? '-';
    }
  }

String get judul      => title;
String get deskripsi  => description;
String get alamat     => address ?? '';
double get lat        => latitude;
double get lng        => longitude;
String? get kategori  => category;
double? get tinggiAir => waterHeight;
String? get fotoUrl   => photoUrl;

  // ── fromJson — sesuai response API ────────────────────────
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id:           json['id'] as int,
      userId:       json['user_id'] as int,
      title:        json['title'] as String,
      description:  json['description'] as String? ?? '',
      address:      json['address'] as String?,
      latitude:     double.parse(json['latitude'].toString()),
      longitude:    double.parse(json['longitude'].toString()),
      category:     json['category'] as String?,
      waterHeight:  json['water_height'] != null
                      ? double.parse(json['water_height'].toString())
                      : null,
      photoUrl:     json['photo_url'] as String?,
      status:       (json['status'] as String? ?? 'pending').toLowerCase(),
      createdAt:    DateTime.parse(json['created_at'] as String),
      updatedAt:    DateTime.parse(json['updated_at'] as String),
      pelapor:      json['user']?['name'] as String?,
      emailPelapor: json['user']?['email'] as String?,
    );
  }

  // ── toJson — untuk kirim ke API ───────────────────────────
  Map<String, dynamic> toJson() => {
        'title':        title,
        'description':  description,
        'address':      address,
        'latitude':     latitude,
        'longitude':    longitude,
        'category':     category,
        'water_height': waterHeight,
        'status':       status,
      };

  ReportModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? category,
    double? waterHeight,
    String? photoUrl,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pelapor,
    String? emailPelapor,
  }) {
    return ReportModel(
      id:           id ?? this.id,
      userId:       userId ?? this.userId,
      title:        title ?? this.title,
      description:  description ?? this.description,
      address:      address ?? this.address,
      latitude:     latitude ?? this.latitude,
      longitude:    longitude ?? this.longitude,
      category:     category ?? this.category,
      waterHeight:  waterHeight ?? this.waterHeight,
      photoUrl:     photoUrl ?? this.photoUrl,
      status:       status ?? this.status,
      createdAt:    createdAt ?? this.createdAt,
      updatedAt:    updatedAt ?? this.updatedAt,
      pelapor:      pelapor ?? this.pelapor,
      emailPelapor: emailPelapor ?? this.emailPelapor,
    );
  }

  @override
  String toString() =>
      'ReportModel(id: $id, title: $title, status: $status)';
}

// ── Konstanta ─────────────────────────────────────────────────

// Kategori sesuai enum di database
const List<String> kKategoriOptions = [
  'genangan',
  'banjir_sedang',
  'banjir_parah',
];

// Label tampilan untuk dropdown
const Map<String, String> kKategoriLabels = {
  'genangan':      'Genangan Air',
  'banjir_sedang': 'Banjir Sedang',
  'banjir_parah':  'Banjir Parah',
};

// Status sesuai enum di database
const List<String> kStatusOptions = [
  'pending',
  'selesai',
  'batal',
];

// Label tampilan untuk dropdown status
const Map<String, String> kStatusLabels = {
  'pending': 'Pending',
  'selesai': 'Selesai',
  'batal':   'Batal',
};
