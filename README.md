# 💍 LMS Persiapan Pernikahan (terhubung Supabase)

Aplikasi Learning Management System (LMS) bimbingan pranikah, terhubung ke **Supabase**
(Auth + PostgreSQL) sehingga progres & nilai tiap peserta tersimpan permanen per akun.

> ⚠️ **PENTING:** Aplikasi TIDAK akan berfungsi penuh sebelum tabel database dibuat.
> Ikuti **Langkah 1** di bawah sekali saja.

---

## Struktur Proyek

```
lms-nikah/
├── index.html     # Frontend aplikasi (dasbor, materi, kuis, nilai, sertifikat)
├── login.html     # Halaman login/register (gerbang masuk utama)
├── admin.html     # Panel superadmin (materi, artikel, sertifikat, kelulusan)
├── config.js      # Kredensial publik Supabase (aman untuk diekspos)
├── schema.sql     # SKEMA DATABASE — WAJIB dijalankan sekali di Supabase
├── dev-server.js  # Server lokal (express) — TIDAK dipakai di Vercel
├── vercel.json    # Konfigurasi deploy statis Vercel
├── package.json
└── .env           # Kredensial (jangan dibagikan/commit)
```

---

## Langkah 1 — Buat Database di Supabase (WAJIB, sekali saja)

1. Buka [Supabase Dashboard](https://supabase.com/dashboard) → pilih project kamu.
2. Klik menu kiri **SQL Editor** → **New Query**.
3. Salin **seluruh isi `schema.sql`**, tempel, lalu klik **Run**.
   - Membuat tabel `profil`, `perjalanan_sesi`, `materi`, `artikel`, `sertifikat_template`
     lengkap dengan **Row Level Security (RLS)**.
   - **Akun yang pertama kali mendaftar otomatis menjadi SUPERADMIN** (tanpa perlu SQL manual).
   - Kalau sudah pernah ada akun sebelum skema dijalankan, user tertua otomatis dijadikan admin.

> Bila muncul pesan "Could not find the table", itu artinya langkah ini belum dijalankan.

---

## 🛡️ Panel Superadmin

Superadmin bisa mengontrol penuh: kelola peserta, isi materi 8 sesi + embed video YouTube,
tulis artikel, upload template background sertifikat, dan **melihat status kelulusan
(lulus/belum) setiap peserta** di tab **Kelulusan**.

**Cara menjadi Superadmin:**
1. Jalankan **Langkah 1** di atas (wajib).
2. Buka `login.html` → tab **Daftar** → buat akun (email + sandi min. 6 karakter).
3. Karena kamu adalah **user pertama**, akunmu otomatis jadi superadmin.
4. Masuk → otomatis diarahkan ke **Panel Admin** (`admin.html`).

**Halaman admin:** `https://lms-nikah.vercel.app/admin.html`

> Pengguna lain yang mendaftar setelahnya otomatis menjadi **peserta biasa**.
> Superadmin bisa menaikkan/menurunkan admin lain lewat tab **Peserta**.

---

## 🌐 Versi Online (Vercel)

Aplikasi telah di-deploy ke Vercel:

**› https://lms-nikah.vercel.app**

Saat mengetik domain, pengguna **selalu diarahkan ke halaman login** (tidak bisa langsung
masuk ke aplikasi). Setelah masuk, baru masuk ke dasbor / panel admin sesuai peran.

Deploy ulang ke production dengan CLI:

```bash
vercel --prod
```

---

## Langkah 2 — Jalankan Aplikasi (Lokal)

Pastikan Node.js terpasang, lalu dari folder proyek:

```bash
npm install      # hanya pertama kali
npm run dev
```

Buka browser ke **http://localhost:3000**

---

## Langkah 3 — Gunakan Aplikasi

- **Daftar akun** → email + kata sandi (min 6 karakter).
  - Jika "Confirm email" Supabase **nonaktif** → langsung masuk & bisa mulai belajar.
  - Jika **aktif** → cek email, klik tautan verifikasi, lalu **Masuk**.
- Alur tiap sesi: **Pre-Test** (dinilai) → **Materi/Video** → tunggu durasi minimum →
  **Post-Test** (dinilai, lulus ≥ 80) → nilai tersimpan ke `perjalanan_sesi`.
- Selesai 8 sesi dengan rata-rata ≥ 80 → sertifikat terbuka.

---

## Catatan Keamanan

- Kunci `sb_publishable` **aman** di frontend (memang untuk publik).
- Perlindungan data sebenarnya dipegang oleh **RLS** — pastikan `schema.sql` sudah dijalankan,
  kalau tidak, tabel tidak akan terlihat/terbaca sama sekali lewat API publik.
