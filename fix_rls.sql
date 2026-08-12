-- ============================================================
-- PERBAIKAN RLS: mencegah "infinite recursion" pada tabel profil
-- Jalankan seluruh isi file ini di: Supabase SQL Editor > Run
-- (Setelah ini, login & deteksi admin akan berfungsi normal.)
-- ============================================================

-- 1) Hapus semua POLICY lama pada tabel profil yang memicu rekursi
drop policy if exists "profil_select_own" on public.profil;
drop policy if exists "profil_select_admin" on public.profil;
drop policy if exists "profil_insert_own" on public.profil;
drop policy if exists "profil_update_own" on public.profil;
drop policy if exists "profil_update_admin" on public.profil;
drop policy if exists "profil_delete_admin" on public.profil;

-- 2) Buat fungsi security definer utk deteksi admin (bypass RLS, tanpa rekursi)
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(
    (select p.is_admin from public.profil p where p.user_id = auth.uid()),
    false
  );
$$;

-- 3) Buat ulang policy profil yang benar (pakai fungsi is_admin)
--    user biasa: baca/ubah profil sendiri
drop policy if exists "profil_select_own" on public.profil;
create policy "profil_select_own" on public.profil
    for select using (auth.uid() = user_id);

drop policy if exists "profil_insert_own" on public.profil;
create policy "profil_insert_own" on public.profil
    for insert with check (auth.uid() = user_id);

drop policy if exists "profil_update_own" on public.profil;
create policy "profil_update_own" on public.profil
    for update using (auth.uid() = user_id)
    with check (auth.uid() = user_id and is_admin = false);

--    admin: lihat & ubah SEMUA profil
drop policy if exists "profil_select_admin" on public.profil;
create policy "profil_select_admin" on public.profil
    for select using (public.is_admin());

drop policy if exists "profil_update_admin" on public.profil;
create policy "profil_update_admin" on public.profil
    for update using (public.is_admin());

drop policy if exists "profil_insert_admin" on public.profil;
create policy "profil_insert_admin" on public.profil
    for insert with check (public.is_admin());

drop policy if exists "profil_delete_admin" on public.profil;
create policy "profil_delete_admin" on public.profil
    for delete using (public.is_admin());

-- 4) Perbarui policy tabel lain yang juga memakai is_admin utk konsistensi
drop policy if exists "sesi_select_admin" on public.perjalanan_sesi;
create policy "sesi_select_admin" on public.perjalanan_sesi
    for select using (public.is_admin());

drop policy if exists "materi_adm" on public.materi;
create policy "materi_adm" on public.materi
    for all using (public.is_admin())
    with check (public.is_admin());

drop policy if exists "artikel_adm" on public.artikel;
create policy "artikel_adm" on public.artikel
    for all using (public.is_admin())
    with check (public.is_admin());

drop policy if exists "sertif_adm" on public.sertifikat_template;
create policy "sertif_adm" on public.sertifikat_template
    for all using (public.is_admin())
    with check (public.is_admin());

-- 5) TRIGGER: buat profil otomatis saat user baru mendaftar
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $BODY$
begin
    insert into public.profil (user_id, nama)
    values (new.id, coalesce(nullif(new.raw_user_meta_data->>'full_name', ''), 'Peserta'))
    on conflict (user_id) do nothing;
    return new;
end;
$BODY$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ============================================================
-- SELESAI. Sekarang jalankan query admin untuk akun pemilik.
-- ============================================================
