# Flutter_Sistem-Monitor-Banjir
<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Laravel-11.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white"/>
  <img src="https://img.shields.io/badge/Sanctum-API Auth-FF2D20?style=for-the-badge&logo=laravel&logoColor=white"/>
  <img src="https://img.shields.io/badge/OpenStreetMap-Peta-7EBC6F?style=for-the-badge&logo=openstreetmap&logoColor=white"/>
</p>

Aplikasi mobile berbasis **Flutter** untuk pemantauan dan pelaporan banjir wilayah secara real-time. Dibangun dengan arsitektur **REST API** menggunakan Laravel sebagai backend dan Flutter sebagai frontend mobile. Dirancang untuk dua peran pengguna: **Masyarakat** dan **Pemerintah**.

---

## Tampilan Aplikasi

| Dashboard Masyarakat | Dashboard Pemerintah | Form Laporan |
|---|---|---|
| Peta persebaran banjir | Statistik laporan masuk | Input lokasi via peta |
| Stat card wilayah rawan | Filter status laporan | Upload foto kejadian |
| Tombol buat laporan | Update status penanganan | Reverse geocoding otomatis |

---

## Fitur Utama

### Role Masyarakat
- **Dashboard** peta persebaran banjir, statistik wilayah rawan & potensi banjir
- **Buat Laporan** form lengkap dengan pilih lokasi di peta interaktif, upload foto, estimasi tinggi air
- **Laporan Saya** riwayat laporan beserta status penanganan
- **Pantau Banjir** peta dengan radius area terdampak
- **Chat** komunikasi langsung dengan pemerintah + chatbot banjir

### Role Pemerintah
- **Dashboard** 4 stat card (Total/Pending/Selesai/Batal) + peta persebaran
- **Laporan Masuk** kelola semua laporan dengan search & filter status
- **Detail Laporan** lihat foto, lokasi peta, dan update status penanganan
- **Pantau Banjir** monitoring area terdampak dengan radius visual
- **Chat** komunikasi dengan masyarakat pelapor

### Fitur Teknis
- Autentikasi token-based dengan **Laravel Sanctum**
- Peta interaktif menggunakan **OpenStreetMap** (flutter_map)
- Reverse geocoding otomatis via **Nominatim API** (gratis, tanpa API key)
- Upload foto dengan **ImagePicker** (kamera & galeri)
- State management dengan **Riverpod**
- Navigasi dengan **GoRouter** + guard redirect per role
- Polling chat otomatis setiap 5 detik
- Tema warna berbeda per role: **Biru** (masyarakat) & **Hijau** (pemerintah)

---

## Arsitektur

```
Flutter (Mobile)  ←→  HTTPS  ←→  Laravel REST API  ←→  MySQL
```

### Struktur Folder Flutter
```
lib/
├── core/           # constants, theme, router
├── models/         # data class dari response API
├── services/       # HTTP request ke Laravel (Dio)
├── providers/      # state management (Riverpod)
├── screens/
│   ├── auth/       # login, register
│   ├── masyarakat/ # dashboard, laporan, pantau, form
│   ├── pemerintah/ # dashboard, laporan masuk, detail, pantau
│   └── shared/     # chat, profil
├── widgets/        # komponen reusable
└── utils/          # helper: tanggal, geocode, snackbar
```

### Endpoint API Laravel (20 endpoint)
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| POST | `/api/register` | Registrasi user |
| POST | `/api/login` | Login & dapat token |
| POST | `/api/logout` | Logout |
| GET | `/api/reports` | Laporan milik user |
| POST | `/api/reports` | Buat laporan baru |
| GET | `/api/admin/reports` | Semua laporan (pemerintah) |
| POST | `/api/admin/reports/{id}/status` | Update status |
| GET | `/api/water-levels` | Data pantau banjir |
| GET | `/api/chat` | List percakapan |
| POST | `/api/chat/{id}` | Kirim pesan |

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK 3.x
- PHP 8.2+
- Composer
- MySQL
- XAMPP / Laragon

### 1. Clone Repository
```bash
git clone https://github.com/username/sistem-pemantauan-banjir.git
cd sistem-pemantauan-banjir
```

### 2. Setup Backend Laravel
```bash
composer install
cp .env.example .env
php artisan key:generate

# Konfigurasi database di .env
php artisan migrate
php artisan storage:link
php artisan serve
```

### 3. Setup Flutter
```bash
cd flutter_app
flutter pub get

# Sesuaikan baseUrl di lib/core/constants.dart
# Emulator Android : http://10.0.2.2:8000/api
# Browser/Windows  : http://127.0.0.1:8000/api
# HP Fisik (ngrok) : https://xxxx.ngrok.io/api

flutter run
```

---

## Tech Stack

| Layer | Teknologi |
|---|---|
| Mobile Frontend | Flutter 3.x, Dart |
| State Management | Flutter Riverpod |
| Navigation | GoRouter |
| HTTP Client | Dio |
| Peta | flutter_map + OpenStreetMap |
| Geocoding | Nominatim (OpenStreetMap) |
| Kamera/Galeri | image_picker |
| Secure Storage | flutter_secure_storage |
| Backend | Laravel 11 |
| Auth API | Laravel Sanctum |
| Database | MySQL |

---

## Dependencies Flutter

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  dio: ^5.4.0
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  flutter_secure_storage: ^9.0.0
  image_picker: ^1.0.7
```

---

## Dikembangkan Untuk

Tugas Akhir / Proyek Mata Kuliah **Pemrograman Aplikasi Berbasis Platform (ABP)**  
Semester 6 — Sistem Informasi

---

