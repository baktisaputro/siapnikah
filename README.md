# 💍 LMS Persiapan Pernikahan (terhubung Supabase)

Aplikasi Learning Management System (LMS) bimbingan pranikah, kini terhubung ke **Supabase**
(Auth + PostgreSQL) sehingga progres & nilai tiap peserta tersimpan secara permanen per akun.

---

## Struktur Proyek

```
lms-nikah/
├── index.html     # Frontend aplikasi (dasbor, materi, nilai, sertifikat)
├── login.html     # Halaman login/register (terpisah & modern)
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
   - Ini membuat tabel `perjalanan_sesi` dan `profil` plus kebijakan **Row Level Security (RLS)**
     agar tiap pengguna hanya bisa membaca/menulis datanya sendiri.

> Bila muncul pesan "Could not find the table", itu artinya langkah ini belum dijalankan.

---

## 🛡️ Panel Admin (Pemilik Aplikasi)

Admin bisa mengontrol penuh: kelola peserta, isi materi + embed video YouTube, upload artikel, dan upload template background sertifikat (goal kelulusan).

**Cara menjadikan akun sebagai Admin (sekali saja):**
1. Daftar/login akun lewat `login.html`.
2. Di Supabase Dashboard → **SQL Editor** → jalankan:
   ```sql
   update public.profil
   set is_admin = true
   where user_id = (select id from auth.users where lower(email) = 'EMAIL_ANDA');
   ```
3. Setelah itu, login ulang → otomatis diarahkan ke Panel Admin (**admin.html**).

**Halaman admin:** `https://lms-nikah.vercel.app/admin.html`

---

## 🌐 Versi Online (Vercel)

Aplikasi telah di-deploy ke Vercel dan bisa diakses online:

**› https://lms-nikah.vercel.app**

Mengunjungi root akan otomatis diarahkan ke halaman login (`login.html`) jika belum masuk.
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

> Bisa juga langsung buka `index.html` tanpa server — semua logika berjalan di browser via CDN supabase-js.

---

## Langkah 3 — Gunakan Aplikasi

- **Daftar akun** → email + kata sandi (min 6 karakter).
  - Jika di Setting Auth Supabase, "Confirm email" **nonaktif** → langsung masuk & bisa mulai belajar.
  - Jika **aktif** → cek email, klik tautan verifikasi, lalu **Masuk**.
- Setiap selesai **Post-Test**, nilai tersimpan ke tabel `perjalanan_sesi` milik akun kamu.
- Progres, status kesiapan, dan sertifikat dihitung ulang otomatis dari database.

---

## Catatan Keamanan

- Kunci `sb_publishable` **aman** ditempatkan di frontend (memang tujuannya untuk publik).
- Perlindungan data sebenarnya dipegang oleh **RLS** — pastikan `schema.sql` sudah dijalankan,
  kalau tidak, tabel tidak akan terlihat/terbaca sama sekali lewat API publik.
