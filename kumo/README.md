# Kumo – Flutter

Port Flutter dari `index.html` (Kumo – Nonton Anime).

## Struktur

```
kumo/
  pubspec.yaml
  lib/main.dart   ← seluruh app (model, state, 5 tab, detail sheet, player pratinjau)
```

Fitur yang di-port:
- Beranda: hero auto-rotate 6 dtk, Lanjutkan menonton, Baru rilis, Spotlight, Top 10
- Genre: filter chips + grid
- Terbaru: episode terbaru (sort episode desc)
- Cari: live search judul/genre
- Daftarku: persist `shared_preferences` (kunci `kumo`)
- Detail: bottom sheet + statistik + episode (maks 8) + Daftarku
- Player: pratinjau tanpa video (timer + slider + ±10 dtk). Ganti dengan `video_player` / HLS untuk produksi.
- Tema: terang / gelap / sistem (disimpan `kumoTheme`)
- Profil: statistik + hapus daftar + ganti tema

## Cara menjalankan

Flutter SDK **tidak terinstal** di environment ini, jadi jalankan lokal:

```bash
# 1. Install Flutter 3.x, lalu dari repo root:
cp -r kumo /tmp/kumo_app
cd /tmp/kumo_app

# 2. Generate folder platform (android/ios/web/…):
flutter create . --project-name kumo --org com.example

# 3. Ambil dependensi + run:
flutter pub get
flutter run
# atau: flutter run -d chrome
```

Alternatif cepat:

```bash
flutter create kumo_app
cp kumo/pubspec.yaml kumo_app/pubspec.yaml
cp kumo/lib/main.dart kumo_app/lib/main.dart
cd kumo_app && flutter pub get && flutter run
```

## Catatan produksi

- Ganti `PlayerScreen` dengan `video_player` + `chewie` dan URL HLS/DASH asli.
- Tambah `cached_network_image` untuk poster asli (sekarang gradient HSL seperti web).
- Tambah notifikasi jadwal rilis dengan `flutter_local_notifications`.
