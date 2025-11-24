# COURTIFY Mobile App – Flutter

Courtify Mobile adalah aplikasi Flutter yang terintegrasi dengan web service Django (Proyek Tengah Semester). Aplikasi ini digunakan untuk melakukan booking lapangan olahraga, mengelola lapangan bagi penyedia, membaca artikel olahraga, melihat iklan, serta menyimpan wishlist.

Aplikasi Flutter ini menggunakan backend Django yang sama dengan aplikasi web sebelumnya, sehingga seluruh data antara web dan mobile saling sinkron.

---

## Daftar Anggota Kelompok

| No | Nama Lengkap | NIM | Pembagian Tugas |
|----|--------------|-----|------------------|
| 1 | Rafa Rally Soelistiono | 2406344675 | Autentikasi, Role Management, Wishlist |
| 2 | Wildan Al Rizka Yusuf | 2406407083 | Modul Booking Lapangan |
| 3 | Justin Timothy Wirawan | 2406413981 | Modul Manajemen Lapangan (Owner Dashboard) |
| 4 | Msy. Aulya Salsabila Putri | 2406353364 | Modul Iklan |
| 5 | Khayra Tazkiya | 2406428876 | Modul Artikel / Berita Olahraga |

---

## Deskripsi Aplikasi

Courtify Mobile adalah aplikasi yang bertujuan untuk mempermudah pengguna dalam:

- Mencari dan memesan lapangan olahraga.
- Melihat detail lapangan seperti fasilitas, lokasi, dan harga.
- Menyimpan wishlist lapangan.
- Membaca artikel atau berita olahraga.
- Mengelola profil pengguna.

Penyedia lapangan dapat:

- Menambah, mengedit, dan menghapus lapangan.
- Membuat dan mengelola iklan promosi.
- Membuat dan mengelola artikel atau berita olahraga.

Seluruh fitur pada aplikasi diakses melalui API Django yang sudah dibuat pada PTS, sehingga Flutter hanya berperan sebagai frontend mobile.

---

## Daftar Modul yang Diimplementasikan Beserta Pembagian Kerja

### 1. Modul Autentikasi dan Role Management  
Penanggung jawab: Rafa Rally Soelistiono

Fitur:
- Register user dan owner
- Login menggunakan session cookie
- Logout
- Pengaturan profil pengguna
- Redirect halaman berdasarkan role

---

### 2. Modul Booking Lapangan  
Penanggung jawab: Wildan Al Rizka Yusuf

Fitur:
- Menampilkan daftar lapangan yang tersedia
- Membuat booking baru
- Mengedit jadwal booking
- Membatalkan booking
- Melihat riwayat booking pengguna

---

### 3. Modul Manajemen Lapangan (Owner)  
Penanggung jawab: Justin Timothy Wirawan

Fitur:
- Menambah lapangan baru
- Mengedit informasi lapangan
- Menghapus lapangan
- Melihat daftar lapangan yang dimiliki oleh penyedia

---

### 4. Modul Artikel / Berita Olahraga  
Penanggung jawab: Khayra Tazkiya

Fitur:
- Melihat daftar artikel
- Menambah artikel
- Mengedit artikel
- Menghapus artikel
- Melihat detail artikel

---

### 5. Modul Iklan  
Penanggung jawab: Msy. Aulya Salsabila Putri

Fitur:
- Menambah iklan
- Mengedit iklan
- Menghapus iklan
- Melihat daftar iklan yang dimiliki owner

---

### 6. Modul Wishlist  
Penanggung jawab: Rafa Rally Soelistiono

Fitur:
- Menambah wishlist
- Menghapus wishlist
- Menampilkan daftar wishlist pengguna

---

## Peran atau Aktor Pengguna Aplikasi

| Role | Deskripsi |
|------|-----------|
| User (Pemain) | Dapat mencari lapangan, melakukan booking, membaca artikel, melihat iklan, dan menambah wishlist. |
| Owner (Penyedia Lapangan) | Dapat mengelola lapangan, membuat iklan, membuat artikel olahraga, dan melihat daftar booking. |
| Admin | Hanya digunakan di backend Django untuk manajemen global. Tidak digunakan lewat Flutter. |

---

## Alur Pengintegrasian Flutter dengan Web Service Django

Aplikasi Flutter terhubung sepenuhnya dengan web service Django yang sudah dibuat pada Proyek Tengah Semester. Alurnya sebagai berikut:

### 1. Autentikasi Menggunakan Session Cookie
- Flutter menggunakan library `pbp_django_auth` untuk mengelola login.
- Flutter mengirim request POST login ke endpoint Django.
- Django memberikan session cookie jika login berhasil.
- Session cookie disimpan oleh `CookieRequest`.
- Semua request selanjutnya ke Django akan otomatis membawa cookie untuk menjaga session.

### 2. Pengambilan Data (GET)
- Flutter mengambil data dari Django menggunakan endpoint JSON.
- Contoh data yang diambil: lapangan, booking, artikel, wishlist, iklan.
- JSON yang diterima Flutter diubah menjadi model Dart menggunakan `fromJson`.

### 3. Pengiriman Data (POST/PUT/DELETE)
- Untuk membuat booking, menambah lapangan, mengedit artikel, dll:
  - Flutter mengirim request POST/PUT/DELETE melalui CookieRequest.
  - Django melakukan validasi user, role, dan izin akses.
  - Data disimpan pada database backend.

### 4. Kesamaan Struktur Model
- Model Dart disesuaikan dengan struktur model Django.
- Hal ini memastikan integrasi data berjalan konsisten dan aman.

### 5. Satu Backend untuk Web dan Mobile
- Aplikasi web (Django Template) dan aplikasi Flutter menggunakan backend yang sama.
- Semua perubahan data pada Flutter langsung mempengaruhi data di aplikasi web, dan sebaliknya.

---

## Link Figma  
(akan diisi nanti)

