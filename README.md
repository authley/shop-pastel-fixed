# Pastel Shop (tugasleyla)

Aplikasi Flutter katalog produk bertema pastel dengan **CRUD produk lengkap**
yang terhubung ke backend REST [DummyJSON](https://dummyjson.com/docs/products).

https://youtu.be/BEEc5I5ugwg?feature=shared

## Fitur

| Operasi | Endpoint | Di aplikasi |
| --- | --- | --- |
| Read (daftar) | `GET /products?limit=0` | Grid produk, tarik untuk refresh |
| Read (cari) | `GET /products/search?q=` | Kolom pencarian (debounce 450 ms) |
| Read (kategori) | `GET /products/category-list`, `/products/category/{slug}` | Chip kategori |
| Read (detail) | `GET /products/{id}` | Halaman detail + carousel gambar + ulasan |
| Create | `POST /products/add` | Tombol **Tambah** |
| Update | `PATCH /products/{id}` | Ikon edit di detail / menu "⋯" di kartu |
| Delete | `DELETE /products/{id}` | Ikon hapus di detail / menu "⋯" di kartu (dengan konfirmasi) |

Menu aksi kartu (Lihat / Edit / Hapus) dibuka lewat tombol **⋯** atau tekan lama kartu.

## Catatan penting tentang backend

DummyJSON adalah API tiruan: `POST`/`PATCH`/`DELETE` selalu membalas sukses
**tetapi data di server tidak benar-benar berubah**, dan `POST /products/add`
selalu mengembalikan `id: 195`. Karena itu `ProductProvider` menyimpan
*overlay* lokal (produk baru, produk yang diedit, produk yang dihapus) yang
diterapkan lagi pada setiap refresh / cari / filter, sehingga perilaku CRUD
konsisten selama aplikasi berjalan. Produk baru diberi id lokal unik mulai dari
`10000`; produk lokal tidak dikirim ke `PATCH`/`DELETE` (server pasti 404).
Perubahan **tidak bertahan** setelah aplikasi ditutup. Untuk persistensi
sungguhan, ganti `baseUrl` di `lib/services/api_service_products.dart` dengan
backend milikmu sendiri; provider tidak perlu diubah.

## Menjalankan

```bash
flutter pub get
flutter run
```

## Struktur

```
lib/
  main.dart                      router (go_router) + provider
  models/product_model.dart      Product, copyWith, fromForm, applyForm
  services/api_service_products.dart   semua pemanggilan HTTP (dio)
  providers/product_provider.dart      state + CRUD + overlay lokal
  screens/                       list, detail, add, edit
  widgets/                       product_form, product_actions, product_loader
  theme/                         pastel_theme, product_card
```
