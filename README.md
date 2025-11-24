#  COURTIFY Mobile App – Flutter Version

Aplikasi mobile **Courtify** dibangun menggunakan **Flutter** sebagai frontend dan **Django** sebagai backend. Aplikasi ini menyediakan layanan booking lapangan olahraga, pengelolaan lapangan oleh penyedia, artikel olahraga, iklan, dan wishlist.

---

## Anggota Kelompok

| No | Nama Lengkap | NIM | Peran / Modul (Flutter) |
|----|--------------|-----|--------------------------|
| 1  | **Rafa Rally Soelistiono** | 2406344675 | Autentikasi, Role Management, Wishlist |
| 2  | **Wildan Al Rizka Yusuf** | 2406407083 | Booking Lapangan |
| 3  | **Justin Timothy Wirawan** | 2406413981 | Manajemen Lapangan (Owner Dashboard) |
| 4  | **Msy. Aulya Salsabila Putri** | 2406353364 | Modul Iklan |
| 5  | **Khayra Tazkiya** | 2406428876 | Modul Artikel & Berita Olahraga |

---

##  Deskripsi Aplikasi Flutter

**Courtify Mobile** adalah aplikasi Flutter yang terhubung dengan backend Django untuk mempermudah:

### ✔ Pengguna (User)
- Mencari dan memesan lapangan olahraga
- Menyimpan wishlist
- Membaca artikel olahraga
- Mengatur profil

### ✔ Penyedia Lapangan (Owner)
- Menambahkan & mengelola lapangan
- Membuat iklan
- Membuat artikel berita olahraga
- Melihat daftar booking

### **Tujuan Utama**
- Mempermudah booking lapangan secara mobile  
- Menjadi wadah komunitas olahraga  
- Membantu penyedia mengelola fasilitas olahraga

---

#  Modul Flutter

## 1. Autentikasi & Role Management
**Penanggung jawab:** Rafa Rally Soelistiono

### Fitur
- Register user & owner
- Login dengan CookieRequest
- Redirect halaman sesuai role
- Edit profil

### Halaman
- `login_page.dart`
- `register_page.dart`
- `profile_page.dart`

### Model
- UserProfile

---

## 2. Booking Lapangan
**Penanggung jawab:** Wildan Al Rizka Yusuf

### Fitur
- List lapangan
- Form booking
- Update booking
- Cancel booking
- History booking

### Halaman
- `booking_list_page.dart`
- `booking_form_page.dart`
- `booking_history_page.dart`

### Model
- Booking

---

## 3. Manajemen Lapangan (Owner Dashboard)
**Penanggung jawab:** Justin Timothy Wirawan

### Fitur
- Tambah lapangan
- Edit lapangan
- Hapus lapangan
- Lihat daftar lapangan owner

### Halaman
- `lapangan_form_page.dart`
- `lapangan_list_owner_page.dart`
- `lapangan_detail_page.dart`

### Model
- Lapangan

---

## 4. Artikel & Berita Olahraga
**Penanggung jawab:** Khayra Tazkiya

### Fitur
- List artikel
- Tambah artikel
- Edit artikel
- Hapus artikel
- Detail artikel

### Halaman
- `news_list_page.dart`
- `news_form_page.dart`
- `news_detail_page.dart`

### Model
- News

---

## 5. Modul Iklan
**Penanggung jawab:** Msy. Aulya Salsabila Putri

### Fitur
- Tambah iklan
- Edit iklan
- Hapus iklan
- List iklan owner

### Halaman
- `iklan_form_page.dart`
- `iklan_list_owner_page.dart`

### Model
- Iklan

---

## 6. Modul Wishlist
**Penanggung jawab:** Rafa Rally Soelistiono

### Fitur
- Tambah wishlist
- Hapus wishlist
- Lihat wishlist user

### Halaman
- `wishlist_page.dart`

### Model
- Wishlist

---

# Dataset Awal (Backend Django)

Dataset awal lapangan olahraga menggunakan data publik:

Kategori: futsal, basket, tenis, badminton, padel  
Sumber dataset:  
https://opendata.jabarprov.go.id/id/dataset/jumlah-fasilitaslapangan-olahraga-berdasarkan-kategori-dan-desakelurahan-di-jawa-barat

---

# Role Pengguna

| Role | Deskripsi |
|------|-----------|
| **User (Pemain)** | Mencari lapangan, booking, membaca artikel, wishlist |
| **Owner (Penyedia)** | Mengelola lapangan, artikel, iklan |
| **Admin** | Manajemen global (backend Django) |

---

# Tautan Deployment & Desain

- **Backend (Django / PWS):**  
  https://justin-timothy-courtify.pbp.cs.ui.ac.id/

- **Desain Figma:**  
  https://www.figma.com/design/WFXPpXYAMJKiQBmJfbklMn/PBP-COURTIFY

---

